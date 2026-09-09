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
