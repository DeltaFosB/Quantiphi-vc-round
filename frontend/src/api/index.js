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
