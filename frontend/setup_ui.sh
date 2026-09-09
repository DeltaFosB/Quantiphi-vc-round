#!/bin/bash
mkdir -p src/components
mkdir -p src/hooks
mkdir -p src/api

# 1. API Helper
cat << 'API_EOF' > src/api/index.js
const API_BASE = '/api';

export const api = {
    getCurrencies: () => fetch(`${API_BASE}/currencies`).then(r => r.json()),
    convert: (data) => fetch(`${API_BASE}/convert`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(data)
    }).then(r => r.json()),
    getTrends: (source, target) => fetch(`${API_BASE}/trends?source=${source}&target=${target}`).then(r => r.json()),
    getTravelBudget: (data) => fetch(`${API_BASE}/travel-budget`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(data)
    }).then(r => r.json()),
    getHistory: () => fetch(`${API_BASE}/history`).then(r => r.json()),
    getFavorites: () => fetch(`${API_BASE}/favorites`).then(r => r.json()),
    addFavorite: (data) => fetch(`${API_BASE}/favorites`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(data)
    }).then(r => r.json()),
    deleteFavorite: (id) => fetch(`${API_BASE}/favorites/${id}`, { method: 'DELETE' }).then(r => r.json())
};
API_EOF

# 2. Header Component
cat << 'HEADER_EOF' > src/components/Header.jsx
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
HEADER_EOF

# 3. Converter Component
cat << 'CONV_EOF' > src/components/ConverterCard.jsx
import React, { useState, useEffect } from 'react';
import { ArrowRightLeft, Star } from 'lucide-react';
import { api } from '../api';

export default function ConverterCard({ currencies, onConvertSuccess }) {
  const [source, setSource] = useState('USD');
  const [target, setTarget] = useState('EUR');
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
      if (onConvertSuccess) onConvertSuccess(res.source, res.target);
    } catch (e) {
      console.error(e);
    } finally {
      setLoading(false);
    }
  };

  const handleSaveFavorite = async () => {
    try {
      await api.addFavorite({ source, target });
      alert('Saved to favorites!');
    } catch (e) {
      alert('Already in favorites or error occurred.');
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

      <div className="mt-8 flex flex-col items-center justify-between gap-6 rounded-xl bg-slate-50 p-6 sm:flex-row">
        <div className="flex flex-col">
          {result ? (
            <>
              <p className="text-sm font-medium text-slate-500">{result.amount} {result.source} =</p>
              <h2 className="text-4xl font-bold tracking-tight text-slate-900">
                {result.converted_amount.toLocaleString(undefined, { minimumFractionDigits: 2, maximumFractionDigits: 4 })} <span className="text-2xl text-slate-500">{result.target}</span>
              </h2>
              <p className="mt-1 text-sm text-emerald-600 font-medium">1 {result.source} = {result.rate} {result.target}</p>
            </>
          ) : (
            <p className="text-lg font-medium text-slate-400">Enter amount and click convert</p>
          )}
        </div>
        
        <div className="flex gap-3 w-full sm:w-auto">
            <button
            onClick={handleSaveFavorite}
            title="Save Pair to Favorites"
            className="flex h-14 w-14 items-center justify-center rounded-xl border border-slate-200 bg-white text-slate-400 transition-all hover:border-amber-300 hover:text-amber-500 active:scale-95"
            >
            <Star size={24} className="fill-current opacity-20 hover:opacity-100" />
            </button>
            <button 
            onClick={handleConvert}
            disabled={loading}
            className="flex-1 rounded-xl bg-indigo-600 px-8 py-4 font-semibold text-white shadow-sm transition-all hover:bg-indigo-700 active:scale-95 disabled:opacity-70 sm:flex-none"
            >
            {loading ? 'Converting...' : 'Convert'}
            </button>
        </div>
      </div>
    </div>
  );
}
CONV_EOF

# 4. Trend Chart Component
cat << 'CHART_EOF' > src/components/TrendChart.jsx
import React, { useEffect, useState } from 'react';
import { LineChart, Line, XAxis, YAxis, Tooltip, ResponsiveContainer, CartesianGrid } from 'recharts';
import { api } from '../api';

export default function TrendChart({ source, target }) {
  const [data, setData] = useState([]);
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    if (!source || !target) return;
    const fetchTrends = async () => {
      setLoading(true);
      try {
        const res = await api.getTrends(source, target);
        setData(res.trends);
      } catch (e) {
        console.error(e);
      } finally {
        setLoading(false);
      }
    };
    fetchTrends();
  }, [source, target]);

  if (!source || !target) return null;

  return (
    <div className="flex h-full min-h-[350px] flex-col rounded-2xl bg-white p-6 shadow-sm border border-slate-100">
      <h3 className="mb-6 text-lg font-bold text-slate-900">
        30-Day Trend: {source} to {target}
      </h3>
      {loading ? (
        <div className="flex h-full items-center justify-center">
          <div className="h-32 w-32 animate-pulse rounded-full bg-indigo-50"></div>
        </div>
      ) : (
        <div className="h-[250px] w-full flex-1">
          <ResponsiveContainer width="100%" height="100%">
            <LineChart data={data} margin={{ top: 5, right: 0, left: -20, bottom: 0 }}>
              <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#e2e8f0" />
              <XAxis 
                dataKey="date" 
                tick={{ fontSize: 12, fill: '#64748b' }} 
                tickLine={false} 
                axisLine={false}
                minTickGap={30}
              />
              <YAxis 
                domain={['auto', 'auto']} 
                tick={{ fontSize: 12, fill: '#64748b' }} 
                tickLine={false} 
                axisLine={false}
                tickFormatter={(val) => val.toFixed(4)}
              />
              <Tooltip 
                contentStyle={{ borderRadius: '12px', border: 'none', boxShadow: '0 4px 6px -1px rgb(0 0 0 / 0.1)' }}
                labelStyle={{ fontWeight: 'bold', color: '#0f172a' }}
              />
              <Line 
                type="monotone" 
                dataKey="rate" 
                stroke="#4f46e5" 
                strokeWidth={3} 
                dot={false}
                activeDot={{ r: 6, fill: '#4f46e5', stroke: '#fff', strokeWidth: 2 }} 
              />
            </LineChart>
          </ResponsiveContainer>
        </div>
      )}
    </div>
  );
}
CHART_EOF

# 5. Sidebar (Favorites & History)
cat << 'SIDEBAR_EOF' > src/components/Sidebar.jsx
import React, { useState, useEffect } from 'react';
import { Clock, Star, Trash2 } from 'lucide-react';
import { api } from '../api';

export default function Sidebar() {
  const [tab, setTab] = useState('favorites'); // 'favorites' | 'history'
  const [favorites, setFavorites] = useState([]);
  const [history, setHistory] = useState([]);

  const fetchData = async () => {
    if (tab === 'favorites') {
      const res = await api.getFavorites();
      setFavorites(res.favorites || []);
    } else {
      const res = await api.getHistory();
      setHistory(res.history || []);
    }
  };

  useEffect(() => {
    fetchData();
  }, [tab]);

  const handleDeleteFav = async (id) => {
    await api.deleteFavorite(id);
    fetchData();
  };

  return (
    <div className="flex h-[350px] flex-col rounded-2xl bg-white shadow-sm border border-slate-100 overflow-hidden">
      <div className="flex border-b border-slate-100">
        <button 
          onClick={() => setTab('favorites')}
          className={`flex-1 flex items-center justify-center gap-2 py-4 text-sm font-semibold transition-colors ${tab === 'favorites' ? 'border-b-2 border-indigo-600 text-indigo-600' : 'text-slate-500 hover:text-slate-700'}`}
        >
          <Star size={16} /> Favorites
        </button>
        <button 
          onClick={() => setTab('history')}
          className={`flex-1 flex items-center justify-center gap-2 py-4 text-sm font-semibold transition-colors ${tab === 'history' ? 'border-b-2 border-indigo-600 text-indigo-600' : 'text-slate-500 hover:text-slate-700'}`}
        >
          <Clock size={16} /> History
        </button>
      </div>

      <div className="flex-1 overflow-y-auto p-2 scrollbar-hide">
        {tab === 'favorites' ? (
          favorites.length > 0 ? (
            <ul className="space-y-1">
              {favorites.map(f => (
                <li key={f.id} className="flex items-center justify-between rounded-xl p-3 hover:bg-slate-50 transition-colors">
                  <span className="font-semibold text-slate-800">{f.source_currency} <span className="text-slate-400 font-normal mx-1">→</span> {f.target_currency}</span>
                  <button onClick={() => handleDeleteFav(f.id)} className="text-slate-300 hover:text-rose-500 p-1 rounded-md transition-colors">
                    <Trash2 size={16} />
                  </button>
                </li>
              ))}
            </ul>
          ) : (
            <div className="flex h-full flex-col items-center justify-center text-center p-4">
              <Star className="text-slate-200 mb-2" size={32} />
              <p className="text-sm text-slate-500">No favorites yet. Convert a pair and click the star to save it.</p>
            </div>
          )
        ) : (
          history.length > 0 ? (
            <ul className="space-y-1">
              {history.map(h => (
                <li key={h.id} className="flex flex-col rounded-xl p-3 hover:bg-slate-50 transition-colors">
                  <div className="flex items-center justify-between mb-1">
                    <span className="font-semibold text-slate-800">{h.source_currency} <span className="text-slate-400 font-normal mx-1">→</span> {h.target_currency}</span>
                    <span className="text-xs text-slate-400">{new Date(h.created_at).toLocaleDateString()}</span>
                  </div>
                  <div className="flex items-center justify-between text-sm">
                    <span className="text-slate-500">{h.amount}</span>
                    <span className="font-semibold text-emerald-600">{h.converted_amount.toLocaleString(undefined, { minimumFractionDigits: 2, maximumFractionDigits: 4 })}</span>
                  </div>
                </li>
              ))}
            </ul>
          ) : (
            <div className="flex h-full flex-col items-center justify-center text-center p-4">
              <Clock className="text-slate-200 mb-2" size={32} />
              <p className="text-sm text-slate-500">Your recent conversions will appear here.</p>
            </div>
          )
        )}
      </div>
    </div>
  );
}
SIDEBAR_EOF

# 6. Travel Budget Component
cat << 'TRAVEL_EOF' > src/components/TravelBudget.jsx
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
TRAVEL_EOF

# 7. App.jsx Root Component
cat << 'APP_EOF' > src/App.jsx
import { useState, useEffect } from 'react';
import Header from './components/Header';
import ConverterCard from './components/ConverterCard';
import TrendChart from './components/TrendChart';
import Sidebar from './components/Sidebar';
import TravelBudget from './components/TravelBudget';
import { api } from './api';

function App() {
  const [isTravelMode, setIsTravelMode] = useState(false);
  const [currencies, setCurrencies] = useState({});
  const [activeTrend, setActiveTrend] = useState({ source: 'USD', target: 'EUR' });

  useEffect(() => {
    api.getCurrencies().then(res => {
      if(res.currencies) setCurrencies(res.currencies);
    }).catch(console.error);
  }, []);

  const handleConvertSuccess = (source, target) => {
    setActiveTrend({ source, target });
  };

  return (
    <div className="min-h-screen bg-slate-50 font-sans text-slate-900 pb-12">
      <div className="mx-auto max-w-5xl px-4 sm:px-6">
        <Header isTravelMode={isTravelMode} setIsTravelMode={setIsTravelMode} />
        
        <main className="mt-8">
          {!isTravelMode ? (
            <div className="flex flex-col gap-6 animate-in fade-in slide-in-from-bottom-4 duration-500">
              <ConverterCard currencies={currencies} onConvertSuccess={handleConvertSuccess} />
              
              <div className="grid grid-cols-1 gap-6 lg:grid-cols-3">
                <div className="lg:col-span-2">
                  <TrendChart source={activeTrend.source} target={activeTrend.target} />
                </div>
                <div className="lg:col-span-1">
                  <Sidebar />
                </div>
              </div>
            </div>
          ) : (
            <TravelBudget currencies={currencies} />
          )}
        </main>
      </div>
    </div>
  );
}

export default App;
APP_EOF

