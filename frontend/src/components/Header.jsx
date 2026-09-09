import React from 'react';
import { Plane, ArrowRightLeft } from 'lucide-react';

export default function Header({ isTravelMode, setIsTravelMode }) {
  return (
    <header className="flex items-center justify-between py-6">
      <div className="flex items-center gap-2 text-indigo-600">
        <ArrowRightLeft size={28} className="stroke-[2.5]" />
        <h1 className="text-2xl font-bold tracking-tight text-slate-900">VibeConvert</h1>
      </div>
      
      <button 
        onClick={() => setIsTravelMode(!isTravelMode)}
        className={`relative inline-flex h-10 w-48 items-center justify-between rounded-full px-1 py-1 transition-colors duration-300 focus:outline-none ${isTravelMode ? 'bg-emerald-100 text-emerald-800' : 'bg-slate-100 text-slate-500'}`}
      >
        <span className={`absolute left-1 h-8 w-24 rounded-full bg-white shadow-sm transition-transform duration-300 ${isTravelMode ? 'translate-x-[5.5rem]' : 'translate-x-0'}`} />
        <span className="relative z-10 flex w-1/2 items-center justify-center gap-1 text-sm font-medium">Standard</span>
        <span className="relative z-10 flex w-1/2 items-center justify-center gap-1 text-sm font-medium">
          <Plane size={16} /> Travel
        </span>
      </button>
    </header>
  );
}
