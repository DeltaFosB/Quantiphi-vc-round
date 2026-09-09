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
