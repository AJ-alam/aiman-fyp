export const API_BASE = process.env.NEXT_PUBLIC_API_URL || "http://localhost:5000/api";

export async function apiRequest(endpoint: string, options: RequestInit = {}) {
    const token = typeof window !== 'undefined' ? localStorage.getItem("ownerToken") : null;

    const headers = {
        "Content-Type": "application/json",
        ...(token ? { "Authorization": `Bearer ${token}` } : {}),
        ...options.headers,
    };

    const url = `${API_BASE}${endpoint}`;
    console.log(`🌐 API Request: ${options.method || 'GET'} ${url}`);
    console.log(`🔑 Token Sent: ${token ? "✅ Yes (" + token.substring(0, 20) + "...)" : "❌ No token found"}`);

    try {
        const response = await fetch(url, {
            ...options,
            headers,
        });

        console.log(`📡 Response Status: ${response.status}`);

        const data = await response.json();
        console.log(`📦 Response Data:`, data);

        if (!response.ok) {
            const errorMessage = data.message || data.msg || `Request failed with status ${response.status}`;
            console.error(`❌ API Error [${response.status}]:`, errorMessage);
            
            // Handle 401 - clear token and redirect to login
            if (response.status === 401 && typeof window !== 'undefined') {
                console.warn("🔐 Unauthorized! Clearing token and redirecting to login...");
                localStorage.removeItem("ownerToken");
                window.location.href = "/";
            }
            
            throw new Error(errorMessage);
        }
        return data;
    } catch (error: any) {
        console.error(`❌ Network Error:`, error.message);
        throw error;
    }
}

export const adminService = {
    login: (credentials: any) => {
        console.log("🔐 [ADMIN LOGIN] Attempting owner login...");
        console.log("📧 [ADMIN LOGIN] Email:", credentials.email);
        return apiRequest("/auth/owner/login", {
            method: "POST",
            body: JSON.stringify(credentials),
        });
    },

    getAgents: async () => {
        console.log("📋 [ADMIN] Fetching all agents for queue...");
        const response = await apiRequest("/admin/agents", {
            method: "GET",
        });
        console.log("✅ [ADMIN] Agents response:", response);
        // Filter for pending in frontend if needed, or just return all and let the component handle it
        return response?.agents || [];
    },

    approveAgent: (id: string) => {
        console.log(`✅ [ADMIN] Approving agent: ${id}`);
        return apiRequest(`/admin/approve-agent/${id}`, {
            method: "PATCH",
            body: JSON.stringify({}),
        });
    },

    rejectAgent: (id: string, reason?: string) => {
        console.log(`❌ [ADMIN] Rejecting agent: ${id}`);
        return apiRequest(`/admin/reject-agent/${id}`, {
            method: "PATCH",
            body: JSON.stringify({ reason }),
        });
    },

    getAllAgents: async () => {
        console.log("📋 [ADMIN] Fetching all agents...");
        const response = await apiRequest("/admin/agents", {
            method: "GET",
        });
        console.log("✅ [ADMIN] All agents response:", response);
        return response?.agents || [];
    },

    getComplaints: async () => {
        console.log("⚠️ [ADMIN] Fetching complaints...");
        const response = await apiRequest("/admin/complaints", {
            method: "GET",
        });
        console.log("✅ [ADMIN] Complaints response:", response);
        return response?.complaints || [];
    },

    respondToComplaint: (id: string, response: string) => {
        console.log(`💬 [ADMIN] Responding to complaint: ${id}`);
        return apiRequest(`/admin/complaints/${id}/respond`, {
            method: "PATCH",
            body: JSON.stringify({ response }),
        });
    },

    getSystemLogs: async () => {
        console.log("📝 [ADMIN] Fetching system logs...");
        const response = await apiRequest("/logs", {
            method: "GET",
        });
        console.log("✅ [ADMIN] System logs response:", response);
        return response?.logs || [];
    },

    getAnalytics: async () => {
        console.log("📊 [ADMIN] Fetching analytics...");
        const response = await apiRequest("/dashboard/owner", {
            method: "GET",
        });
        console.log("✅ [ADMIN] Analytics response:", response);
        return response || {};
    },
};
