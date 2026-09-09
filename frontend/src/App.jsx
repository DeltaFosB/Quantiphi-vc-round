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
  const [source, setSource] = useState('USD');
  const [target, setTarget] = useState('EUR');
  const [refreshTrigger, setRefreshTrigger] = useState(0);

  useEffect(() => {
    api.getCurrencies().then(res => {
      if(res.currencies) setCurrencies(res.currencies);
    }).catch(console.error);
  }, []);

  return (
    <div className="min-h-screen bg-slate-50 font-sans text-slate-900 pb-12">
      <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
        <Header isTravelMode={isTravelMode} setIsTravelMode={setIsTravelMode} />
        
        <main className="mt-8">
          {!isTravelMode ? (
            <div className="flex flex-col gap-6 animate-in fade-in slide-in-from-bottom-4 duration-500">
              <ConverterCard 
                currencies={currencies} 
                source={source} 
                setSource={setSource} 
                target={target} 
                setTarget={setTarget}
                onFavoriteAdded={() => setRefreshTrigger(prev => prev + 1)}
                onConversion={() => setRefreshTrigger(prev => prev + 1)}
              />
              
              <div className="grid grid-cols-1 gap-6 lg:grid-cols-3">
                <div className="lg:col-span-2">
                  <TrendChart source={source} target={target} />
                </div>
                <div className="lg:col-span-1">
                  <Sidebar refreshTrigger={refreshTrigger} setSource={setSource} setTarget={setTarget} />
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
