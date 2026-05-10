'use client';

import { useEffect, useState } from 'react';
import { adminService } from '@/lib/api';

export default function AgentsPage() {
  const [agents, setAgents] = useState<any[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState('');

  useEffect(() => {
    loadAllAgents();
  }, []);

  const loadAllAgents = async () => {
    try {
      setIsLoading(true);
      setError('');
      console.log('📋 Loading all agents...');

      const data = await adminService.getAllAgents();
      const agentsList = Array.isArray(data) ? data : (data?.agents || []);
      setAgents(agentsList);
      console.log('✅ All agents loaded:', agentsList);
    } catch (err: any) {
      console.error('❌ Error loading agents:', err);
      setError(err.message || 'Failed to load agents');
    } finally {
      setIsLoading(false);
    }
  };

  const handleApproveAgent = async (id: string, agentName: string) => {
    if (!confirm(`Are you sure you want to approve ${agentName}?`)) return;
    try {
      await adminService.approveAgent(id);
      await loadAllAgents();
    } catch (err: any) {
      alert(`Approval failed: ${err.message}`);
    }
  };

  const handleRejectAgent = async (id: string, agentName: string) => {
    const reason = prompt(`Please provide a reason for rejecting ${agentName}:`);
    if (reason === null) return;
    try {
      await adminService.rejectAgent(id, reason);
      await loadAllAgents();
    } catch (err: any) {
      alert(`Rejection failed: ${err.message}`);
    }
  };

  return (
    <div className="space-y-12">
      {/* Header */}
      <div className="space-y-1">
        <h1 className="text-4xl font-black">All Agents</h1>
        <p className="text-[#7D848D] text-lg font-medium">Complete agent management and overview</p>
      </div>

      {/* Stats Cards */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-8">
        {[
          { label: 'Total Agents', value: agents.length, color: 'blue' },
          { label: 'Approved', value: agents.filter(a => a.status === 'APPROVED').length, color: 'green' },
          { label: 'Pending', value: agents.filter(a => a.status === 'PENDING_APPROVAL').length, color: 'yellow' },
          { label: 'Rejected', value: agents.filter(a => a.status === 'REJECTED').length, color: 'red' }
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
            {agents.length} Total Agents
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
                  <th className="px-10 py-6 text-[#7D848D] font-bold uppercase tracking-widest text-xs text-right">Actions</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-50">
                {agents.length === 0 ? (
                  <tr>
                    <td colSpan={6} className="px-10 py-20 text-center text-gray-400 font-medium">
                      No agents found in the system
                    </td>
                  </tr>
                ) : (
                  agents.map((agent) => (
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
                      <td className="px-10 py-8 text-right">
                        {agent.status === 'PENDING_APPROVAL' ? (
                          <div className="flex items-center justify-end gap-3">
                            <button
                              onClick={() => handleApproveAgent(agent._id, agent.fullName || agent.name || 'Agent')}
                              className="px-4 py-2 bg-[#007AFF] text-white rounded-lg font-bold text-xs hover:bg-blue-600 transition-all active:scale-95"
                            >
                              Approve
                            </button>
                            <button
                              onClick={() => handleRejectAgent(agent._id, agent.fullName || agent.name || 'Agent')}
                              className="px-4 py-2 bg-red-50 text-red-600 rounded-lg font-bold text-xs hover:bg-red-100 transition-all active:scale-95"
                            >
                              Reject
                            </button>
                          </div>
                        ) : (
                          <span className="text-gray-400 text-xs font-bold uppercase tracking-widest italic">Processed</span>
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