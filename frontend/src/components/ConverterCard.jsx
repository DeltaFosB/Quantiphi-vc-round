import React, { useState } from 'react';
import { ArrowRightLeft, Star } from 'lucide-react';
import { api } from '../api';

export default function ConverterCard({ currencies, source, setSource, target, setTarget, onFavoriteAdded, onConversion }) {
  const [amount, setAmount] = useState('100');
  const [result, setResult] = useState(null);
  const [loading, setLoading] = useState(false);

  const currList = Object.entries(currencies || {}).map(([code, name]) => ({ code, name }));

  const handleSwap = () => {
    setSource(target);
    setTarget(source);
    setResult(null);
  };

  const handleConvert = async () => {
    if (!amount || isNaN(amount) || amount <= 0) return;
    setLoading(true);
    try {
      const res = await api.convert({ source, target, amount: parseFloat(amount) });
      setResult(res);
      if (onConversion) onConversion();
    } catch (e) {
      console.error(e);
    } finally {
      setLoading(false);
    }
  };

  const handleSaveFavorite = async () => {
    try {
      await api.addFavorite({ source, target });
      if (onFavoriteAdded) onFavoriteAdded();
    } catch (e) {
      console.error('Already in favorites or error occurred.', e);
    }
  };

  return (
    <div className="rounded-2xl bg-white p-6 shadow-sm border border-slate-100 transition-shadow hover:shadow-md">
      <div className="flex flex-col gap-4 sm:flex-row sm:items-end">
        <div className="flex-1">
          <label className="mb-2 block text-sm font-medium text-slate-500">Amount</label>
          <input
            type="number"
            value={amount}
            onChange={(e) => setAmount(e.target.value)}
            className="w-full rounded-xl border border-slate-200 bg-slate-50 p-4 text-xl font-semibold text-slate-900 outline-none transition-colors focus:border-indigo-500 focus:bg-white"
          />
        </div>
        
        <div className="flex-1">
          <label className="mb-2 block text-sm font-medium text-slate-500">From</label>
          <select 
            value={source} 
            onChange={(e) => setSource(e.target.value)}
            className="w-full appearance-none rounded-xl border border-slate-200 bg-slate-50 p-4 text-lg font-medium text-slate-900 outline-none transition-colors focus:border-indigo-500 focus:bg-white"
          >
            {currList.map(c => <option key={c.code} value={c.code}>{c.code} - {c.name}</option>)}
          </select>
        </div>

        <button 
          onClick={handleSwap}
          className="mx-auto flex h-14 w-14 shrink-0 items-center justify-center rounded-full bg-indigo-50 text-indigo-600 transition-all duration-200 hover:bg-indigo-100 active:rotate-180 active:scale-95 sm:mx-2"
        >
          <ArrowRightLeft size={24} />
        </button>

        <div className="flex-1">
          <label className="mb-2 block text-sm font-medium text-slate-500">To</label>
          <select 
            value={target} 
            onChange={(e) => setTarget(e.target.value)}
            className="w-full appearance-none rounded-xl border border-slate-200 bg-slate-50 p-4 text-lg font-medium text-slate-900 outline-none transition-colors focus:border-indigo-500 focus:bg-white"
          >
            {currList.map(c => <option key={c.code} value={c.code}>{c.code} - {c.name}</option>)}
          </select>
        </div>
      </div>

      <div className="mt-8 flex flex-col items-center justify-between gap-6 pt-6 border-t border-slate-100 sm:flex-row">
        <div className="flex flex-col">
          {result ? (
            <>
              <p className="text-sm font-medium text-slate-500">{result.amount} {result.source} =</p>
              <h2 className="text-3xl font-bold tracking-tight text-slate-900">
                {result.converted_amount.toLocaleString(undefined, { minimumFractionDigits: 2, maximumFractionDigits: 4 })} <span className="text-xl text-slate-500">{result.target}</span>
              </h2>
              <p className="mt-1 text-sm text-emerald-600 font-medium">1 {result.source} = {result.rate} {result.target}</p>
            </>
          ) : (
            <p className="text-base font-medium text-slate-400">Ready to convert</p>
          )}
        </div>
        
        <div className="flex gap-3 w-full sm:w-auto">
            <button
            onClick={handleSaveFavorite}
            title="Save Pair to Favorites"
            className="flex h-12 w-12 items-center justify-center rounded-xl border border-slate-200 bg-white text-slate-400 transition-all hover:border-amber-300 hover:text-amber-500 active:scale-95"
            >
            <Star size={20} className="fill-current opacity-20 hover:opacity-100" />
            </button>
            <button 
            onClick={handleConvert}
            disabled={loading}
            className="flex-1 rounded-xl bg-indigo-600 px-6 py-3 font-semibold text-white shadow-sm transition-all hover:bg-indigo-700 active:scale-95 disabled:opacity-70 sm:flex-none"
            >
            {loading ? 'Converting...' : 'Convert'}
            </button>
        </div>
      </div>
    </div>
  );
}
