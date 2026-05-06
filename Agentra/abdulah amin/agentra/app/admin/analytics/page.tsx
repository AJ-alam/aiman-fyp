'use client';

import { useEffect, useState } from 'react';
import { adminService } from '@/lib/api';

export default function AnalyticsPage() {
  const [analytics, setAnalytics] = useState<any>({});
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState('');

  useEffect(() => {
    loadAnalytics();
  }, []);

  const loadAnalytics = async () => {
    try {
      setIsLoading(true);
      setError('');
      console.log('📊 Loading analytics...');

      const data = await adminService.getAnalytics();
      setAnalytics(data || {});
      console.log('✅ Analytics loaded:', data);
    } catch (err: any) {
      console.error('❌ Error loading analytics:', err);
      setError(err.message || 'Failed to load analytics');
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="space-y-12">
      {/* Header */}
      <div className="space-y-1">
        <h1 className="text-4xl font-black">System Analytics</h1>
        <p className="text-[#7D848D] text-lg font-medium">Comprehensive platform insights and metrics</p>
      </div>

      {error && (
        <div className="p-6 text-center bg-red-50 border border-red-100 rounded-[32px]">
          <p className="text-red-600 font-medium">⚠️ {error}</p>
        </div>
      )}

      {!isLoading && !error && (
        <>
          {/* Main Analytics Cards */}
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
                  <div className="text-[#7D848D] font-bold uppercase tracking-widest text-xs">Issues Reported</div>
                </div>
              </div>
            </div>
          </div>
        </>
      )}

      {isLoading && (
        <div className="p-10 text-center">
          <p className="text-gray-500 font-medium">Loading analytics...</p>
        </div>
      )}
    </div>
  );
}