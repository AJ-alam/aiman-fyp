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
            <div className="overflow-x-auto">
              <table className="w-full text-left">
                <thead>
                  <tr className="border-b border-gray-50">
                    <th className="px-12 py-8 text-[#7D848D] font-bold uppercase tracking-widest text-xs">Agent Entity</th>
                    <th className="px-12 py-8 text-[#7D848D] font-bold uppercase tracking-widest text-xs">Credential Info</th>
                    <th className="px-12 py-8 text-[#7D848D] font-bold uppercase tracking-widest text-xs text-center">Status</th>
                    <th className="px-12 py-8 text-[#7D848D] font-bold uppercase tracking-widest text-xs text-right">Actions</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-gray-50">
                  {agents.length === 0 ? (
                    <tr>
                      <td colSpan={4} className="py-40 text-center">
                        <div className="space-y-4">
                          <span className="text-6xl">✨</span>
                          <p className="text-[#7D848D] font-bold text-xl">All agents are verified!</p>
                        </div>
                      </td>
                    </tr>
                  ) : (
                    agents.map((agent) => (
                      <tr key={agent._id} className="hover:bg-gray-50/50 transition-all group">
                        <td className="px-12 py-10">
                          <div className="space-y-1">
                            <p className="font-black text-xl text-[#1B1E28]">{agent.fullName || agent.name || 'Untitled Agent'}</p>
                            <p className="text-[#7D848D] font-medium">{agent.email}</p>
                          </div>
                        </td>
                        <td className="px-12 py-10">
                          <div className="space-y-1">
                            <p className="font-bold text-[#1B1E28]">{agent.businessName || 'Independent'}</p>
                            <p className="text-[#7D848D] text-xs font-mono">CNIC: {agent.cnic || 'NOT_FOUND'}</p>
                          </div>
                        </td>
                        <td className="px-12 py-10 text-center">
                          <span className={`px-5 py-2 rounded-2xl text-[10px] font-black uppercase tracking-widest border ${
                            agent.status === 'APPROVED' 
                              ? 'bg-emerald-50 text-emerald-600 border-emerald-100' 
                              : agent.status === 'REJECTED'
                              ? 'bg-rose-50 text-rose-600 border-rose-100'
                              : 'bg-orange-50 text-orange-600 border-orange-100'
                          }`}>
                            {agent.status?.replace('_', ' ') || 'PENDING'}
                          </span>
                        </td>
                        <td className="px-12 py-10">
                          <div className="flex justify-end gap-4 opacity-0 group-hover:opacity-100 transition-all">
                            {agent.status === 'PENDING_APPROVAL' ? (
                              <>
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
                              </>
                            ) : (
                              <span className="text-[#7D848D] font-bold text-xs uppercase italic tracking-widest">Processed</span>
                            )}
                          </div>
                        </td>
                      </tr>
                    ))
                  )}
                </tbody>
              </table>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}