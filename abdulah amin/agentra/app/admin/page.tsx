'use client';

import { useEffect, useState, useCallback } from 'react';
import { adminService } from '@/lib/api';

interface Agent {
  _id: string;
  fullName?: string;
  name?: string;
  email: string;
  phone?: string;
  businessName?: string;
  cnic?: string;
  status: string;
}

interface Stats {
  totalBookings: number;
  pendingRefunds: number;
  newAgents: number;
  totalComplaints: number;
}

export default function AdminDashboard() {
  const [agents, setAgents] = useState<Agent[]>([]);
  const [stats, setStats] = useState<Stats>({
    totalBookings: 0,
    pendingRefunds: 0,
    newAgents: 0,
    totalComplaints: 0,
  });
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const loadDashboardData = useCallback(async () => {
    try {
      setIsLoading(true);
      setError(null);
      
      const [agentsData, analyticsData] = await Promise.all([
        adminService.getAgents(),
        adminService.getAnalytics()
      ]);

      const agentsList = Array.isArray(agentsData) ? agentsData : (agentsData?.agents || []);
      setAgents(agentsList);

      if (analyticsData) {
        setStats({
          totalBookings: analyticsData.totalBookings || 0,
          pendingRefunds: analyticsData.pendingRefunds || 0,
          newAgents: analyticsData.newAgents || 0,
          totalComplaints: analyticsData.totalComplaints || 0,
        });
      }
    } catch (err: any) {
      console.error('❌ Dashboard Sync Error:', err);
      setError(err.message || 'Unable to sync with live data');
    } finally {
      setIsLoading(false);
    }
  }, []);

  useEffect(() => {
    loadDashboardData();
  }, [loadDashboardData]);

  const handleApproveAgent = async (id: string, agentName: string) => {
    if (!confirm(`Are you sure you want to approve ${agentName}?`)) return;
    try {
      await adminService.approveAgent(id);
      await loadDashboardData();
    } catch (err: any) {
      alert(`Approval failed: ${err.message}`);
    }
  };

  const handleRejectAgent = async (id: string, agentName: string) => {
    const reason = prompt(`Please provide a reason for rejecting ${agentName}:`);
    if (reason === null) return;
    try {
      await adminService.rejectAgent(id, reason);
      await loadDashboardData();
    } catch (err: any) {
      alert(`Rejection failed: ${err.message}`);
    }
  };

  const pendingCount = agents.filter(a => a.status === 'PENDING_APPROVAL').length;

  return (
    <div className="min-h-screen bg-[#F8F9FB] p-8 space-y-10">
      {/* Header Section */}
      <div className="flex justify-between items-end">
        <div className="space-y-2">
          <h1 className="text-5xl font-black text-[#1B1E28] tracking-tight">System Overview</h1>
          <p className="text-[#7D848D] text-xl font-medium">Real-time platform metrics and verification</p>
        </div>
        <button 
          onClick={loadDashboardData}
          className="px-6 py-3 bg-white text-[#1B1E28] font-bold rounded-2xl shadow-sm border border-gray-100 hover:bg-gray-50 transition-all active:scale-95"
        >
          Refresh Data
        </button>
      </div>

      {/* Analytics Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-8">
        {[
          { label: 'Total Bookings', value: stats.totalBookings, color: 'bg-blue-500' },
          { label: 'Pending Refunds', value: stats.pendingRefunds, color: 'bg-orange-500' },
          { label: 'New Agents (Month)', value: stats.newAgents, color: 'bg-emerald-500' },
          { label: 'Total Complaints', value: stats.totalComplaints, color: 'bg-rose-500' }
        ].map((stat) => (
          <div key={stat.label} className="bg-white p-8 rounded-[32px] shadow-[0_8px_30px_rgb(0,0,0,0.04)] border border-gray-50 flex flex-col justify-between hover:translate-y-[-4px] transition-all duration-300">
            <div className="space-y-4">
              <div className={`w-2 h-8 rounded-full ${stat.color} mb-4 opacity-20`} />
              <p className="text-[#7D848D] font-bold uppercase tracking-[0.2em] text-[10px]">{stat.label}</p>
              <h3 className="text-5xl font-black text-[#1B1E28]">{stat.value.toLocaleString()}</h3>
            </div>
          </div>
        ))}
      </div>

      {/* Main Content Area */}
      <div className="bg-white rounded-[48px] shadow-[0_20px_50px_rgba(0,0,0,0.02)] border border-gray-100 overflow-hidden">
        <div className="p-12 border-b border-gray-50 flex items-center justify-between">
          <div className="flex items-center gap-6">
            <h2 className="text-3xl font-black text-[#1B1E28]">Verification Queue</h2>
            <div className="bg-[#007AFF]/10 text-[#007AFF] px-6 py-2 rounded-2xl font-black text-sm uppercase tracking-tighter">
              {pendingCount} Pending Requests
            </div>
          </div>
        </div>

        <div className="p-2">
          {isLoading ? (
            <div className="py-32 text-center space-y-6">
              <div className="w-16 h-16 border-4 border-[#007AFF]/10 border-t-[#007AFF] rounded-full animate-spin mx-auto" />
              <p className="text-[#7D848D] font-bold text-lg animate-pulse">Synchronizing with system...</p>
            </div>
          ) : error ? (
            <div className="py-32 text-center px-12 space-y-6">
              <div className="bg-rose-50 w-24 h-24 rounded-full flex items-center justify-center mx-auto text-rose-500 text-4xl">⚠️</div>
              <div className="space-y-2">
                <h3 className="text-2xl font-black text-rose-600">Connection Failed</h3>
                <p className="text-rose-400 font-medium">{error}</p>
              </div>
              <button 
                onClick={loadDashboardData}
                className="px-10 py-4 bg-rose-600 text-white rounded-2xl font-black hover:bg-rose-700 transition-all shadow-lg shadow-rose-200"
              >
                Retry Connection
              </button>
            </div>
          ) : (
            <div className="space-y-8">
              <div className="bg-white rounded-[40px] shadow-2xl shadow-gray-200/50 border border-gray-100/50 overflow-hidden">
                <div className="p-12 border-b border-gray-50 flex items-center justify-between">
                  <div className="flex items-center gap-4">
                    <h2 className="text-2xl font-black text-[#1B1E28]">Verification Queue</h2>
                    <span className="bg-orange-500 text-white px-4 py-1 rounded-full text-sm font-bold">
                      {agents.filter(a => a.status === 'PENDING_APPROVAL').length} Pending
                    </span>
                  </div>
                </div>
                
                <div className="overflow-x-auto">
                  <table className="w-full text-left border-collapse">
                    <thead>
                      <tr className="bg-gray-50/30">
                        <th className="px-12 py-8 text-[#7D848D] font-bold uppercase tracking-widest text-xs">Agent Entity</th>
                        <th className="px-12 py-8 text-[#7D848D] font-bold uppercase tracking-widest text-xs">Credential Info</th>
                        <th className="px-12 py-8 text-[#7D848D] font-bold uppercase tracking-widest text-xs text-center">Status</th>
                        <th className="px-12 py-8 text-[#7D848D] font-bold uppercase tracking-widest text-xs text-right">Actions</th>
                      </tr>
                    </thead>
                    <tbody className="divide-y divide-gray-50">
                      {agents.filter(a => a.status === 'PENDING_APPROVAL').length === 0 ? (
                        <tr>
                          <td colSpan={4} className="px-12 py-32 text-center">
                            <div className="flex flex-col items-center gap-4">
                              <div className="w-20 h-20 bg-green-50 rounded-full flex items-center justify-center">
                                <svg className="w-10 h-10 text-green-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="3" d="M5 13l4 4L19 7"></path>
                                </svg>
                              </div>
                              <p className="font-black text-2xl text-[#1B1E28]">All requests processed!</p>
                              <p className="text-[#7D848D] font-medium">There are no pending agent verifications.</p>
                            </div>
                          </td>
                        </tr>
                      ) : (
                        agents.filter(a => a.status === 'PENDING_APPROVAL').map((agent) => (
                          <tr key={agent._id} className="hover:bg-gray-50/50 transition-all group">
                            <td className="px-12 py-10">
                              <div className="flex items-center gap-6">
                                <div className="w-16 h-16 rounded-3xl bg-[#F7F7F9] flex items-center justify-center font-black text-xl text-[#007AFF] shadow-inner">
                                  {agent.fullName?.[0] || agent.name?.[0] || 'A'}
                                </div>
                                <div className="flex flex-col gap-1">
                                  <p className="font-black text-xl text-[#1B1E28]">{agent.fullName || agent.name || 'Untitled Agent'}</p>
                                  <p className="text-[#7D848D] font-bold text-sm">{agent.email}</p>
                                </div>
                              </div>
                            </td>
                            <td className="px-12 py-10">
                              <div className="flex flex-col gap-1">
                                <p className="font-bold text-[#1B1E28]">{agent.businessName || 'No Business Name'}</p>
                                <p className="text-[#7D848D] text-sm font-medium">{agent.phone || 'No Phone'}</p>
                              </div>
                            </td>
                            <td className="px-12 py-10 text-center">
                              <span className="inline-flex items-center px-6 py-2 rounded-2xl text-xs font-black uppercase tracking-tighter border bg-orange-50 text-orange-600 border-orange-100">
                                PENDING
                              </span>
                            </td>
                            <td className="px-12 py-10 text-right">
                              <div className="flex justify-end gap-4 transition-all">
                                <button
                                  onClick={() => handleApproveAgent(agent._id, agent.fullName || agent.name || 'Agent')}
                                  className="px-6 py-3 bg-[#007AFF] text-white rounded-2xl font-black text-xs hover:shadow-xl hover:shadow-blue-200 transition-all active:scale-95"
                                >
                                  Approve
                                </button>
                                <button
                                  onClick={() => handleRejectAgent(agent._id, agent.fullName || agent.name || 'Agent')}
                                  className="px-6 py-3 bg-white text-rose-600 border border-rose-100 rounded-2xl font-black text-xs hover:bg-rose-50 transition-all active:scale-95"
                                >
                                  Reject
                                </button>
                              </div>
                            </td>
                          </tr>
                        ))
                      )}
                    </tbody>
                  </table>
                </div>
              </div>

              {/* Processed Agents Section */}
              {agents.filter(a => a.status !== 'PENDING_APPROVAL').length > 0 && (
                <div className="bg-white rounded-[40px] shadow-2xl shadow-gray-200/50 border border-gray-100/50 overflow-hidden">
                  <div className="p-12 border-b border-gray-50 bg-gray-50/30 flex items-center justify-between">
                    <div className="flex items-center gap-4">
                      <h2 className="text-2xl font-black text-[#1B1E28]">Recently Processed</h2>
                      <span className="bg-[#007AFF] text-white px-4 py-1 rounded-full text-sm font-bold">
                        {agents.filter(a => a.status !== 'PENDING_APPROVAL').length}
                      </span>
                    </div>
                  </div>
                  <div className="overflow-x-auto">
                    <table className="w-full text-left border-collapse">
                      <thead>
                        <tr className="bg-gray-50/50">
                          <th className="px-12 py-6 text-[#7D848D] font-black uppercase tracking-widest text-[10px]">Agent Info</th>
                          <th className="px-12 py-6 text-[#7D848D] font-black uppercase tracking-widest text-[10px]">Status</th>
                          <th className="px-12 py-6 text-[#7D848D] font-black uppercase tracking-widest text-[10px] text-right">Date</th>
                        </tr>
                      </thead>
                      <tbody className="divide-y divide-gray-50">
                        {agents.filter(a => a.status !== 'PENDING_APPROVAL').map((agent) => (
                          <tr key={agent._id} className="hover:bg-gray-50/30 transition-all">
                            <td className="px-12 py-8">
                              <div className="flex items-center gap-4">
                                <div className="w-10 h-10 rounded-xl bg-gray-100 flex items-center justify-center font-bold text-gray-500">
                                  {agent.fullName?.[0] || agent.name?.[0] || 'A'}
                                </div>
                                <div>
                                  <p className="font-bold text-[#1B1E28]">{agent.fullName || agent.name}</p>
                                  <p className="text-[#7D848D] text-xs">{agent.email}</p>
                                </div>
                              </div>
                            </td>
                            <td className="px-12 py-8">
                              <span className={`inline-flex items-center px-4 py-1 rounded-full text-[10px] font-black uppercase tracking-tighter border ${
                                agent.status === 'APPROVED' 
                                  ? 'bg-green-50 text-green-600 border-green-100'
                                  : 'bg-rose-50 text-rose-600 border-rose-100'
                              }`}>
                                {agent.status}
                              </span>
                            </td>
                            <td className="px-12 py-8 text-right text-[#7D848D] text-xs font-medium">
                              {new Date(agent.updatedAt || agent.createdAt || '').toLocaleDateString()}
                            </td>
                          </tr>
                        ))}
                      </tbody>
                    </table>
                  </div>
                </div>
              )}
            </div>
          )}
        </div>
      </div>
    </div>
  );
}