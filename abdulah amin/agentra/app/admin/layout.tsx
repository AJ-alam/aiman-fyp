'use client';

import { useEffect, useState } from 'react';
import { useRouter, usePathname } from 'next/navigation';
import Link from 'next/link';
import Image from 'next/image';

const AdminLayout = ({ children }: { children: React.ReactNode }) => {
  const router = useRouter();
  const pathname = usePathname();
  const [isAuthenticated, setIsAuthenticated] = useState(false);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    // Check if admin token exists
    const token = typeof window !== 'undefined' ? localStorage.getItem('ownerToken') : null;
    if (!token) {
      router.push('/');
    } else {
      setIsAuthenticated(true);
      setIsLoading(false);
    }
  }, [router]);

  const handleLogout = () => {
    localStorage.removeItem('ownerToken');
    router.push('/');
  };

  const navItems = [
    { name: 'Dashboard', icon: '🏠', href: '/admin', section: 'dashboard' },
    { name: 'Agents', icon: '👤', href: '/admin/agents', section: 'agents' },
    { name: 'Complaints', icon: '⚠️', href: '/admin/complaints', section: 'complaints' },
    { name: 'System Logs', icon: '📝', href: '/admin/logs', section: 'logs' },
    { name: 'Analytics', icon: '📊', href: '/admin/analytics', section: 'analytics' }
  ];

  if (isLoading) {
    return (
      <div className="flex items-center justify-center min-h-screen bg-gray-50">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-[#007AFF] mx-auto mb-4"></div>
          <p className="text-gray-500 font-medium">Loading admin dashboard...</p>
        </div>
      </div>
    );
  }

  if (!isAuthenticated) {
    return null;
  }

  return (
    <div className="flex min-h-screen bg-[#F8F9FA] text-[#1B1E28]">
      {/* Sidebar */}
      <aside className="hidden lg:flex flex-col w-80 bg-white border-r border-gray-100 p-10 space-y-12 shrink-0 fixed h-screen left-0">
        <div className="flex items-center space-x-4">
          <Image src="/logo.png" alt="Logo" width={50} height={50} className="object-contain" />
          <span className="text-2xl font-black uppercase tracking-widest">ADMIN</span>
        </div>

        <nav className="flex-1 space-y-4">
          {navItems.map((item) => {
            const isActive = pathname === item.href || (item.href === '/admin' && pathname === '/admin');
            return (
              <Link
                key={item.name}
                href={item.href}
                className={`flex items-center space-x-4 p-4 rounded-xl cursor-pointer transition-all group ${
                  isActive
                    ? 'bg-[#007AFF] text-white shadow-lg'
                    : 'hover:bg-blue-50 hover:text-[#007AFF]'
                }`}
              >
                <span className="text-xl">{item.icon}</span>
                <span className="text-lg font-bold">{item.name}</span>
              </Link>
            );
          })}
        </nav>

        <button
          onClick={handleLogout}
          className="w-full py-4 border-2 border-red-50 text-red-500 rounded-2xl font-bold hover:bg-red-50 transition-all flex items-center justify-center space-x-2"
        >
          <span>Log out</span>
        </button>
      </aside>

      {/* Main Content */}
      <main className="flex-1 ml-0 lg:ml-80 flex flex-col overflow-y-auto">
        {/* Header */}
        <header className="bg-white border-b border-gray-100 p-8 sm:p-12 flex items-center justify-between sticky top-0 z-40">
          <div className="flex-1" />
          <div className="flex items-center space-x-6">
            <div className="flex items-center space-x-4 bg-white p-2 pr-6 rounded-2xl shadow-sm border border-gray-50">
              <div className="w-12 h-12 bg-[#FF6B35] rounded-xl flex items-center justify-center text-white font-bold">A</div>
              <span className="font-bold text-gray-700">Administrator</span>
            </div>
          </div>
        </header>

        {/* Page Content */}
        <div className="flex-1 p-8 sm:p-12">
          {children}
        </div>
      </main>
    </div>
  );
};

export default AdminLayout;