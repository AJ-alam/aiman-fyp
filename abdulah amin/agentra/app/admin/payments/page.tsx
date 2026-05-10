'use client';

import { useEffect, useState } from 'react';
import { API_BASE, apiRequest } from '@/lib/api';

interface Transaction {
  _id: string;
  type: string;
  amount: number;
  payoutStatus: string;
  paymentMethod: string;
  createdAt: string;
  userId?: { fullName?: string; email?: string };
  agentId?: { fullName?: string; businessName?: string };
  packageId?: { title?: string; location?: string };
}

export default function PaymentsPage() {
  const [transactions, setTransactions] = useState<Transaction[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState('');

  useEffect(() => {
    loadPayments();
  }, []);

  const loadPayments = async () => {
    try {
      setIsLoading(true);
      setError('');
      // Fetch all transactions via owner endpoint
      const data = await apiRequest('/payments/all?limit=100', { method: 'GET' });
      const list = data?.transactions || [];
      setTransactions(list);
    } catch (err: any) {
      setError(err.message || 'Failed to load payments');
    } finally {
      setIsLoading(false);
    }
  };

  const totalRevenue = transactions
    .filter((t) => t.type === 'EARNING')
    .reduce((sum, t) => sum + t.amount, 0);

  const totalRefunds = transactions
    .filter((t) => t.type === 'REFUND')
    .reduce((sum, t) => sum + t.amount, 0);

  return (
    <div className="space-y-12">
      {/* Header */}
      <div className="space-y-1">
        <h1 className="text-4xl font-black">Payments</h1>
        <p className="text-[#7D848D] text-lg font-medium">All platform transactions and earnings</p>
      </div>

      {/* Summary Cards */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
        {[
          { label: 'Total Transactions', value: transactions.length, color: 'blue' },
          { label: 'Total Revenue (PKR)', value: `${totalRevenue.toLocaleString()}`, color: 'green' },
          { label: 'Total Refunds (PKR)', value: `${totalRefunds.toLocaleString()}`, color: 'red' },
        ].map((stat, i) => (
          <div key={i} className="bg-white p-8 rounded-[32px] shadow-sm border border-gray-50 flex flex-col justify-between hover:shadow-md transition-all">
            <p className="text-[#7D848D] font-bold uppercase tracking-widest text-xs">{stat.label}</p>
            <h3 className="text-3xl font-black mt-2">{stat.value}</h3>
          </div>
        ))}
      </div>

      {/* Transactions Table */}
      <div className="bg-white rounded-[40px] shadow-sm border border-gray-50 overflow-hidden">
        <div className="p-10 border-b border-gray-50 flex items-center justify-between bg-gray-50/30">
          <h2 className="text-2xl font-black">Transaction History</h2>
          <button
            onClick={loadPayments}
            className="px-6 py-2 bg-white border border-gray-200 rounded-2xl font-bold text-sm hover:bg-gray-50 transition-all"
          >
            Refresh
          </button>
        </div>

        {isLoading && (
          <div className="p-10 text-center">
            <p className="text-gray-500 font-medium">Loading transactions...</p>
          </div>
        )}

        {error && !isLoading && (
          <div className="p-10 text-center bg-red-50 border-t border-red-100">
            <p className="text-red-600 font-medium">⚠️ {error}</p>
          </div>
        )}

        {!isLoading && !error && (
          <div className="overflow-x-auto">
            <table className="w-full text-left border-collapse">
              <thead>
                <tr className="bg-gray-50/50">
                  <th className="px-8 py-6 text-[#7D848D] font-bold uppercase tracking-widest text-xs">User</th>
                  <th className="px-8 py-6 text-[#7D848D] font-bold uppercase tracking-widest text-xs">Agent</th>
                  <th className="px-8 py-6 text-[#7D848D] font-bold uppercase tracking-widest text-xs">Package</th>
                  <th className="px-8 py-6 text-[#7D848D] font-bold uppercase tracking-widest text-xs">Amount</th>
                  <th className="px-8 py-6 text-[#7D848D] font-bold uppercase tracking-widest text-xs">Type</th>
                  <th className="px-8 py-6 text-[#7D848D] font-bold uppercase tracking-widest text-xs">Status</th>
                  <th className="px-8 py-6 text-[#7D848D] font-bold uppercase tracking-widest text-xs">Date</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-50">
                {transactions.length === 0 ? (
                  <tr>
                    <td colSpan={7} className="px-8 py-20 text-center text-gray-400 font-medium">
                      No transactions found
                    </td>
                  </tr>
                ) : (
                  transactions.map((txn) => (
                    <tr key={txn._id} className="hover:bg-gray-50/30 transition-colors">
                      <td className="px-8 py-6">
                        <span className="font-medium text-sm">
                          {txn.userId?.fullName || 'N/A'}
                        </span>
                      </td>
                      <td className="px-8 py-6">
                        <span className="text-sm text-[#7D848D]">
                          {txn.agentId?.businessName || txn.agentId?.fullName || 'N/A'}
                        </span>
                      </td>
                      <td className="px-8 py-6">
                        <span className="text-sm text-[#7D848D]">
                          {txn.packageId?.title || 'N/A'}
                        </span>
                      </td>
                      <td className="px-8 py-6">
                        <span className="font-bold text-sm">
                          PKR {txn.amount?.toLocaleString() || 0}
                        </span>
                      </td>
                      <td className="px-8 py-6">
                        <span className={`inline-flex items-center px-3 py-1 rounded-full text-xs font-black uppercase ${
                          txn.type === 'EARNING'
                            ? 'bg-green-100 text-green-700'
                            : txn.type === 'REFUND'
                            ? 'bg-red-100 text-red-700'
                            : 'bg-blue-100 text-blue-700'
                        }`}>
                          {txn.type}
                        </span>
                      </td>
                      <td className="px-8 py-6">
                        <span className={`inline-flex items-center px-3 py-1 rounded-full text-xs font-black uppercase ${
                          txn.payoutStatus === 'PAID'
                            ? 'bg-green-100 text-green-700'
                            : txn.payoutStatus === 'FAILED'
                            ? 'bg-red-100 text-red-700'
                            : 'bg-yellow-100 text-yellow-700'
                        }`}>
                          {txn.payoutStatus}
                        </span>
                      </td>
                      <td className="px-8 py-6">
                        <span className="text-sm text-[#7D848D]">
                          {txn.createdAt ? new Date(txn.createdAt).toLocaleDateString() : 'N/A'}
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
    </div>
  );
}
