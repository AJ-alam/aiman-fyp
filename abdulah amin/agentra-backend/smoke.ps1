param(
    [string]$BaseUrl = $env:BASE_URL,
    [string]$UserEmail = $env:USER_EMAIL,
    [string]$UserPassword = $env:USER_PASSWORD,
    [string]$AgentEmail = $env:AGENT_EMAIL,
    [string]$AgentPassword = $env:AGENT_PASSWORD,
    [string]$OwnerEmail = $env:OWNER_EMAIL,
    [string]$OwnerPassword = $env:OWNER_PASSWORD,
    [string]$User2Email = $env:USER2_EMAIL,
    [string]$User2Password = $env:USER2_PASSWORD,
    [string]$InputPackageId = $env:PACKAGE_ID,
    [string]$InputBookingId = $env:BOOKING_ID,
    [string]$InputConversationId = $env:CONVERSATION_ID,
    [string]$VerboseLog = $env:VERBOSE_LOG,
    [string]$AllowDestructive = $env:ALLOW_DESTRUCTIVE_TESTS,
    [string]$ReportPath = $env:REPORT_PATH
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($BaseUrl)) {
    $BaseUrl = "http://localhost:5000"
}

$BaseUrl = $BaseUrl.Trim().TrimEnd("/")
$ApiBase = if ($BaseUrl.ToLower().EndsWith("/api")) { $BaseUrl } else { "$BaseUrl/api" }
$CompatApiBase = "$BaseUrl/api/api"

$VerboseEnabled = ($VerboseLog -eq "1" -or $VerboseLog -eq "true" -or $VerboseLog -eq "TRUE")
$AllowDestructiveEnabled = ($AllowDestructive -eq "1" -or $AllowDestructive -eq "true" -or $AllowDestructive -eq "TRUE")

if ([string]::IsNullOrWhiteSpace($ReportPath)) {
    $ReportPath = Join-Path -Path $PSScriptRoot -ChildPath "smoke-report.json"
}

$RequiredCreds = @{
    "USER_EMAIL" = $UserEmail
    "USER_PASSWORD" = $UserPassword
    "AGENT_EMAIL" = $AgentEmail
    "AGENT_PASSWORD" = $AgentPassword
    "OWNER_EMAIL" = $OwnerEmail
    "OWNER_PASSWORD" = $OwnerPassword
}

$Missing = @()
foreach ($kv in $RequiredCreds.GetEnumerator()) {
    if ([string]::IsNullOrWhiteSpace($kv.Value)) {
        $Missing += $kv.Key
    }
}

if ($Missing.Count -gt 0) {
    Write-Host "Fatal setup error: Missing required environment values: $($Missing -join ', ')" -ForegroundColor Red
    exit 1
}

$Results = New-Object System.Collections.Generic.List[object]
$Global:UserToken = $null
$Global:AgentToken = $null
$Global:OwnerToken = $null
$Global:User2Token = $null
$Global:PackageId = $InputPackageId
$Global:BookingId = $InputBookingId
$Global:ConversationId = $InputConversationId
$Global:CurrentPlan = $null

function Write-VerboseLog {
    param([string]$Message)
    if ($VerboseEnabled) {
        Write-Host "[VERBOSE] $Message" -ForegroundColor DarkGray
    }
}

function Truncate-Text {
    param(
        [AllowNull()][string]$Text,
        [int]$Max = 400
    )
    if ($null -eq $Text) { return "" }
    if ($Text.Length -le $Max) { return $Text }
    return $Text.Substring(0, $Max)
}

function Invoke-Api {
    param(
        [Parameter(Mandatory = $true)][string]$Method,
        [Parameter(Mandatory = $true)][string]$Url,
        [hashtable]$Headers,
        [AllowNull()]$Body
    )

    $requestHeaders = @{}
    if ($Headers) {
        foreach ($key in $Headers.Keys) {
            $requestHeaders[$key] = $Headers[$key]
        }
    }

    $bodyText = $null
    if ($null -ne $Body) {
        if ($Body -is [string]) {
            $bodyText = $Body
        } else {
            $bodyText = ($Body | ConvertTo-Json -Depth 20 -Compress)
        }

        if (-not $requestHeaders.ContainsKey("Content-Type")) {
            $requestHeaders["Content-Type"] = "application/json"
        }
    }

    Write-VerboseLog "$Method $Url"

    try {
        $response = Invoke-WebRequest -Method $Method -Uri $Url -Headers $requestHeaders -Body $bodyText -UseBasicParsing
        $statusCode = [int]$response.StatusCode
        $rawBody = [string]$response.Content
    } catch {
        $statusCode = 0
        $rawBody = ""
        $exception = $_.Exception
        if ($null -ne $exception.Response) {
            try {
                $statusCode = [int]$exception.Response.StatusCode
            } catch {
                $statusCode = 0
            }
            try {
                $stream = $exception.Response.GetResponseStream()
                if ($stream) {
                    $reader = New-Object System.IO.StreamReader($stream)
                    $rawBody = $reader.ReadToEnd()
                    $reader.Close()
                }
            } catch {
                $rawBody = [string]$exception.Message
            }
        } else {
            $rawBody = [string]$exception.Message
        }
    }

    $json = $null
    if (-not [string]::IsNullOrWhiteSpace($rawBody)) {
        try { $json = $rawBody | ConvertFrom-Json } catch { }
    }

    return [pscustomobject]@{
        StatusCode = $statusCode
        Body       = $rawBody
        Json       = $json
        Ok         = ($statusCode -ge 200 -and $statusCode -lt 300)
    }
}

function Assert-Status {
    param(
        [Parameter(Mandatory = $true)]$Response,
        [Parameter(Mandatory = $true)][int[]]$Allowed
    )
    return ($Allowed -contains [int]$Response.StatusCode)
}

function Assert-HasKeys {
    param(
        [AllowNull()]$Obj,
        [Parameter(Mandatory = $true)][string[]]$Keys
    )
    if ($null -eq $Obj) { return $false }
    foreach ($k in $Keys) {
        if (-not ($Obj.PSObject.Properties.Name -contains $k)) {
            return $false
        }
    }
    return $true
}

function Assert-True {
    param(
        [bool]$Condition,
        [string]$Message = "Assertion failed."
    )
    if (-not $Condition) {
        throw $Message
    }
}

function Record-TestResult {
    param(
        [Parameter(Mandatory = $true)][string]$TestName,
        [Parameter(Mandatory = $true)][string]$Status,
        [int]$Http = 0,
        [string]$Message = "",
        [string]$Evidence = ""
    )
    $Results.Add([pscustomobject]@{
        TestName  = $TestName
        Status    = $Status
        HTTP      = $Http
        Message   = $Message
        Evidence  = (Truncate-Text -Text $Evidence -Max 400)
    }) | Out-Null
}

function Run-Test {
    param(
        [Parameter(Mandatory = $true)][string]$Name,
        [Parameter(Mandatory = $true)][scriptblock]$Action
    )
    try {
        $result = & $Action
        if ($null -eq $result) {
            Record-TestResult -TestName $Name -Status "PASS" -Message "OK"
            return
        }
        $statusValue = $null
        if ($result -is [hashtable]) {
            if ($result.ContainsKey("Status")) {
                $statusValue = [string]$result["Status"]
            }
        } elseif ($result -is [psobject]) {
            if ($result.PSObject.Properties.Name -contains "Status") {
                $statusValue = [string]$result.Status
            }
        }

        if ($statusValue -eq "SKIP") {
            $msg = if ($result -is [hashtable] -and $result.ContainsKey("Message")) { [string]$result["Message"] } elseif ($result.PSObject.Properties.Name -contains "Message") { [string]$result.Message } else { "Skipped." }
            Record-TestResult -TestName $Name -Status "SKIP" -Message $msg
            return
        }

        $http = 0
        $msg = "OK"
        $evidence = ""
        if ($result -is [hashtable]) {
            if ($result.ContainsKey("Http")) { $http = [int]$result["Http"] }
            if ($result.ContainsKey("Message")) { $msg = [string]$result["Message"] }
            if ($result.ContainsKey("Evidence")) { $evidence = [string]$result["Evidence"] }
        } else {
            if ($result.PSObject.Properties.Name -contains "Http") { $http = [int]$result.Http }
            if ($result.PSObject.Properties.Name -contains "Message") { $msg = [string]$result.Message }
            if ($result.PSObject.Properties.Name -contains "Evidence") { $evidence = [string]$result.Evidence }
        }

        Record-TestResult -TestName $Name -Status "PASS" -Http $http -Message $msg -Evidence $evidence
    } catch {
        Record-TestResult -TestName $Name -Status "FAIL" -Message $_.Exception.Message
    }
}

function Get-Token {
    param(
        [Parameter(Mandatory = $true)][string]$Role,
        [Parameter(Mandatory = $true)][string]$Email,
        [Parameter(Mandatory = $true)][string]$Password,
        [string]$ApiPath = "/auth/user/login",
        [string]$Base = $ApiBase
    )

    $response = Invoke-Api -Method "POST" -Url "$Base$ApiPath" -Body @{
        email    = $Email
        password = $Password
    }

    Assert-True (Assert-Status -Response $response -Allowed @(200)) "Login failed for $Role. HTTP=$($response.StatusCode)"
    Assert-True ($null -ne $response.Json) "Login response for $Role is not JSON."
    Assert-True (Assert-HasKeys -Obj $response.Json -Keys @("token")) "Login response for $Role missing token."

    return [pscustomobject]@{
        Token    = [string]$response.Json.token
        Response = $response
    }
}

function Auth-Header {
    param([Parameter(Mandatory = $true)][string]$Token)
    return @{ "x-auth-token" = $Token }
}

Write-Host "Running smoke tests against: $BaseUrl" -ForegroundColor Cyan
Write-Host "API base: $ApiBase" -ForegroundColor Cyan
Write-Host "Compat API base: $CompatApiBase" -ForegroundColor Cyan

# ---------------- A) Health + Auth ----------------
Run-Test -Name "A1 Health GET /" -Action {
    $resp = Invoke-Api -Method "GET" -Url "$BaseUrl/"
    Assert-True (Assert-Status -Response $resp -Allowed @(200)) "Health check failed. HTTP=$($resp.StatusCode)"
    return @{ Http = $resp.StatusCode; Message = "Health endpoint reachable."; Evidence = $resp.Body }
}

Run-Test -Name "A2 User login /api/auth/user/login" -Action {
    $login = Get-Token -Role "USER" -Email $UserEmail -Password $UserPassword -ApiPath "/auth/user/login"
    $Global:UserToken = $login.Token
    return @{ Http = $login.Response.StatusCode; Message = "User token acquired."; Evidence = $login.Response.Body }
}

Run-Test -Name "A3 Agent login /api/auth/agent/login" -Action {
    $login = Get-Token -Role "AGENT" -Email $AgentEmail -Password $AgentPassword -ApiPath "/auth/agent/login"
    $Global:AgentToken = $login.Token
    return @{ Http = $login.Response.StatusCode; Message = "Agent token acquired."; Evidence = $login.Response.Body }
}

Run-Test -Name "A4 Owner login /api/auth/owner/login" -Action {
    $login = Get-Token -Role "OWNER" -Email $OwnerEmail -Password $OwnerPassword -ApiPath "/auth/owner/login"
    $Global:OwnerToken = $login.Token
    return @{ Http = $login.Response.StatusCode; Message = "Owner token acquired."; Evidence = $login.Response.Body }
}

Run-Test -Name "A5 Compat login /api/api/auth/agent/login" -Action {
    $resp = Invoke-Api -Method "POST" -Url "$CompatApiBase/auth/agent/login" -Body @{
        email    = $AgentEmail
        password = $AgentPassword
    }
    Assert-True (Assert-Status -Response $resp -Allowed @(200)) "Compat agent login failed. HTTP=$($resp.StatusCode)"
    Assert-True (Assert-HasKeys -Obj $resp.Json -Keys @("token")) "Compat agent login missing token."
    return @{ Http = $resp.StatusCode; Message = "Compat login works."; Evidence = $resp.Body }
}

Run-Test -Name "A6 User logout /api/auth/user/logout" -Action {
    if ([string]::IsNullOrWhiteSpace($Global:UserToken)) {
        return @{ Status = "SKIP"; Message = "Missing USER token." }
    }
    $resp = Invoke-Api -Method "POST" -Url "$ApiBase/auth/user/logout" -Headers (Auth-Header $Global:UserToken)
    Assert-True (Assert-Status -Response $resp -Allowed @(200)) "Logout failed. HTTP=$($resp.StatusCode)"
    return @{ Http = $resp.StatusCode; Message = "Logout endpoint works."; Evidence = $resp.Body }
}

# Optional second user for cross-user negative tests.
if (-not [string]::IsNullOrWhiteSpace($User2Email) -and -not [string]::IsNullOrWhiteSpace($User2Password)) {
    Run-Test -Name "A7 Secondary user login (optional)" -Action {
        $login = Get-Token -Role "USER2" -Email $User2Email -Password $User2Password -ApiPath "/auth/user/login"
        $Global:User2Token = $login.Token
        return @{ Http = $login.Response.StatusCode; Message = "Secondary user token acquired."; Evidence = $login.Response.Body }
    }
} else {
    Record-TestResult -TestName "A7 Secondary user login (optional)" -Status "SKIP" -Message "USER2_EMAIL/USER2_PASSWORD not provided."
}

# ---------------- B) Owner/Admin ----------------
Run-Test -Name "B1 Owner dashboard /api/owner/dashboard" -Action {
    $resp = Invoke-Api -Method "GET" -Url "$ApiBase/owner/dashboard" -Headers (Auth-Header $Global:OwnerToken)
    Assert-True (Assert-Status -Response $resp -Allowed @(200)) "Owner dashboard failed. HTTP=$($resp.StatusCode)"
    return @{ Http = $resp.StatusCode; Message = "Owner dashboard reachable."; Evidence = $resp.Body }
}

Run-Test -Name "B2 Owner agents /api/owner/agents" -Action {
    $resp = Invoke-Api -Method "GET" -Url "$ApiBase/owner/agents" -Headers (Auth-Header $Global:OwnerToken)
    Assert-True (Assert-Status -Response $resp -Allowed @(200)) "Owner agents failed. HTTP=$($resp.StatusCode)"
    return @{ Http = $resp.StatusCode; Message = "Owner agents list works."; Evidence = $resp.Body }
}

Run-Test -Name "B3 Owner compat /api/auth/owner/agents" -Action {
    $resp = Invoke-Api -Method "GET" -Url "$ApiBase/auth/owner/agents" -Headers (Auth-Header $Global:OwnerToken)
    Assert-True (Assert-Status -Response $resp -Allowed @(200)) "Owner compat agents failed. HTTP=$($resp.StatusCode)"
    return @{ Http = $resp.StatusCode; Message = "Owner compat path works."; Evidence = $resp.Body }
}

Run-Test -Name "B4 Agents list compat /api/agents" -Action {
    $resp = Invoke-Api -Method "GET" -Url "$ApiBase/agents" -Headers (Auth-Header $Global:OwnerToken)
    Assert-True (Assert-Status -Response $resp -Allowed @(200)) "Agents list compat failed. HTTP=$($resp.StatusCode)"
    return @{ Http = $resp.StatusCode; Message = "Compat agents list works."; Evidence = $resp.Body }
}

# ---------------- C) Agent Profile + Package/Analytics ----------------
Run-Test -Name "C1 Agent profile GET /api/auth/agent/profile" -Action {
    $resp = Invoke-Api -Method "GET" -Url "$ApiBase/auth/agent/profile" -Headers (Auth-Header $Global:AgentToken)
    Assert-True (Assert-Status -Response $resp -Allowed @(200)) "Agent profile get failed. HTTP=$($resp.StatusCode)"
    return @{ Http = $resp.StatusCode; Message = "Agent profile read OK."; Evidence = $resp.Body }
}

Run-Test -Name "C2 Agent profile PUT /api/auth/agent/profile" -Action {
    $bio = "Smoke test update $(Get-Date -Format s)"
    $resp = Invoke-Api -Method "PUT" -Url "$ApiBase/auth/agent/profile" -Headers (Auth-Header $Global:AgentToken) -Body @{
        bio = $bio
    }
    Assert-True (Assert-Status -Response $resp -Allowed @(200)) "Agent profile update failed. HTTP=$($resp.StatusCode)"
    return @{ Http = $resp.StatusCode; Message = "Agent profile update OK."; Evidence = $resp.Body }
}

Run-Test -Name "C3 Packages GET /api/packages" -Action {
    $resp = Invoke-Api -Method "GET" -Url "$ApiBase/packages"
    Assert-True (Assert-Status -Response $resp -Allowed @(200)) "Packages fetch failed. HTTP=$($resp.StatusCode)"
    if ([string]::IsNullOrWhiteSpace($Global:PackageId) -and $null -ne $resp.Json -and $resp.Json.packages.Count -gt 0) {
        $Global:PackageId = [string]$resp.Json.packages[0]._id
    }
    $msg = if ([string]::IsNullOrWhiteSpace($Global:PackageId)) { "Packages fetched; no package id discovered." } else { "Packages fetched; package id=$($Global:PackageId)." }
    return @{ Http = $resp.StatusCode; Message = $msg; Evidence = $resp.Body }
}

Run-Test -Name "C4 Analytics view/click/get package" -Action {
    if ([string]::IsNullOrWhiteSpace($Global:PackageId)) {
        return @{ Status = "SKIP"; Message = "No PACKAGE_ID available." }
    }

    $view = Invoke-Api -Method "POST" -Url "$ApiBase/analytics/package/$($Global:PackageId)/view"
    Assert-True (Assert-Status -Response $view -Allowed @(200)) "Analytics view failed. HTTP=$($view.StatusCode)"

    $click = Invoke-Api -Method "POST" -Url "$ApiBase/analytics/package/$($Global:PackageId)/click"
    Assert-True (Assert-Status -Response $click -Allowed @(200)) "Analytics click failed. HTTP=$($click.StatusCode)"

    $get = Invoke-Api -Method "GET" -Url "$ApiBase/analytics/package/$($Global:PackageId)" -Headers (Auth-Header $Global:AgentToken)
    Assert-True (Assert-Status -Response $get -Allowed @(200, 404)) "Analytics get unexpected status. HTTP=$($get.StatusCode)"

    return @{ Http = $get.StatusCode; Message = "Analytics endpoints callable."; Evidence = $get.Body }
}

# ---------------- D) User Core Flows ----------------
Run-Test -Name "D1 User packages GET /api/packages" -Action {
    $resp = Invoke-Api -Method "GET" -Url "$ApiBase/packages"
    Assert-True (Assert-Status -Response $resp -Allowed @(200)) "User packages fetch failed. HTTP=$($resp.StatusCode)"
    return @{ Http = $resp.StatusCode; Message = "User packages endpoint OK."; Evidence = $resp.Body }
}

Run-Test -Name "D2 Search GET /api/search?q=test" -Action {
    $resp = Invoke-Api -Method "GET" -Url "$ApiBase/search?q=test"
    Assert-True (Assert-Status -Response $resp -Allowed @(200)) "Search failed. HTTP=$($resp.StatusCode)"
    return @{ Http = $resp.StatusCode; Message = "Search endpoint OK."; Evidence = $resp.Body }
}

Run-Test -Name "D3 Create booking POST /api/bookings" -Action {
    if ([string]::IsNullOrWhiteSpace($Global:PackageId)) {
        return @{ Status = "SKIP"; Message = "No PACKAGE_ID available." }
    }
    $travelDate = (Get-Date).AddDays(15).ToString("yyyy-MM-dd")
    $resp = Invoke-Api -Method "POST" -Url "$ApiBase/bookings" -Headers (Auth-Header $Global:UserToken) -Body @{
        packageId     = $Global:PackageId
        seats         = 1
        travelDate    = $travelDate
        paymentMethod = "JAZZCASH"
    }
    Assert-True (Assert-Status -Response $resp -Allowed @(200, 201)) "Create booking failed. HTTP=$($resp.StatusCode)"
    if ($null -ne $resp.Json -and $null -ne $resp.Json.booking -and $resp.Json.booking.PSObject.Properties.Name -contains "_id") {
        $Global:BookingId = [string]$resp.Json.booking._id
    }
    return @{ Http = $resp.StatusCode; Message = "Booking created."; Evidence = $resp.Body }
}

Run-Test -Name "D4 My bookings GET /api/bookings/my" -Action {
    $resp = Invoke-Api -Method "GET" -Url "$ApiBase/bookings/my" -Headers (Auth-Header $Global:UserToken)
    Assert-True (Assert-Status -Response $resp -Allowed @(200)) "Get my bookings failed. HTTP=$($resp.StatusCode)"
    if ([string]::IsNullOrWhiteSpace($Global:BookingId) -and $null -ne $resp.Json -and $resp.Json.bookings.Count -gt 0) {
        $Global:BookingId = [string]$resp.Json.bookings[0]._id
    }
    return @{ Http = $resp.StatusCode; Message = "My bookings endpoint OK."; Evidence = $resp.Body }
}

Run-Test -Name "D5 Cancel booking PUT /api/bookings/{id}/cancel" -Action {
    if ([string]::IsNullOrWhiteSpace($Global:BookingId)) {
        return @{ Status = "SKIP"; Message = "No BOOKING_ID available." }
    }
    $resp = Invoke-Api -Method "PUT" -Url "$ApiBase/bookings/$($Global:BookingId)/cancel" -Headers (Auth-Header $Global:UserToken)
    Assert-True (Assert-Status -Response $resp -Allowed @(200)) "Cancel booking failed. HTTP=$($resp.StatusCode)"
    return @{ Http = $resp.StatusCode; Message = "Cancel booking endpoint OK."; Evidence = $resp.Body }
}

# ---------------- E) Payment Compatibility ----------------
Run-Test -Name "E1 Payment methods includes paymentMethods+methods" -Action {
    $resp = Invoke-Api -Method "GET" -Url "$ApiBase/payments/methods"
    Assert-True (Assert-Status -Response $resp -Allowed @(200)) "Payment methods failed. HTTP=$($resp.StatusCode)"
    Assert-True (Assert-HasKeys -Obj $resp.Json -Keys @("paymentMethods", "methods")) "Payment methods response missing compatibility keys."
    return @{ Http = $resp.StatusCode; Message = "Payment methods compatibility keys present."; Evidence = $resp.Body }
}

Run-Test -Name "E2 Payment history includes transactions+payments" -Action {
    $resp = Invoke-Api -Method "GET" -Url "$ApiBase/payments/history" -Headers (Auth-Header $Global:UserToken)
    Assert-True (Assert-Status -Response $resp -Allowed @(200)) "Payment history failed. HTTP=$($resp.StatusCode)"
    Assert-True (Assert-HasKeys -Obj $resp.Json -Keys @("transactions", "payments")) "Payment history response missing compatibility keys."
    return @{ Http = $resp.StatusCode; Message = "Payment history compatibility keys present."; Evidence = $resp.Body }
}

Run-Test -Name "E3 Optional payment intent/process (skip if no unpaid booking path)" -Action {
    if ([string]::IsNullOrWhiteSpace($Global:BookingId)) {
        return @{ Status = "SKIP"; Message = "No BOOKING_ID available." }
    }
    $intent = Invoke-Api -Method "POST" -Url "$ApiBase/payments/intent" -Headers (Auth-Header $Global:UserToken) -Body @{
        bookingId = $Global:BookingId
        paymentMethod = "JAZZCASH"
    }
    if ($intent.StatusCode -eq 400 -or $intent.StatusCode -eq 404) {
        return @{ Status = "SKIP"; Message = "No unpaid booking path available for intent/process in current data flow." }
    }
    Assert-True (Assert-Status -Response $intent -Allowed @(200)) "Payment intent failed. HTTP=$($intent.StatusCode)"

    $process = Invoke-Api -Method "POST" -Url "$ApiBase/payments/process" -Headers (Auth-Header $Global:UserToken) -Body @{
        bookingId = $Global:BookingId
        paymentMethod = "JAZZCASH"
        paymentDetails = @{ source = "smoke" }
    }
    Assert-True (Assert-Status -Response $process -Allowed @(200)) "Payment process failed. HTTP=$($process.StatusCode)"
    return @{ Http = $process.StatusCode; Message = "Payment intent/process path works."; Evidence = $process.Body }
}

# ---------------- F) Reviews + Saved Optional Auth ----------------
Run-Test -Name "F1 Public reviews /api/users/reviews?packageId=..." -Action {
    if ([string]::IsNullOrWhiteSpace($Global:PackageId)) {
        return @{ Status = "SKIP"; Message = "No PACKAGE_ID available." }
    }
    $resp = Invoke-Api -Method "GET" -Url "$ApiBase/users/reviews?packageId=$($Global:PackageId)"
    Assert-True (Assert-Status -Response $resp -Allowed @(200)) "Public package reviews failed. HTTP=$($resp.StatusCode)"
    return @{ Http = $resp.StatusCode; Message = "Public package reviews endpoint OK."; Evidence = $resp.Body }
}

Run-Test -Name "F2 Saved check no token /api/saved/{id}/check" -Action {
    if ([string]::IsNullOrWhiteSpace($Global:PackageId)) {
        return @{ Status = "SKIP"; Message = "No PACKAGE_ID available." }
    }
    $resp = Invoke-Api -Method "GET" -Url "$ApiBase/saved/$($Global:PackageId)/check"
    Assert-True (Assert-Status -Response $resp -Allowed @(200)) "Saved check without token failed. HTTP=$($resp.StatusCode)"
    Assert-True (Assert-HasKeys -Obj $resp.Json -Keys @("isSaved")) "Saved check response missing isSaved."
    Assert-True (-not [bool]$resp.Json.isSaved) "Expected isSaved=false without token."
    return @{ Http = $resp.StatusCode; Message = "Saved check without token returns isSaved=false."; Evidence = $resp.Body }
}

Run-Test -Name "F3 Saved check with token /api/saved/{id}/check" -Action {
    if ([string]::IsNullOrWhiteSpace($Global:PackageId)) {
        return @{ Status = "SKIP"; Message = "No PACKAGE_ID available." }
    }
    $resp = Invoke-Api -Method "GET" -Url "$ApiBase/saved/$($Global:PackageId)/check" -Headers (Auth-Header $Global:UserToken)
    Assert-True (Assert-Status -Response $resp -Allowed @(200)) "Saved check with token failed. HTTP=$($resp.StatusCode)"
    Assert-True (Assert-HasKeys -Obj $resp.Json -Keys @("isSaved", "notes")) "Saved check with token missing keys."
    return @{ Http = $resp.StatusCode; Message = "Saved check with token returns expected structure."; Evidence = $resp.Body }
}

# ---------------- G) Chatbot Auth + Ownership ----------------
Run-Test -Name "G1 Chatbot start /api/chatbot/start" -Action {
    $resp = Invoke-Api -Method "POST" -Url "$ApiBase/chatbot/start" -Headers (Auth-Header $Global:UserToken)
    Assert-True (Assert-Status -Response $resp -Allowed @(200)) "Chatbot start failed. HTTP=$($resp.StatusCode)"
    if ($null -ne $resp.Json -and $resp.Json.PSObject.Properties.Name -contains "conversationId") {
        $Global:ConversationId = [string]$resp.Json.conversationId
    }
    return @{ Http = $resp.StatusCode; Message = "Chatbot conversation started."; Evidence = $resp.Body }
}

Run-Test -Name "G2 Chatbot message with owner token" -Action {
    if ([string]::IsNullOrWhiteSpace($Global:ConversationId)) {
        return @{ Status = "SKIP"; Message = "No CONVERSATION_ID available." }
    }
    $resp = Invoke-Api -Method "POST" -Url "$ApiBase/chatbot/message" -Headers (Auth-Header $Global:UserToken) -Body @{
        conversationId = $Global:ConversationId
        message = "hello from smoke test"
    }
    Assert-True (Assert-Status -Response $resp -Allowed @(200)) "Chatbot message failed. HTTP=$($resp.StatusCode)"
    return @{ Http = $resp.StatusCode; Message = "Chatbot message works for owner user."; Evidence = $resp.Body }
}

Run-Test -Name "G3 Chatbot ownership negative with secondary user" -Action {
    if ([string]::IsNullOrWhiteSpace($Global:ConversationId)) {
        return @{ Status = "SKIP"; Message = "No CONVERSATION_ID available." }
    }
    if ([string]::IsNullOrWhiteSpace($Global:User2Token)) {
        return @{ Status = "SKIP"; Message = "No secondary user token provided." }
    }
    $resp = Invoke-Api -Method "POST" -Url "$ApiBase/chatbot/message" -Headers (Auth-Header $Global:User2Token) -Body @{
        conversationId = $Global:ConversationId
        message = "unauthorized access test"
    }
    Assert-True (Assert-Status -Response $resp -Allowed @(403, 404)) "Expected 403/404 for cross-user conversation access. HTTP=$($resp.StatusCode)"
    return @{ Http = $resp.StatusCode; Message = "Cross-user chatbot ownership enforced."; Evidence = $resp.Body }
}

Run-Test -Name "G4 Chatbot message without token should fail" -Action {
    if ([string]::IsNullOrWhiteSpace($Global:ConversationId)) {
        return @{ Status = "SKIP"; Message = "No CONVERSATION_ID available." }
    }
    $resp = Invoke-Api -Method "POST" -Url "$ApiBase/chatbot/message" -Body @{
        conversationId = $Global:ConversationId
        message = "should fail without token"
    }
    Assert-True (Assert-Status -Response $resp -Allowed @(401)) "Expected 401 for unauthenticated chatbot message. HTTP=$($resp.StatusCode)"
    return @{ Http = $resp.StatusCode; Message = "Chatbot message auth enforced."; Evidence = $resp.Body }
}

# ---------------- H) Security Negatives ----------------
Run-Test -Name "H1 Cancel booking without token => 401" -Action {
    if ([string]::IsNullOrWhiteSpace($Global:BookingId)) {
        return @{ Status = "SKIP"; Message = "No BOOKING_ID available." }
    }
    $resp = Invoke-Api -Method "PUT" -Url "$ApiBase/bookings/$($Global:BookingId)/cancel"
    Assert-True (Assert-Status -Response $resp -Allowed @(401)) "Expected 401 for cancel without token. HTTP=$($resp.StatusCode)"
    return @{ Http = $resp.StatusCode; Message = "Cancel booking auth enforced."; Evidence = $resp.Body }
}

Run-Test -Name "H2 Cancel booking wrong user => 403 (optional)" -Action {
    if ([string]::IsNullOrWhiteSpace($Global:BookingId)) {
        return @{ Status = "SKIP"; Message = "No BOOKING_ID available." }
    }
    if ([string]::IsNullOrWhiteSpace($Global:User2Token)) {
        return @{ Status = "SKIP"; Message = "No secondary user token provided." }
    }
    $resp = Invoke-Api -Method "PUT" -Url "$ApiBase/bookings/$($Global:BookingId)/cancel" -Headers (Auth-Header $Global:User2Token)
    Assert-True (Assert-Status -Response $resp -Allowed @(403)) "Expected 403 for wrong user booking cancel. HTTP=$($resp.StatusCode)"
    return @{ Http = $resp.StatusCode; Message = "Booking ownership enforced."; Evidence = $resp.Body }
}

Run-Test -Name "H3 temp-cleanup without owner => 401/403" -Action {
    $resp = Invoke-Api -Method "DELETE" -Url "$ApiBase/packages/temp-cleanup"
    Assert-True (Assert-Status -Response $resp -Allowed @(401, 403)) "Expected 401/403 for temp-cleanup without owner token. HTTP=$($resp.StatusCode)"
    return @{ Http = $resp.StatusCode; Message = "Temp-cleanup protected."; Evidence = $resp.Body }
}

Run-Test -Name "H4 temp-cleanup with owner token (destructive, opt-in)" -Action {
    if (-not $AllowDestructiveEnabled) {
        return @{ Status = "SKIP"; Message = "Set ALLOW_DESTRUCTIVE_TESTS=true to run." }
    }
    $resp = Invoke-Api -Method "DELETE" -Url "$ApiBase/packages/temp-cleanup" -Headers (Auth-Header $Global:OwnerToken)
    Assert-True (Assert-Status -Response $resp -Allowed @(200)) "Expected owner cleanup call to be allowed. HTTP=$($resp.StatusCode)"
    return @{ Http = $resp.StatusCode; Message = "Owner can call protected cleanup route."; Evidence = $resp.Body }
}

# ---------------- I) Subscription Reliability ----------------
Run-Test -Name "I1 Subscription plans GET /api/subscription/plans" -Action {
    $resp = Invoke-Api -Method "GET" -Url "$ApiBase/subscription/plans"
    Assert-True (Assert-Status -Response $resp -Allowed @(200)) "Subscription plans failed. HTTP=$($resp.StatusCode)"
    return @{ Http = $resp.StatusCode; Message = "Subscription plans endpoint OK."; Evidence = $resp.Body }
}

Run-Test -Name "I2 Subscribe agent /api/subscription/subscribe" -Action {
    $resp = Invoke-Api -Method "POST" -Url "$ApiBase/subscription/subscribe" -Headers (Auth-Header $Global:AgentToken) -Body @{
        plan = "MONTHLY"
        paymentMethod = "JAZZCASH"
    }
    Assert-True (Assert-Status -Response $resp -Allowed @(200, 201, 400)) "Subscribe unexpected status. HTTP=$($resp.StatusCode)"
    if ($resp.StatusCode -eq 400) {
        $msg = if ($null -ne $resp.Json -and $resp.Json.PSObject.Properties.Name -contains "message") { [string]$resp.Json.message } else { "400 returned without message." }
        Assert-True ($msg -match "active subscription|already") "Subscribe returned 400 for unexpected reason: $msg"
        return @{ Http = $resp.StatusCode; Message = "Subscribe blocked due to existing active subscription (acceptable)."; Evidence = $resp.Body }
    }
    return @{ Http = $resp.StatusCode; Message = "Subscribe flow OK."; Evidence = $resp.Body }
}

Run-Test -Name "I3 Current subscription GET /api/subscription/current" -Action {
    $resp = Invoke-Api -Method "GET" -Url "$ApiBase/subscription/current" -Headers (Auth-Header $Global:AgentToken)
    Assert-True (Assert-Status -Response $resp -Allowed @(200)) "Current subscription failed. HTTP=$($resp.StatusCode)"
    if ($null -ne $resp.Json -and $null -ne $resp.Json.subscription -and $resp.Json.subscription.PSObject.Properties.Name -contains "plan") {
        $Global:CurrentPlan = [string]$resp.Json.subscription.plan
    }
    return @{ Http = $resp.StatusCode; Message = "Current subscription endpoint OK."; Evidence = $resp.Body }
}

Run-Test -Name "I4 Upgrade subscription alternate plan" -Action {
    if ([string]::IsNullOrWhiteSpace($Global:CurrentPlan)) {
        return @{ Status = "SKIP"; Message = "Current plan not available." }
    }
    $target = if ($Global:CurrentPlan -eq "MONTHLY") { "YEARLY" } else { "MONTHLY" }
    $resp = Invoke-Api -Method "POST" -Url "$ApiBase/subscription/upgrade" -Headers (Auth-Header $Global:AgentToken) -Body @{
        plan = $target
        paymentMethod = "JAZZCASH"
    }
    Assert-True (Assert-Status -Response $resp -Allowed @(200)) "Upgrade subscription failed. HTTP=$($resp.StatusCode)"
    return @{ Http = $resp.StatusCode; Message = "Upgrade subscription to $target succeeded."; Evidence = $resp.Body }
}

Run-Test -Name "I5 Cancel subscription then verify /current" -Action {
    $cancel = Invoke-Api -Method "POST" -Url "$ApiBase/subscription/cancel" -Headers (Auth-Header $Global:AgentToken)
    Assert-True (Assert-Status -Response $cancel -Allowed @(200, 404)) "Cancel subscription unexpected status. HTTP=$($cancel.StatusCode)"

    $current = Invoke-Api -Method "GET" -Url "$ApiBase/subscription/current" -Headers (Auth-Header $Global:AgentToken)
    Assert-True (Assert-Status -Response $current -Allowed @(200, 404)) "Current subscription post-cancel unexpected status. HTTP=$($current.StatusCode)"

    return @{ Http = $current.StatusCode; Message = "Cancel/current consistency check completed."; Evidence = $current.Body }
}

# ---------------- Summary + Report ----------------
$passed = @($Results | Where-Object { $_.Status -eq "PASS" }).Count
$failed = @($Results | Where-Object { $_.Status -eq "FAIL" }).Count
$skipped = @($Results | Where-Object { $_.Status -eq "SKIP" }).Count

Write-Host ""
Write-Host "Smoke Test Results" -ForegroundColor Cyan
$Results | Select-Object TestName, Status, HTTP, Message | Format-Table -AutoSize

Write-Host ""
Write-Host "Summary: PASS=$passed FAIL=$failed SKIP=$skipped" -ForegroundColor Cyan

$report = [pscustomobject]@{
    runAt = (Get-Date).ToString("s")
    baseUrl = $BaseUrl
    apiBase = $ApiBase
    compatApiBase = $CompatApiBase
    counts = @{
        pass = $passed
        fail = $failed
        skip = $skipped
    }
    failedTests = @($Results | Where-Object { $_.Status -eq "FAIL" } | Select-Object -ExpandProperty TestName)
    results = $Results
}

try {
    $report | ConvertTo-Json -Depth 20 | Set-Content -Path $ReportPath -Encoding UTF8
    Write-Host "Report written: $ReportPath" -ForegroundColor Gray
} catch {
    Write-Host "Warning: failed to write report file: $($_.Exception.Message)" -ForegroundColor Yellow
}

if ($failed -gt 0) {
    exit 1
}
exit 0
