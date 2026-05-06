'use client';

import { useEffect, useState } from 'react';
import { adminService } from '@/lib/api';

export default function AdminDashboard() {
  const [agents, setAgents] = useState<any[]>([]);
  const [stats, setStats] = useState({
    totalUsers: 0,
    totalAgents: 0,
    totalBookings: 0,
    totalComplaints: 0,
  });
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState('');

  useEffect(() => {
    loadDashboardData();
  }, []);

  const loadDashboardData = async () => {
    try {
      setIsLoading(true);
      setError('');
      console.log('📊 Loading dashboard data...');

      // Fetch pending agents
      const agentsData = await adminService.getAgents();
      const agentsList = Array.isArray(agentsData) ? agentsData : (agentsData?.agents || []);
      setAgents(agentsList);
      console.log('✅ Pending agents loaded:', agentsList);

      // Fetch analytics
      const analyticsData = await adminService.getAnalytics();
      if (analyticsData) {
        setStats({
          totalUsers: analyticsData.totalUsers || 0,
          totalAgents: analyticsData.totalAgents || 0,
          totalBookings: analyticsData.totalBookings || 0,
          totalComplaints: analyticsData.totalComplaints || 0,
        });
        console.log('✅ Analytics loaded:', analyticsData);
      }
    } catch (err: any) {
      console.error('❌ Error loading dashboard:', err);
      setError(err.message || 'Failed to load dashboard data');
    } finally {
      setIsLoading(false);
    }
  };

  const handleApproveAgent = async (id: string, agentName: string) => {
    if (confirm(`Approve ${agentName}'s application?`)) {
      try {
        await adminService.approveAgent(id);
        alert(`${agentName} approved successfully!`);
        await loadDashboardData();
      } catch (err: any) {
        alert(`Error: ${err.message}`);
      }
    }
  };

  const handleRejectAgent = async (id: string, agentName: string) => {
    const reason = prompt(`Reason for rejecting ${agentName}?`);
    if (reason !== null) {
      try {
        await adminService.rejectAgent(id, reason);
        alert(`${agentName} rejected successfully!`);
        await loadDashboardData();
      } catch (err: any) {
        alert(`Error: ${err.message}`);
      }
    }
  };

  return (
    <div className="space-y-12">
      {/* Header */}
      <div className="space-y-1">
        <h1 className="text-4xl font-black">System Overview</h1>
        <p className="text-[#7D848D] text-lg font-medium">Agent verification and system statistics</p>
      </div>

      {/* Stats Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-8">
        {[
          { label: 'Total Users', value: stats.totalUsers, color: 'blue' },
          { label: 'Total Agents', value: stats.totalAgents, color: 'orange' },
          { label: 'Total Bookings', value: stats.totalBookings, color: 'green' },
          { label: 'Complaints', value: stats.totalComplaints, color: 'red' }
        ].map((stat, i) => (
          <div key={i} className="bg-white p-8 rounded-[32px] shadow-sm border border-gray-50 flex flex-col justify-between hover:shadow-md transition-all">
            <p className="text-[#7D848D] font-bold uppercase tracking-widest text-xs">{stat.label}</p>
            <h3 className="text-4xl font-black mt-2">{stat.value}</h3>
          </div>
        ))}
      </div>

      {/* Pending Agents Table */}
      <div className="bg-white rounded-[40px] shadow-sm border border-gray-50 overflow-hidden">
        <div className="p-10 border-b border-gray-50 flex items-center justify-between bg-gray-50/30">
          <h2 className="text-2xl font-black">Agent Verification Queue</h2>
          <div className="bg-[#007AFF]/10 text-[#007AFF] px-6 py-2 rounded-full font-bold text-sm">
            {agents.filter(a => a.status === 'PENDING_APPROVAL').length} Pending
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
                      ✓ No agents waiting for approval
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
                              className="px-6 py-3 bg-[#007AFF] text-white rounded-xl font-bold text-sm hover:shadow-lg hover:shadow-blue-200 transition-all active:scale-95"
                            >
                              Approve
                            </button>
                            <button
                              onClick={() => handleRejectAgent(agent._id, agent.fullName || agent.name)}
                              className="px-6 py-3 bg-red-50 text-red-600 rounded-xl font-bold text-sm hover:bg-red-100 transition-all active:scale-95"
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
    </div>
  );
}