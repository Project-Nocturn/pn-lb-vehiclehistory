let ownedVehicles = [];
let currentPlate = null;
let currentHistory = [];

function goHome() {
    document.getElementById('view-home').classList.add('active');
    document.getElementById('view-history').classList.remove('active');
    const back = document.getElementById('btn-back');
    if (back) back.style.display = 'none';
}

function goHistory() {
    document.getElementById('view-home').classList.remove('active');
    document.getElementById('view-history').classList.add('active');
    const back = document.getElementById('btn-back');
    if (back) back.style.display = 'inline-block';
}

function renderOwned(list) {
    const container = document.getElementById('owned-list');
    container.innerHTML = '';
    if (!list || list.length === 0) {
        const empty = document.createElement('div');
        empty.className = 'card';
        empty.innerText = 'Aucun véhicule trouvé';
        container.appendChild(empty);
        return;
    }
    for (let i = 0; i < list.length; i++) {
        const v = list[i];
        const card = document.createElement('div');
        card.className = 'card';
        const title = document.createElement('div');
        title.className = 'card-title';
        title.innerText = v.plate;
        const sub = document.createElement('div');
        sub.className = 'card-sub';
        sub.innerText = v.model ? `Modèle: ${v.model}` : '';
        const btn = document.createElement('button');
        btn.className = 'btn';
        btn.innerText = 'Voir historique';
        btn.onclick = () => openHistory(v.plate);
        card.appendChild(title);
        card.appendChild(sub);
        card.appendChild(btn);
        container.appendChild(card);
    }
}

function formatDate(ts) {
    try {
        const n = Number(ts);
        const d = new Date(n < 1e12 ? n * 1000 : n);
        return d.toLocaleString();
    } catch {
        return String(ts);
    }
}

function firstProp(obj, keys, fallback) {
    for (let i = 0; i < keys.length; i++) {
        const k = keys[i];
        const v = obj[k];
        if (v !== undefined && v !== null && String(v).length > 0) return v;
    }
    return fallback;
}

function renderHistory(list) {
    const container = document.getElementById('history-list');
    container.innerHTML = '';
    if (!list || list.length === 0) {
        const empty = document.createElement('div');
        empty.className = 'card';
        empty.innerText = 'Aucun entretien trouvé';
        container.appendChild(empty);
        return;
    }
    for (let i = 0; i < list.length; i++) {
        const it = list[i];
        const card = document.createElement('div');
        card.className = 'card';
        const title = document.createElement('div');
        title.className = 'card-title';
        const mech = firstProp(it, ['mechanic_label','mechanic','identifier'], 'Mécanicien');
        title.innerText = `${mech} • ${formatDate(it.date)}`;
        const sub = document.createElement('div');
        sub.className = 'card-sub';
        sub.innerText = `Plaque: ${it.plate}`;
        const chips = document.createElement('div');
        chips.className = 'chips';
        const partVal = firstProp(it, ['serviced_paort','serviced_part','part','service'], 'Pièce');
        const part = document.createElement('span');
        part.className = 'chip';
        part.innerText = partVal;
        const km = document.createElement('span');
        km.className = 'chip';
        km.innerText = (it.mileage_km != null ? (it.mileage_km + ' km') : 'Km inconnu');
        const idChip = document.createElement('span');
        idChip.className = 'chip';
        idChip.innerText = firstProp(it, ['id'], 'Entrée');
        card.appendChild(title);
        card.appendChild(sub);
        chips.appendChild(part);
        chips.appendChild(km);
        chips.appendChild(idChip);
        card.appendChild(chips);
        container.appendChild(card);
    }
}

function openHistory(plate) {
    currentPlate = plate;
    document.getElementById('history-title').innerText = `Historique • ${plate}`;
    fetchNui('getHistoryByPlate', { plate }).then((history) => {
        currentHistory = Array.isArray(history) ? history : [];
        renderHistory(currentHistory);
        goHistory();
    });
}

function searchByPlate() {
    const plate = document.getElementById('search-plate').value?.trim();
    if (!plate || plate.length === 0) {
        fetchNui('notify', { title: 'Carnet', message: 'Entrez une plaque' });
        return;
    }
    openHistory(plate);
}

function copyHistory() {
    if (!currentHistory || currentHistory.length === 0) {
        fetchNui('notify', { title: 'Carnet', message: 'Rien à copier' });
        return;
    }
    const text = JSON.stringify(currentHistory, null, 2);
    if (navigator.clipboard && navigator.clipboard.writeText) {
        navigator.clipboard.writeText(text).then(() => {
            fetchNui('notify', { title: 'Carnet', message: 'Copié dans le presse-papiers' });
        });
    }
}

function initSettingsSync() {
    if (typeof onSettingsChange === 'function') {
        onSettingsChange((settings) => {
            let theme = settings.display.theme;
            document.getElementsByClassName('app')[0].dataset.theme = theme;
        });
    }
    if (typeof getSettings === 'function') {
        getSettings().then((settings) => {
            let theme = settings.display.theme;
            document.getElementsByClassName('app')[0].dataset.theme = theme;
        });
    }
}

window.addEventListener('message', (e) => {
    if (e.data === 'componentsLoaded') {
        initSettingsSync();
        goHome();
        fetchNui('getOwnedVehicles').then((list) => {
            ownedVehicles = Array.isArray(list) ? list : [];
            renderOwned(ownedVehicles);
        });
    }
});
