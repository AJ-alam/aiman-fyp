"use client";

import { useEffect, useState } from "react";
import Image from "next/image";
import { adminService } from "@/lib/api";

type ViewState = "splash" | "onboarding" | "signin" | "signup" | "main" | "admin-dashboard" | "admin-agents" | "admin-complaints" | "admin-logs" | "admin-analytics";

export default function Home() {
  
  const [view, setView] = useState<ViewState>("splash");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState("");

  // Admin State
  const [agents, setAgents] = useState<any[]>([]);
  const [allAgents, setAllAgents] = useState<any[]>([]);
  const [complaints, setComplaints] = useState<any[]>([]);
  const [systemLogs, setSystemLogs] = useState<any[]>([]);
  const [analytics, setAnalytics] = useState<any>({});
  const [stats, setStats] = useState({
    totalUsers: 0,
    totalAgents: 0,
    totalBookings: 0,
    totalComplaints: 0,
  });
  useEffect(() => {
    if (view === "splash") {
      const timer = setTimeout(() => {
        // Check for existing owner session
        const token = localStorage.getItem("ownerToken");
        if (token) {
          // Redirect to admin dashboard using window.location
          window.location.href = '/admin';
        } else {
          setView("onboarding");
        }
      }, 2500);
      return () => clearTimeout(timer);
    }
  }, [view]);

  useEffect(() => {
    if (view === "admin-dashboard") {
      loadAdminData();
    }
  }, [view]);

  const loadAdminData = async () => {
    try {
      setIsLoading(true);
      setError(""); // Clear previous errors
      console.log("📊 Loading admin data...");
      
      const agentsData = await adminService.getAgents();
      console.log("✅ Agents data received:", agentsData);
      
      // Handle both array and object responses
      const agentsList = Array.isArray(agentsData) ? agentsData : (agentsData || []);
      console.log("✅ Processed agents list:", agentsList);
      
      setAgents(agentsList);
      console.log("✅ Admin data loaded successfully. Total agents:", agentsList.length);
    } catch (err: any) {
      const errorMsg = err.message || "Failed to load admin data";
      console.error("❌ Error loading admin data:", errorMsg);
      setError(errorMsg);
      
      // If unauthorized, logout and redirect to login
      if (err.message.includes("Token") || err.message.includes("unauthorized") || err.message.includes("401")) {
        console.warn("🔐 Token invalid or expired, logging out...");
        handleLogout();
      }
    } finally {
      setIsLoading(false);
    }
  };

  const handleOwnerLogin = async () => {
    try {
      setIsLoading(true);
      setError("");
      console.log("🔐 [LOGIN] Attempting owner login with email:", email);
      
      const data = await adminService.login({ email, password });
      console.log("✅ [LOGIN] Login successful, token received:", data.token?.substring(0, 20) + "...");
      
      localStorage.setItem("ownerToken", data.token);
      setView("admin-dashboard");
    } catch (err: any) {
      const errorMsg = err.message || "Admin login failed";
      console.error("❌ [LOGIN] Login error:", errorMsg);
      
      // Provide specific error messages
      if (errorMsg.includes("Owner not found") || errorMsg.includes("404")) {
        setError("Email not found. Please contact support.");
      } else if (errorMsg.includes("Invalid credentials") || errorMsg.includes("400")) {
        setError("Invalid email or password.");
      } else if (errorMsg.includes("Server") || errorMsg.includes("500")) {
        setError("Server error. Please try again later.");
      } else {
        setError(errorMsg);
      }
    } finally {
      setIsLoading(false);
    }
  };

  const handleApproveAgent = async (id: string, agentName: string) => {
    if (confirm(`Are you sure you want to approve ${agentName}'s application?`)) {
      try {
        setIsLoading(true);
        console.log('✅ Approving agent:', { id, agentName });
        const result = await adminService.approveAgent(id);
        console.log('✅ Approve result:', result);
        alert(`${agentName}'s application has been approved successfully.`);
        await loadAdminData(); // Refresh list
      } catch (err: any) {
        console.error('❌ Approve error:', err);
        alert(`Failed to approve agent: ${err.message || 'Unknown error'}`);
      } finally {
        setIsLoading(false);
      }
    }
  };

  const handleRejectAgent = async (id: string, agentName: string) => {
    const reason = prompt(`Why are you rejecting ${agentName}'s application?`);
    if (reason !== null) { // User clicked OK (null means cancelled)
      try {
        setIsLoading(true);
        console.log('❌ Rejecting agent:', { id, agentName, reason });
        const result = await adminService.rejectAgent(id, reason);
        console.log('✅ Reject result:', result);
        alert(`${agentName}'s application has been rejected.`);
        await loadAdminData(); // Refresh list
      } catch (err: any) {
        console.error('❌ Reject error:', err);
        alert(`Failed to reject agent: ${err.message || 'Unknown error'}`);
      } finally {
        setIsLoading(false);
      }
    }
  };

  const handleLogout = () => {
    localStorage.removeItem("ownerToken");
    setView("signin");
  };

  // Admin Navigation Handlers
  const handleNavClick = (section: string) => {
    setView(`admin-${section.toLowerCase()}` as ViewState);
    loadSectionData(section.toLowerCase());
  };

  const loadSectionData = async (section: string) => {
    try {
      setIsLoading(true);
      setError("");

      switch (section) {
        case 'dashboard':
          await loadAdminData();
          break;
        case 'agents':
          await loadAllAgents();
          break;
        case 'complaints':
          await loadComplaints();
          break;
        case 'logs':
          await loadSystemLogs();
          break;
        case 'analytics':
          await loadAnalytics();
          break;
      }
    } catch (err: any) {
      console.error(`❌ Error loading ${section} data:`, err);
      setError(`Failed to load ${section} data`);
    } finally {
      setIsLoading(false);
    }
  };

  const loadAllAgents = async () => {
    console.log("📋 Loading all agents...");
    try {
      const response = await adminService.getAllAgents();
      setAllAgents(response || []);
      console.log("✅ All agents loaded:", response?.length || 0);
    } catch (err) {
      console.error("❌ Failed to load all agents:", err);
      throw err;
    }
  };

  const loadComplaints = async () => {
    console.log("⚠️ Loading complaints...");
    try {
      const response = await adminService.getComplaints();
      setComplaints(response || []);
      console.log("✅ Complaints loaded:", response?.length || 0);
    } catch (err) {
      console.error("❌ Failed to load complaints:", err);
      throw err;
    }
  };

  const loadSystemLogs = async () => {
    console.log("📝 Loading system logs...");
    try {
      const response = await adminService.getSystemLogs();
      setSystemLogs(response || []);
      console.log("✅ System logs loaded:", response?.length || 0);
    } catch (err) {
      console.error("❌ Failed to load system logs:", err);
      throw err;
    }
  };

  const loadAnalytics = async () => {
    console.log("📊 Loading analytics...");
    try {
      const response = await adminService.getAnalytics();
      setAnalytics(response || {});
      console.log("✅ Analytics loaded:", response);
    } catch (err) {
      console.error("❌ Failed to load analytics:", err);
      throw err;
    }
  };

  // Splash Screen
  if (view === "splash") {
    return (
      <div className="fixed inset-0 z-50 flex flex-col items-center justify-center bg-white">
        <div className="relative animate-pulse mb-8">
          <Image
            src="/logo.png"
            alt="Agentra Logo"
            width={180}
            height={180}
            className="object-contain"
            priority
          />
        </div>
        <h1 className="text-3xl font-extrabold tracking-[0.3em] text-[#1B1E28] mt-4 uppercase">
          AGENTRA
        </h1>
        <p className="text-sm text-gray-400 font-bold tracking-widest mt-2 uppercase">
          Admin Control Center
        </p>
      </div>
    );
  }

  // Onboarding Screen
  if (view === "onboarding") {
    return (
      <div className="fixed inset-0 z-40 bg-gray-50 flex flex-col items-center overflow-hidden">
        <div className="relative w-full h-[55%] rounded-b-[50px] overflow-hidden shadow-2xl">
          <Image
            src="/onboarding_mountain.jpeg"
            alt="Onboarding Background"
            fill
            className="object-cover transition-transform duration-[15s] scale-110"
            priority
          />
          <div className="absolute inset-0 bg-gradient-to-b from-black/30 via-transparent to-black/20" />
        </div>

        <div className="absolute bottom-0 w-full h-[50%] bg-white rounded-t-[50px] px-10 pt-12 pb-14 flex flex-col items-center justify-between shadow-[0_-25px_60px_-15px_rgba(0,0,0,0.2)] transition-all duration-1000 ease-out">
          <div className="flex flex-col items-center text-center space-y-5 max-w-xl">
            <h2 className="text-4xl sm:text-5xl font-black text-[#1B1E28] leading-tight">
              Empower your travel <span className="text-[#FF6B35]">network</span>
            </h2>
            <div className="relative w-48 h-3">
              <svg className="absolute top-0 left-0 w-full h-full" viewBox="0 0 120 10" preserveAspectRatio="none">
                <path d="M0 5 Q60 15 120 5" fill="none" stroke="#FF6B35" strokeWidth="5" strokeLinecap="round" />
              </svg>
            </div>
            <p className="text-[#7D848D] text-lg leading-relaxed mt-6 font-medium px-4">
              "Manage, verify, and monitor your agency ecosystem with professional-grade administrative tools."
            </p>
          </div>

          <button
            onClick={() => setView("signin")}
            className="w-full max-w-md h-16 bg-[#007AFF] text-white rounded-[20px] font-bold text-xl hover:bg-[#0062CC] transition-all active:scale-95 shadow-xl shadow-blue-200 uppercase tracking-widest block"
          >
            Access Admin Portal
          </button>
        </div>
      </div>
    );
  }

  // Sign In Screen
  if (view === "signin") {
    return (
      <div className="min-h-screen bg-white flex flex-col items-center justify-center p-6 sm:p-12 relative">
        <button
          onClick={() => setView("onboarding")}
          className="absolute top-10 left-10 w-12 h-12 flex items-center justify-center bg-gray-50 rounded-full hover:bg-gray-100 transition-colors"
        >
          <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round"><path d="m15 18-6-6 6-6" /></svg>
        </button>

        <div className="w-full max-w-md space-y-12">
          <div className="text-center space-y-3">
            <h1 className="text-4xl font-black text-[#1B1E28]">Admin Login</h1>
            <p className="text-[#7D848D] text-lg font-medium">Verify agents and manage system</p>
          </div>

          <div className="space-y-6">
            <input
              type="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              placeholder="admin@agentra.com"
              className="w-full h-16 px-6 bg-[#F7F8F9] rounded-2xl border-none focus:ring-2 focus:ring-[#007AFF] text-lg font-medium transition-all outline-none"
            />
            <input
              type="password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              placeholder="**********"
              className="w-full h-16 px-6 bg-[#F7F8F9] rounded-2xl border-none focus:ring-2 focus:ring-[#007AFF] text-lg font-medium transition-all outline-none"
            />
            {error && <p className="text-red-500 font-bold text-center">{error}</p>}
          </div>

          <button
            onClick={handleOwnerLogin}
            disabled={isLoading}
            className="w-full h-16 bg-[#1B1E28] text-white rounded-[20px] font-bold text-xl hover:bg-black transition-all active:scale-95 shadow-lg uppercase tracking-widest flex items-center justify-center"
          >
            {isLoading ? "Authenticating..." : "Sign In As Owner"}
          </button>
        </div>
      </div>
    );
  }

  // Admin Dashboard View
  if (view === "admin-dashboard") {
    return (
      <div className="flex min-h-screen bg-[#F8F9FA] text-[#1B1E28]">
        {/* Sidebar */}
        <aside className="hidden lg:flex flex-col w-80 bg-white border-r border-gray-100 p-10 space-y-12 shrink-0">
          <div className="flex items-center space-x-4">
            <Image src="/logo.png" alt="Logo" width={50} height={50} className="object-contain" />
            <span className="text-2xl font-black uppercase tracking-widest">ADMIN</span>
          </div>

          <nav className="flex-1 space-y-4">
            {[
              { name: 'Dashboard', icon: '🏠', section: 'dashboard' },
              { name: 'Agents', icon: '👤', section: 'agents' },
              { name: 'Complaints', icon: '⚠️', section: 'complaints' },
              { name: 'System Logs', icon: '📝', section: 'logs' },
              { name: 'Analytics', icon: '📊', section: 'analytics' }
            ].map((item) => (
              <div
                key={item.name}
                onClick={() => handleNavClick(item.section)}
                className={`flex items-center space-x-4 p-4 rounded-xl cursor-pointer transition-all group ${
                  view === `admin-${item.section}`
                    ? 'bg-[#007AFF] text-white shadow-lg'
                    : 'hover:bg-blue-50 hover:text-[#007AFF]'
                }`}
              >
                <span className="text-xl">{item.icon}</span>
                <span className="text-lg font-bold">{item.name}</span>
              </div>
            ))}
          </nav>

          <button
            onClick={handleLogout}
            className="w-full py-4 border-2 border-red-50 text-red-500 rounded-2xl font-bold hover:bg-red-50 transition-all flex items-center justify-center space-x-2"
          >
            <span>Log out</span>
          </button>
        </aside>

        {/* Main Content */}
        <main className="flex-1 flex flex-col p-8 sm:p-12 space-y-12 overflow-y-auto">
          <header className="flex items-center justify-between">
            <div className="space-y-1">
              <h1 className="text-4xl font-black">System Overview</h1>
              <p className="text-[#7D848D] text-lg font-medium">Agent verification and system statistics</p>
            </div>
            <div className="flex items-center space-x-6">
              <div className="flex items-center space-x-4 bg-white p-2 pr-6 rounded-2xl shadow-sm border border-gray-50">
                <div className="w-12 h-12 bg-[#FF6B35] rounded-xl flex items-center justify-center text-white font-bold">A</div>
                <span className="font-bold text-gray-700">Administrator</span>
              </div>
            </div>
          </header>

          {/* Stats Grid */}
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-8">
            {[
              { label: 'Total Users', value: stats?.totalUsers || '0', color: 'blue' },
              { label: 'Total Agents', value: stats?.totalAgents || '0', color: 'orange' },
              { label: 'Total Bookings', value: stats?.totalBookings || '0', color: 'green' },
              { label: 'Complaints', value: stats?.totalComplaints || '0', color: 'red' }
            ].map((stat, i) => (
              <div key={i} className="bg-white p-8 rounded-[32px] shadow-sm border border-gray-50 flex flex-col justify-between hover:shadow-md transition-all">
                <p className="text-[#7D848D] font-bold uppercase tracking-widest text-xs">{stat.label}</p>
                <h3 className="text-4xl font-black mt-2">{stat.value}</h3>
              </div>
            ))}
          </div>

          {/* Verification Table */}
          <div className="bg-white rounded-[40px] shadow-sm border border-gray-50 overflow-hidden">
            <div className="p-10 border-b border-gray-50 flex items-center justify-between bg-gray-50/30">
              <h2 className="text-2xl font-black">Agent Verification Queue</h2>
              <div className="bg-[#007AFF]/10 text-[#007AFF] px-6 py-2 rounded-full font-bold text-sm">
                {agents.filter(a => a.status === 'PENDING_APPROVAL').length} Pending
              </div>
            </div>

            {/* Loading State */}
            {isLoading && (
              <div className="p-10 text-center">
                <p className="text-gray-500 font-medium">Loading agents...</p>
              </div>
            )}

            {/* Error State */}
            {error && !isLoading && (
              <div className="p-10 text-center bg-red-50 border-t border-red-100">
                <p className="text-red-600 font-medium">⚠️ {error}</p>
              </div>
            )}

            {/* Table */}
            {!isLoading && (
              <div className="overflow-x-auto">
                <table className="w-full text-left border-collapse">
                  <thead>
                    <tr className="bg-gray-50/50">
                      <th className="px-10 py-6 text-[#7D848D] font-bold uppercase tracking-widest text-xs">Agent Information</th>
                      <th className="px-10 py-6 text-[#7D848D] font-bold uppercase tracking-widest text-xs">Business/CNIC</th>
                      <th className="px-10 py-6 text-[#7D848D] font-bold uppercase tracking-widest text-xs">Status</th>
                      <th className="px-10 py-6 text-[#7D848D] font-bold uppercase tracking-widest text-xs text-right">Actions</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-gray-50">
                    {agents.length === 0 ? (
                      <tr>
                        <td colSpan={4} className="px-10 py-20 text-center text-gray-400 font-medium">
                          ✓ No agents waiting for approval. All applications have been processed!
                        </td>
                      </tr>
                    ) : (
                      agents.map((agent) => (
                        <tr key={agent._id} className="hover:bg-gray-50/30 transition-colors">
                          <td className="px-10 py-8">
                            <div className="flex flex-col">
                              <span className="font-bold text-lg">{agent.fullName || agent.name || 'N/A'}</span>
                              <span className="text-[#7D848D] text-sm">{agent.email}</span>
                              <span className="text-[#7D848D] text-xs font-mono">{agent.phone}</span>
                            </div>
                          </td>
                          <td className="px-10 py-8">
                            <div className="flex flex-col">
                              <span className="font-medium">{agent.businessName || 'N/A'}</span>
                              <span className="text-[#7D848D] text-xs mt-1">CNIC: {agent.cnic || 'N/A'}</span>
                            </div>
                          </td>
                          <td className="px-10 py-8">
                            <span className={`inline-flex items-center px-4 py-1.5 rounded-full text-xs font-black uppercase tracking-tighter ${
                              agent.status === 'APPROVED'
                                ? 'bg-green-100 text-green-600'
                                : agent.status === 'REJECTED'
                                ? 'bg-red-100 text-red-600'
                                : 'bg-yellow-100 text-yellow-600'
                              }`}>
                              {agent.status || 'PENDING_APPROVAL'}
                            </span>
                          </td>
                          <td className="px-10 py-8">
                            {agent.status === 'PENDING_APPROVAL' && (
                              <div className="flex items-center justify-end gap-3">
                                <button
                                  onClick={() => handleApproveAgent(agent._id, agent.fullName || agent.name)}
                                  disabled={isLoading}
                                  className="px-6 py-3 bg-[#007AFF] text-white rounded-xl font-bold text-sm hover:shadow-lg hover:shadow-blue-200 transition-all active:scale-95 disabled:opacity-50"
                                >
                                  Approve
                                </button>
                                <button
                                  onClick={() => handleRejectAgent(agent._id, agent.fullName || agent.name)}
                                  disabled={isLoading}
                                  className="px-6 py-3 bg-red-50 text-red-600 rounded-xl font-bold text-sm hover:bg-red-100 transition-all active:scale-95 disabled:opacity-50"
                                >
                                  Reject
                                </button>
                              </div>
                            )}
                            {agent.status === 'APPROVED' && (
                              <button className="px-6 py-3 border border-green-200 text-green-600 rounded-xl font-bold text-sm hover:bg-green-50 transition-all">
                                ✓ Approved
                              </button>
                            )}
                            {agent.status === 'REJECTED' && (
                              <button className="px-6 py-3 border border-red-200 text-red-600 rounded-xl font-bold text-sm hover:bg-red-50 transition-all">
                                ✗ Rejected
                              </button>
                            )}
                          </td>
                        </tr>
                      ))
                    )}
                  </tbody>
                </table>
              </div>
            )}
          </div>
        </main>
      </div>
    );
  }

  // Admin Agents View
  if (view === "admin-agents") {
    return (
      <div className="flex min-h-screen bg-[#F8F9FA] text-[#1B1E28]">
        {/* Sidebar */}
        <aside className="hidden lg:flex flex-col w-80 bg-white border-r border-gray-100 p-10 space-y-12 shrink-0">
          <div className="flex items-center space-x-4">
            <Image src="/logo.png" alt="Logo" width={50} height={50} className="object-contain" />
            <span className="text-2xl font-black uppercase tracking-widest">ADMIN</span>
          </div>

          <nav className="flex-1 space-y-4">
            {[
              { name: 'Dashboard', icon: '🏠', section: 'dashboard' },
              { name: 'Agents', icon: '👤', section: 'agents' },
              { name: 'Complaints', icon: '⚠️', section: 'complaints' },
              { name: 'System Logs', icon: '📝', section: 'logs' },
              { name: 'Analytics', icon: '📊', section: 'analytics' }
            ].map((item) => (
              <div
                key={item.name}
                onClick={() => handleNavClick(item.section)}
                className={`flex items-center space-x-4 p-4 rounded-xl cursor-pointer transition-all group ${
                  view === `admin-${item.section}`
                    ? 'bg-[#007AFF] text-white shadow-lg'
                    : 'hover:bg-blue-50 hover:text-[#007AFF]'
                }`}
              >
                <span className="text-xl">{item.icon}</span>
                <span className="text-lg font-bold">{item.name}</span>
              </div>
            ))}
          </nav>

          <button
            onClick={handleLogout}
            className="w-full py-4 border-2 border-red-50 text-red-500 rounded-2xl font-bold hover:bg-red-50 transition-all flex items-center justify-center space-x-2"
          >
            <span>Log out</span>
          </button>
        </aside>

        {/* Main Content */}
        <main className="flex-1 flex flex-col p-8 sm:p-12 space-y-12 overflow-y-auto">
          <header className="flex items-center justify-between">
            <div className="space-y-1">
              <h1 className="text-4xl font-black">All Agents</h1>
              <p className="text-[#7D848D] text-lg font-medium">Complete agent management and overview</p>
            </div>
            <div className="flex items-center space-x-6">
              <div className="flex items-center space-x-4 bg-white p-2 pr-6 rounded-2xl shadow-sm border border-gray-50">
                <div className="w-12 h-12 bg-[#FF6B35] rounded-xl flex items-center justify-center text-white font-bold">A</div>
                <span className="font-bold text-gray-700">Administrator</span>
              </div>
            </div>
          </header>

          {/* Stats Cards */}
          <div className="grid grid-cols-1 md:grid-cols-4 gap-8">
            {[
              { label: 'Total Agents', value: allAgents.length, color: 'blue' },
              { label: 'Approved', value: allAgents.filter(a => a.status === 'APPROVED').length, color: 'green' },
              { label: 'Pending', value: allAgents.filter(a => a.status === 'PENDING_APPROVAL').length, color: 'yellow' },
              { label: 'Rejected', value: allAgents.filter(a => a.status === 'REJECTED').length, color: 'red' }
            ].map((stat, i) => (
              <div key={i} className="bg-white p-8 rounded-[32px] shadow-sm border border-gray-50 flex flex-col justify-between hover:shadow-md transition-all">
                <p className="text-[#7D848D] font-bold uppercase tracking-widest text-xs">{stat.label}</p>
                <h3 className="text-4xl font-black mt-2">{stat.value}</h3>
              </div>
            ))}
          </div>

          {/* Agents Table */}
          <div className="bg-white rounded-[40px] shadow-sm border border-gray-50 overflow-hidden">
            <div className="p-10 border-b border-gray-50 flex items-center justify-between bg-gray-50/30">
              <h2 className="text-2xl font-black">Agent Directory</h2>
              <div className="bg-[#007AFF]/10 text-[#007AFF] px-6 py-2 rounded-full font-bold text-sm">
                {allAgents.length} Total Agents
              </div>
            </div>

            {isLoading && (
              <div className="p-10 text-center">
                <p className="text-gray-500 font-medium">Loading agents...</p>
              </div>
            )}

            {error && !isLoading && (
              <div className="p-10 text-center bg-red-50 border-t border-red-100">
                <p className="text-red-600 font-medium">⚠️ {error}</p>
              </div>
            )}

            {!isLoading && (
              <div className="overflow-x-auto">
                <table className="w-full text-left border-collapse">
                  <thead>
                    <tr className="bg-gray-50/50">
                      <th className="px-10 py-6 text-[#7D848D] font-bold uppercase tracking-widest text-xs">Agent Info</th>
                      <th className="px-10 py-6 text-[#7D848D] font-bold uppercase tracking-widest text-xs">Business</th>
                      <th className="px-10 py-6 text-[#7D848D] font-bold uppercase tracking-widest text-xs">Contact</th>
                      <th className="px-10 py-6 text-[#7D848D] font-bold uppercase tracking-widest text-xs">Status</th>
                      <th className="px-10 py-6 text-[#7D848D] font-bold uppercase tracking-widest text-xs">Joined</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-gray-50">
                    {allAgents.length === 0 ? (
                      <tr>
                        <td colSpan={5} className="px-10 py-20 text-center text-gray-400 font-medium">
                          No agents found in the system
                        </td>
                      </tr>
                    ) : (
                      allAgents.map((agent) => (
                        <tr key={agent._id} className="hover:bg-gray-50/30 transition-colors">
                          <td className="px-10 py-8">
                            <div className="flex flex-col">
                              <span className="font-bold text-lg">{agent.fullName || agent.name || 'N/A'}</span>
                              <span className="text-[#7D848D] text-sm">{agent.email}</span>
                            </div>
                          </td>
                          <td className="px-10 py-8">
                            <div className="flex flex-col">
                              <span className="font-medium">{agent.businessName || 'N/A'}</span>
                              <span className="text-[#7D848D] text-xs mt-1">CNIC: {agent.cnic || 'N/A'}</span>
                            </div>
                          </td>
                          <td className="px-10 py-8">
                            <span className="text-[#7D848D]">{agent.phone || 'N/A'}</span>
                          </td>
                          <td className="px-10 py-8">
                            <span className={`inline-flex items-center px-4 py-1.5 rounded-full text-xs font-black uppercase tracking-tighter ${
                              agent.status === 'APPROVED'
                                ? 'bg-green-100 text-green-600'
                                : agent.status === 'REJECTED'
                                ? 'bg-red-100 text-red-600'
                                : 'bg-yellow-100 text-yellow-600'
                              }`}>
                              {agent.status || 'PENDING_APPROVAL'}
                            </span>
                          </td>
                          <td className="px-10 py-8">
                            <span className="text-[#7D848D] text-sm">
                              {agent.createdAt ? new Date(agent.createdAt).toLocaleDateString() : 'N/A'}
                            </span>
                          </td>
                        </tr>
                      ))
                    )}
                  </tbody>
                </table>
              </div>
            )}
          </div>
        </main>
      </div>
    );
  }

  // Admin Complaints View
  if (view === "admin-complaints") {
    return (
      <div className="flex min-h-screen bg-[#F8F9FA] text-[#1B1E28]">
        {/* Sidebar */}
        <aside className="hidden lg:flex flex-col w-80 bg-white border-r border-gray-100 p-10 space-y-12 shrink-0">
          <div className="flex items-center space-x-4">
            <Image src="/logo.png" alt="Logo" width={50} height={50} className="object-contain" />
            <span className="text-2xl font-black uppercase tracking-widest">ADMIN</span>
          </div>

          <nav className="flex-1 space-y-4">
            {[
              { name: 'Dashboard', icon: '🏠', section: 'dashboard' },
              { name: 'Agents', icon: '👤', section: 'agents' },
              { name: 'Complaints', icon: '⚠️', section: 'complaints' },
              { name: 'System Logs', icon: '📝', section: 'logs' },
              { name: 'Analytics', icon: '📊', section: 'analytics' }
            ].map((item) => (
              <div
                key={item.name}
                onClick={() => handleNavClick(item.section)}
                className={`flex items-center space-x-4 p-4 rounded-xl cursor-pointer transition-all group ${
                  view === `admin-${item.section}`
                    ? 'bg-[#007AFF] text-white shadow-lg'
                    : 'hover:bg-blue-50 hover:text-[#007AFF]'
                }`}
              >
                <span className="text-xl">{item.icon}</span>
                <span className="text-lg font-bold">{item.name}</span>
              </div>
            ))}
          </nav>

          <button
            onClick={handleLogout}
            className="w-full py-4 border-2 border-red-50 text-red-500 rounded-2xl font-bold hover:bg-red-50 transition-all flex items-center justify-center space-x-2"
          >
            <span>Log out</span>
          </button>
        </aside>

        {/* Main Content */}
        <main className="flex-1 flex flex-col p-8 sm:p-12 space-y-12 overflow-y-auto">
          <header className="flex items-center justify-between">
            <div className="space-y-1">
              <h1 className="text-4xl font-black">Complaints Management</h1>
              <p className="text-[#7D848D] text-lg font-medium">Handle customer complaints and agent issues</p>
            </div>
            <div className="flex items-center space-x-6">
              <div className="flex items-center space-x-4 bg-white p-2 pr-6 rounded-2xl shadow-sm border border-gray-50">
                <div className="w-12 h-12 bg-[#FF6B35] rounded-xl flex items-center justify-center text-white font-bold">A</div>
                <span className="font-bold text-gray-700">Administrator</span>
              </div>
            </div>
          </header>

          {/* Stats Cards */}
          <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
            {[
              { label: 'Total Complaints', value: complaints.length, color: 'red' },
              { label: 'Open', value: complaints.filter(c => c.status === 'OPEN').length, color: 'orange' },
              { label: 'Resolved', value: complaints.filter(c => c.status === 'RESOLVED').length, color: 'green' }
            ].map((stat, i) => (
              <div key={i} className="bg-white p-8 rounded-[32px] shadow-sm border border-gray-50 flex flex-col justify-between hover:shadow-md transition-all">
                <p className="text-[#7D848D] font-bold uppercase tracking-widest text-xs">{stat.label}</p>
                <h3 className="text-4xl font-black mt-2">{stat.value}</h3>
              </div>
            ))}
          </div>

          {/* Complaints Table */}
          <div className="bg-white rounded-[40px] shadow-sm border border-gray-50 overflow-hidden">
            <div className="p-10 border-b border-gray-50 flex items-center justify-between bg-gray-50/30">
              <h2 className="text-2xl font-black">Customer Complaints</h2>
              <div className="bg-red-100 text-red-600 px-6 py-2 rounded-full font-bold text-sm">
                {complaints.filter(c => c.status === 'OPEN').length} Open Issues
              </div>
            </div>

            {isLoading && (
              <div className="p-10 text-center">
                <p className="text-gray-500 font-medium">Loading complaints...</p>
              </div>
            )}

            {error && !isLoading && (
              <div className="p-10 text-center bg-red-50 border-t border-red-100">
                <p className="text-red-600 font-medium">⚠️ {error}</p>
              </div>
            )}

            {!isLoading && (
              <div className="overflow-x-auto">
                <table className="w-full text-left border-collapse">
                  <thead>
                    <tr className="bg-gray-50/50">
                      <th className="px-10 py-6 text-[#7D848D] font-bold uppercase tracking-widest text-xs">Complaint</th>
                      <th className="px-10 py-6 text-[#7D848D] font-bold uppercase tracking-widest text-xs">Customer</th>
                      <th className="px-10 py-6 text-[#7D848D] font-bold uppercase tracking-widest text-xs">Agent</th>
                      <th className="px-10 py-6 text-[#7D848D] font-bold uppercase tracking-widest text-xs">Status</th>
                      <th className="px-10 py-6 text-[#7D848D] font-bold uppercase tracking-widest text-xs">Date</th>
                      <th className="px-10 py-6 text-[#7D848D] font-bold uppercase tracking-widest text-xs">Actions</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-gray-50">
                    {complaints.length === 0 ? (
                      <tr>
                        <td colSpan={6} className="px-10 py-20 text-center text-gray-400 font-medium">
                          ✓ No complaints found. All customer issues have been resolved!
                        </td>
                      </tr>
                    ) : (
                      complaints.map((complaint) => (
                        <tr key={complaint._id} className="hover:bg-gray-50/30 transition-colors">
                          <td className="px-10 py-8">
                            <div className="flex flex-col">
                              <span className="font-bold text-lg">{complaint.subject}</span>
                              <span className="text-[#7D848D] text-sm line-clamp-2">{complaint.description}</span>
                            </div>
                          </td>
                          <td className="px-10 py-8">
                            <span className="text-[#7D848D]">{complaint.userId?.fullName || 'N/A'}</span>
                          </td>
                          <td className="px-10 py-8">
                            <span className="text-[#7D848D]">{complaint.agentId?.fullName || 'N/A'}</span>
                          </td>
                          <td className="px-10 py-8">
                            <span className={`inline-flex items-center px-4 py-1.5 rounded-full text-xs font-black uppercase tracking-tighter ${
                              complaint.status === 'RESOLVED'
                                ? 'bg-green-100 text-green-600'
                                : complaint.status === 'IN_PROGRESS'
                                ? 'bg-blue-100 text-blue-600'
                                : 'bg-red-100 text-red-600'
                              }`}>
                              {complaint.status || 'OPEN'}
                            </span>
                          </td>
                          <td className="px-10 py-8">
                            <span className="text-[#7D848D] text-sm">
                              {complaint.createdAt ? new Date(complaint.createdAt).toLocaleDateString() : 'N/A'}
                            </span>
                          </td>
                          <td className="px-10 py-8">
                            {complaint.status !== 'RESOLVED' && (
                              <button className="px-6 py-3 bg-[#007AFF] text-white rounded-xl font-bold text-sm hover:shadow-lg hover:shadow-blue-200 transition-all">
                                Respond
                              </button>
                            )}
                            {complaint.status === 'RESOLVED' && (
                              <button className="px-6 py-3 border border-green-200 text-green-600 rounded-xl font-bold text-sm hover:bg-green-50 transition-all">
                                ✓ Resolved
                              </button>
                            )}
                          </td>
                        </tr>
                      ))
                    )}
                  </tbody>
                </table>
              </div>
            )}
          </div>
        </main>
      </div>
    );
  }

  // Admin System Logs View
  if (view === "admin-logs") {
    return (
      <div className="flex min-h-screen bg-[#F8F9FA] text-[#1B1E28]">
        {/* Sidebar */}
        <aside className="hidden lg:flex flex-col w-80 bg-white border-r border-gray-100 p-10 space-y-12 shrink-0">
          <div className="flex items-center space-x-4">
            <Image src="/logo.png" alt="Logo" width={50} height={50} className="object-contain" />
            <span className="text-2xl font-black uppercase tracking-widest">ADMIN</span>
          </div>

          <nav className="flex-1 space-y-4">
            {[
              { name: 'Dashboard', icon: '🏠', section: 'dashboard' },
              { name: 'Agents', icon: '👤', section: 'agents' },
              { name: 'Complaints', icon: '⚠️', section: 'complaints' },
              { name: 'System Logs', icon: '📝', section: 'logs' },
              { name: 'Analytics', icon: '📊', section: 'analytics' }
            ].map((item) => (
              <div
                key={item.name}
                onClick={() => handleNavClick(item.section)}
                className={`flex items-center space-x-4 p-4 rounded-xl cursor-pointer transition-all group ${
                  view === `admin-${item.section}`
                    ? 'bg-[#007AFF] text-white shadow-lg'
                    : 'hover:bg-blue-50 hover:text-[#007AFF]'
                }`}
              >
                <span className="text-xl">{item.icon}</span>
                <span className="text-lg font-bold">{item.name}</span>
              </div>
            ))}
          </nav>

          <button
            onClick={handleLogout}
            className="w-full py-4 border-2 border-red-50 text-red-500 rounded-2xl font-bold hover:bg-red-50 transition-all flex items-center justify-center space-x-2"
          >
            <span>Log out</span>
          </button>
        </aside>

        {/* Main Content */}
        <main className="flex-1 flex flex-col p-8 sm:p-12 space-y-12 overflow-y-auto">
          <header className="flex items-center justify-between">
            <div className="space-y-1">
              <h1 className="text-4xl font-black">System Logs</h1>
              <p className="text-[#7D848D] text-lg font-medium">Monitor system activity and security events</p>
            </div>
            <div className="flex items-center space-x-6">
              <div className="flex items-center space-x-4 bg-white p-2 pr-6 rounded-2xl shadow-sm border border-gray-50">
                <div className="w-12 h-12 bg-[#FF6B35] rounded-xl flex items-center justify-center text-white font-bold">A</div>
                <span className="font-bold text-gray-700">Administrator</span>
              </div>
            </div>
          </header>

          {/* Stats Cards */}
          <div className="grid grid-cols-1 md:grid-cols-4 gap-8">
            {[
              { label: 'Total Logs', value: systemLogs.length, color: 'blue' },
              { label: 'Errors', value: systemLogs.filter(l => l.level === 'ERROR').length, color: 'red' },
              { label: 'Warnings', value: systemLogs.filter(l => l.level === 'WARN').length, color: 'yellow' },
              { label: 'Info', value: systemLogs.filter(l => l.level === 'INFO').length, color: 'green' }
            ].map((stat, i) => (
              <div key={i} className="bg-white p-8 rounded-[32px] shadow-sm border border-gray-50 flex flex-col justify-between hover:shadow-md transition-all">
                <p className="text-[#7D848D] font-bold uppercase tracking-widest text-xs">{stat.label}</p>
                <h3 className="text-4xl font-black mt-2">{stat.value}</h3>
              </div>
            ))}
          </div>

          {/* Logs Table */}
          <div className="bg-white rounded-[40px] shadow-sm border border-gray-50 overflow-hidden">
            <div className="p-10 border-b border-gray-50 flex items-center justify-between bg-gray-50/30">
              <h2 className="text-2xl font-black">System Activity Logs</h2>
              <div className="bg-gray-100 text-gray-600 px-6 py-2 rounded-full font-bold text-sm">
                Real-time Monitoring
              </div>
            </div>

            {isLoading && (
              <div className="p-10 text-center">
                <p className="text-gray-500 font-medium">Loading system logs...</p>
              </div>
            )}

            {error && !isLoading && (
              <div className="p-10 text-center bg-red-50 border-t border-red-100">
                <p className="text-red-600 font-medium">⚠️ {error}</p>
              </div>
            )}

            {!isLoading && (
              <div className="overflow-x-auto">
                <table className="w-full text-left border-collapse">
                  <thead>
                    <tr className="bg-gray-50/50">
                      <th className="px-10 py-6 text-[#7D848D] font-bold uppercase tracking-widest text-xs">Timestamp</th>
                      <th className="px-10 py-6 text-[#7D848D] font-bold uppercase tracking-widest text-xs">Level</th>
                      <th className="px-10 py-6 text-[#7D848D] font-bold uppercase tracking-widest text-xs">Event</th>
                      <th className="px-10 py-6 text-[#7D848D] font-bold uppercase tracking-widest text-xs">Details</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-gray-50">
                    {systemLogs.length === 0 ? (
                      <tr>
                        <td colSpan={4} className="px-10 py-20 text-center text-gray-400 font-medium">
                          No system logs available. System is running smoothly!
                        </td>
                      </tr>
                    ) : (
                      systemLogs.map((log, index) => (
                        <tr key={index} className="hover:bg-gray-50/30 transition-colors">
                          <td className="px-10 py-8">
                            <span className="text-[#7D848D] text-sm font-mono">
                              {log.timestamp || new Date().toLocaleString()}
                            </span>
                          </td>
                          <td className="px-10 py-8">
                            <span className={`inline-flex items-center px-3 py-1 rounded-full text-xs font-black uppercase tracking-tighter ${
                              log.level === 'ERROR'
                                ? 'bg-red-100 text-red-600'
                                : log.level === 'WARN'
                                ? 'bg-yellow-100 text-yellow-600'
                                : log.level === 'INFO'
                                ? 'bg-blue-100 text-blue-600'
                                : 'bg-gray-100 text-gray-600'
                              }`}>
                              {log.level || 'INFO'}
                            </span>
                          </td>
                          <td className="px-10 py-8">
                            <span className="font-medium">{log.event || log.message || 'System Event'}</span>
                          </td>
                          <td className="px-10 py-8">
                            <span className="text-[#7D848D] text-sm">{log.details || log.data || 'No additional details'}</span>
                          </td>
                        </tr>
                      ))
                    )}
                  </tbody>
                </table>
              </div>
            )}
          </div>
        </main>
      </div>
    );
  }

  // Admin Analytics View
  if (view === "admin-analytics") {
    return (
      <div className="flex min-h-screen bg-[#F8F9FA] text-[#1B1E28]">
        {/* Sidebar */}
        <aside className="hidden lg:flex flex-col w-80 bg-white border-r border-gray-100 p-10 space-y-12 shrink-0">
          <div className="flex items-center space-x-4">
            <Image src="/logo.png" alt="Logo" width={50} height={50} className="object-contain" />
            <span className="text-2xl font-black uppercase tracking-widest">ADMIN</span>
          </div>

          <nav className="flex-1 space-y-4">
            {[
              { name: 'Dashboard', icon: '🏠', section: 'dashboard' },
              { name: 'Agents', icon: '👤', section: 'agents' },
              { name: 'Complaints', icon: '⚠️', section: 'complaints' },
              { name: 'System Logs', icon: '📝', section: 'logs' },
              { name: 'Analytics', icon: '📊', section: 'analytics' }
            ].map((item) => (
              <div
                key={item.name}
                onClick={() => handleNavClick(item.section)}
                className={`flex items-center space-x-4 p-4 rounded-xl cursor-pointer transition-all group ${
                  view === `admin-${item.section}`
                    ? 'bg-[#007AFF] text-white shadow-lg'
                    : 'hover:bg-blue-50 hover:text-[#007AFF]'
                }`}
              >
                <span className="text-xl">{item.icon}</span>
                <span className="text-lg font-bold">{item.name}</span>
              </div>
            ))}
          </nav>

          <button
            onClick={handleLogout}
            className="w-full py-4 border-2 border-red-50 text-red-500 rounded-2xl font-bold hover:bg-red-50 transition-all flex items-center justify-center space-x-2"
          >
            <span>Log out</span>
          </button>
        </aside>

        {/* Main Content */}
        <main className="flex-1 flex flex-col p-8 sm:p-12 space-y-12 overflow-y-auto">
          <header className="flex items-center justify-between">
            <div className="space-y-1">
              <h1 className="text-4xl font-black">System Analytics</h1>
              <p className="text-[#7D848D] text-lg font-medium">Comprehensive platform insights and metrics</p>
            </div>
            <div className="flex items-center space-x-6">
              <div className="flex items-center space-x-4 bg-white p-2 pr-6 rounded-2xl shadow-sm border border-gray-50">
                <div className="w-12 h-12 bg-[#FF6B35] rounded-xl flex items-center justify-center text-white font-bold">A</div>
                <span className="font-bold text-gray-700">Administrator</span>
              </div>
            </div>
          </header>

          {/* Analytics Cards */}
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-8">
            {[
              { label: 'Total Users', value: analytics.totalUsers || 0, color: 'blue', icon: '👥' },
              { label: 'Total Agents', value: analytics.totalAgents || 0, color: 'orange', icon: '👤' },
              { label: 'Total Bookings', value: analytics.totalBookings || 0, color: 'green', icon: '📅' },
              { label: 'Complaints', value: analytics.totalComplaints || 0, color: 'red', icon: '⚠️' }
            ].map((metric, i) => (
              <div key={i} className="bg-white p-8 rounded-[32px] shadow-sm border border-gray-50 flex flex-col justify-between hover:shadow-md transition-all">
                <div className="flex items-center justify-between">
                  <p className="text-[#7D848D] font-bold uppercase tracking-widest text-xs">{metric.label}</p>
                  <span className="text-2xl">{metric.icon}</span>
                </div>
                <h3 className="text-4xl font-black mt-4">{metric.value}</h3>
              </div>
            ))}
          </div>

          {/* Agent Status Breakdown */}
          <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
            <div className="bg-white p-10 rounded-[40px] shadow-sm border border-gray-50">
              <h3 className="text-2xl font-black mb-8">Agent Status Distribution</h3>
              <div className="space-y-6">
                {[
                  { status: 'Approved', count: analytics.approvedAgents || 0, color: 'green' },
                  { status: 'Pending', count: analytics.pendingAgents || 0, color: 'yellow' },
                  { status: 'Rejected', count: analytics.rejectedAgents || 0, color: 'red' }
                ].map((item, i) => (
                  <div key={i} className="flex items-center justify-between">
                    <div className="flex items-center space-x-4">
                      <div className={`w-4 h-4 rounded-full ${
                        item.color === 'green' ? 'bg-green-500' :
                        item.color === 'yellow' ? 'bg-yellow-500' : 'bg-red-500'
                      }`}></div>
                      <span className="font-bold">{item.status}</span>
                    </div>
                    <span className="text-2xl font-black">{item.count}</span>
                  </div>
                ))}
              </div>
            </div>

            <div className="bg-white p-10 rounded-[40px] shadow-sm border border-gray-50">
              <h3 className="text-2xl font-black mb-8">Platform Health</h3>
              <div className="space-y-6">
                <div className="flex items-center justify-between">
                  <span className="font-bold">System Uptime</span>
                  <span className="text-green-600 font-black">99.9%</span>
                </div>
                <div className="flex items-center justify-between">
                  <span className="font-bold">Active Sessions</span>
                  <span className="text-blue-600 font-black">{analytics.totalUsers || 0}</span>
                </div>
                <div className="flex items-center justify-between">
                  <span className="font-bold">Response Time</span>
                  <span className="text-purple-600 font-black">&lt; 200ms</span>
                </div>
                <div className="flex items-center justify-between">
                  <span className="font-bold">Error Rate</span>
                  <span className="text-red-600 font-black">0.1%</span>
                </div>
              </div>
            </div>
          </div>

          {/* Recent Activity */}
          <div className="bg-white rounded-[40px] shadow-sm border border-gray-50 overflow-hidden">
            <div className="p-10 border-b border-gray-50 bg-gray-50/30">
              <h2 className="text-2xl font-black">Recent Activity Summary</h2>
            </div>
            <div className="p-10">
              <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
                <div className="text-center">
                  <div className="text-4xl font-black text-blue-600 mb-2">{analytics.totalBookings || 0}</div>
                  <div className="text-[#7D848D] font-bold uppercase tracking-widest text-xs">Bookings This Month</div>
                </div>
                <div className="text-center">
                  <div className="text-4xl font-black text-green-600 mb-2">{analytics.approvedAgents || 0}</div>
                  <div className="text-[#7D848D] font-bold uppercase tracking-widest text-xs">Agents Approved</div>
                </div>
                <div className="text-center">
                  <div className="text-4xl font-black text-orange-600 mb-2">{analytics.totalComplaints || 0}</div>
                  <div className="text-[#7D848D] font-bold uppercase tracking-widest text-xs">Issues Resolved</div>
                </div>
              </div>
            </div>
          </div>
        </main>
      </div>
    );
  }

  // Regular View (Main View - Travel Agent Portal) - Keeping it as a fallback
  return (
    <div className="flex min-h-screen items-center justify-center p-12 bg-gray-50">
      <div className="text-center space-y-4">
        <h1 className="text-4xl font-black">Agent View Not Loaded</h1>
        <p>You are viewing the common workspace. Sign in as Admin to see controls.</p>
        <button onClick={() => setView("signin")} className="px-8 py-4 bg-[#007AFF] text-white rounded-2xl font-bold">Go To Admin Login</button>
      </div>
    </div>
  );
}
