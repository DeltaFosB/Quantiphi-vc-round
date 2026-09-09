import React, { useState } from 'react';
import { Plane, Compass } from 'lucide-react';
import { api } from '../api';

export default function TravelBudget({ currencies }) {
  const [baseCurrency, setBaseCurrency] = useState('USD');
  const [amount, setAmount] = useState('2500');
  const [results, setResults] = useState([]);
  const [loading, setLoading] = useState(false);

  const currList = Object.entries(currencies || {}).map(([code, name]) => ({ code, name }));

  const handleCalculate = async () => {
    if (!amount || isNaN(amount) || amount <= 0) return;
    setLoading(true);
    try {
      const res = await api.getTravelBudget({ base_currency: baseCurrency, amount: parseFloat(amount) });
      setResults(res.comparisons || []);
    } catch (e) {
      console.error(e);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="flex flex-col gap-8 animate-in fade-in slide-in-from-bottom-4 duration-500">
      
      <div className="rounded-2xl bg-gradient-to-br from-emerald-500 to-teal-600 p-8 text-white shadow-md">
        <div className="flex items-center gap-3 mb-4">
          <div className="p-3 bg-white/20 rounded-xl backdrop-blur-sm">
            <Compass size={28} className="text-white" />
          </div>
          <div>
            <h2 className="text-2xl font-bold">Vibe Check: Global Budget</h2>
            <p className="text-emerald-100">See how far your money goes around the world instantly.</p>
          </div>
        </div>

        <div className="flex flex-col sm:flex-row gap-4 mt-8 items-end">
          <div className="flex-1 w-full">
            <label className="mb-2 block text-sm font-medium text-emerald-100">Total Budget</label>
            <input
              type="number"
              value={amount}
              onChange={(e) => setAmount(e.target.value)}
              className="w-full rounded-xl border-none bg-white/10 p-4 text-2xl font-bold text-white placeholder-emerald-200/50 outline-none backdrop-blur-sm transition-colors focus:bg-white/20 focus:ring-2 focus:ring-white/50"
              placeholder="e.g. 2500"
            />
          </div>
          
          <div className="flex-1 w-full sm:w-auto">
            <label className="mb-2 block text-sm font-medium text-emerald-100">Base Currency</label>
            <select 
              value={baseCurrency} 
              onChange={(e) => setBaseCurrency(e.target.value)}
              className="w-full appearance-none rounded-xl border-none bg-white/10 p-4 text-xl font-bold text-white outline-none backdrop-blur-sm transition-colors focus:bg-white/20 focus:ring-2 focus:ring-white/50"
            >
              {currList.map(c => <option key={c.code} value={c.code} className="text-slate-900">{c.code}</option>)}
            </select>
          </div>

          <button 
            onClick={handleCalculate}
            disabled={loading}
            className="w-full sm:w-auto rounded-xl bg-white px-8 py-4 text-lg font-bold text-emerald-700 shadow-sm transition-all hover:bg-emerald-50 active:scale-95 disabled:opacity-80 flex items-center justify-center gap-2"
          >
            {loading ? 'Checking...' : <><Plane size={20} /> Vibe Check</>}
          </button>
        </div>
      </div>

      {results.length > 0 && (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
          {results.map((r, i) => (
            <div key={r.currency} className="rounded-2xl bg-white p-6 shadow-sm border border-slate-100 hover:shadow-md transition-shadow animate-in zoom-in duration-300" style={{animationDelay: `${i * 100}ms`}}>
              <div className="flex items-center justify-between mb-4">
                <span className="text-3xl bg-slate-50 h-12 w-12 rounded-full flex items-center justify-center border border-slate-100">
                  {r.currency === 'USD' ? '🇺🇸' : r.currency === 'EUR' ? '🇪🇺' : r.currency === 'GBP' ? '🇬🇧' : r.currency === 'JPY' ? '🇯🇵' : r.currency === 'AUD' ? '🇦🇺' : '💸'}
                </span>
                <span className="px-3 py-1 bg-slate-100 text-slate-600 rounded-full text-xs font-bold">{r.currency}</span>
              </div>
              <p className="text-sm font-medium text-slate-500 mb-1">Equivalent Value</p>
              <h3 className="text-3xl font-bold text-slate-900 mb-2">
                {r.equivalent.toLocaleString(undefined, { minimumFractionDigits: 2, maximumFractionDigits: 2 })}
              </h3>
              <p className="text-xs font-medium text-slate-400 border-t border-slate-100 pt-3 mt-3">
                Rate: 1 {baseCurrency} = {r.rate} {r.currency}
              </p>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}
