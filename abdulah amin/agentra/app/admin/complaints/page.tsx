'use client';

import { useEffect, useState } from 'react';
import { adminService } from '@/lib/api';

export default function ComplaintsPage() {
  const [complaints, setComplaints] = useState<any[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState('');

  useEffect(() => {
    loadComplaints();
  }, []);

  const loadComplaints = async () => {
    try {
      setIsLoading(true);
      setError('');
      console.log('⚠️ Loading complaints...');

      const data = await adminService.getComplaints();
      const complaintsList = Array.isArray(data) ? data : (data?.complaints || []);
      setComplaints(complaintsList);
      console.log('✅ Complaints loaded:', complaintsList);
    } catch (err: any) {
      console.error('❌ Error loading complaints:', err);
      setError(err.message || 'Failed to load complaints');
    } finally {
      setIsLoading(false);
    }
  };

  const handleRespond = async (id: string) => {
    const response = prompt('Enter your response to this complaint:');
    if (!response) return;

    try {
      await adminService.respondToComplaint(id, response);
      alert('Response submitted successfully');
      loadComplaints();
    } catch (err: any) {
      alert(`Failed to respond: ${err.message}`);
    }
  };

  return (
    <div className="space-y-12">
      {/* Header */}
      <div className="space-y-1">
        <h1 className="text-4xl font-black">Complaints Management</h1>
        <p className="text-[#7D848D] text-lg font-medium">Handle customer complaints and agent issues</p>
      </div>

      {/* Stats Cards */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
        {[
          { label: 'Total Complaints', value: complaints.length, color: 'red' },
          { label: 'Open', value: complaints.filter(c => c.status !== 'RESOLVED').length, color: 'orange' },
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
            {complaints.filter(c => c.status !== 'RESOLVED').length} Open Issues
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
                  <th className="px-10 py-6 text-[#7D848D] font-bold uppercase tracking-widest text-xs">Filed By</th>
                  <th className="px-10 py-6 text-[#7D848D] font-bold uppercase tracking-widest text-xs">Complaint</th>
                  <th className="px-10 py-6 text-[#7D848D] font-bold uppercase tracking-widest text-xs">Status</th>
                  <th className="px-10 py-6 text-[#7D848D] font-bold uppercase tracking-widest text-xs">Action</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-50">
                {complaints.length === 0 ? (
                  <tr>
                    <td colSpan={4} className="px-10 py-20 text-center text-gray-400 font-medium">
                      ✓ No complaints found. All customer issues have been resolved!
                    </td>
                  </tr>
                ) : (
                  complaints.map((complaint) => (
                    <tr key={complaint._id} className="hover:bg-gray-50/30 transition-colors">
                      <td className="px-10 py-8">
                        <div className="flex flex-col">
                          <span className="font-bold text-sm">
                            {complaint.userId?.fullName || 'Unknown'}
                          </span>
                          <span className="text-[#7D848D] text-xs">
                            {complaint.userId?.email || ''}
                          </span>
                          {complaint.agentId && (
                            <span className="text-xs text-blue-600 mt-1">
                              Agent: {complaint.agentId?.businessName || complaint.agentId?.fullName}
                            </span>
                          )}
                        </div>
                      </td>
                      <td className="px-10 py-8">
                        <div className="flex flex-col">
                          <span className="font-bold text-lg">{complaint.subject}</span>
                          <span className="text-[#7D848D] text-sm line-clamp-2">{complaint.description}</span>
                          {(complaint.ownerResponse || complaint.adminResponse) && (
                            <div className="mt-2 p-3 bg-green-50 rounded-lg border border-green-100">
                              <p className="text-xs font-bold text-green-800 uppercase tracking-wider">Admin Response:</p>
                              <p className="text-sm text-green-700">{complaint.ownerResponse || complaint.adminResponse}</p>
                            </div>
                          )}
                        </div>
                      </td>
                      <td className="px-10 py-8">
                        <span className={`inline-flex items-center px-4 py-1.5 rounded-full text-xs font-black uppercase tracking-tighter ${
                          complaint.status === 'RESOLVED'
                            ? 'bg-green-100 text-green-600'
                            : 'bg-red-100 text-red-600'
                          }`}>
                          {complaint.status || 'OPEN'}
                        </span>
                      </td>
                      <td className="px-10 py-8">
                        {complaint.status !== 'RESOLVED' && (
                          <button
                            onClick={() => handleRespond(complaint._id)}
                            className="bg-black text-white px-6 py-2 rounded-full font-bold text-sm hover:bg-gray-800 transition-colors"
                          >
                            Resolve
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