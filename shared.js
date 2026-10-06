// =====================================================
// shared.js - Elementos con alquimia
// Datos y utilidades compartidas. Lo usa index.html (dashboard).
// Todo se guarda en localStorage, reemplazar por la bd.
// "baja: true" = dado de baja (no se elimina, se puede restablecer).
// =====================================================

const KEY_INV = 'eca_inventarios_v1';   // misma clave que usan las demás pantallas

const SEED_INV = [
    { id: 1, nombre: 'Inventario 1', descripcion: 'Materias primas y esencias para elaboración.', productos: 24, baja: false },
    { id: 2, nombre: 'Inventario 2', descripcion: 'Productos terminados listos para venta.', productos: 18, baja: false },
    { id: 3, nombre: 'Inventario 3', descripcion: 'Envases, etiquetas y material de empaque.', productos: 31, baja: false }
];

function cargar(key, seed) {
    try {
        const s = localStorage.getItem(key);
        if (s) return JSON.parse(s);
    } catch (e) {}
    return JSON.parse(JSON.stringify(seed));
}

let inventarios = cargar(KEY_INV, SEED_INV);

function guardar() {
    try { localStorage.setItem(KEY_INV, JSON.stringify(inventarios)); } catch (e) {}
}

const esc = s => String(s).replace(/[&<>"']/g, c => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]));

// ===== Sidebar: inventarios activos =====
let invActivoId = null;   // inventario que se está viendo (se resalta en el submenú)

function renderSidebar() {
    const ul = document.getElementById('nav-inventarios');
    if (!ul) return;
    const activos = inventarios.filter(i => !i.baja);
    ul.innerHTML = activos.length
        ? activos.map(i => `<li><a href="inventario.html?id=${i.id}"${i.id === invActivoId ? ' class="active" aria-current="page"' : ''}>${esc(i.nombre)}</a></li>`).join('')
        : '<li class="nav-empty">Sin inventarios activos</li>';
}

// ===== Card de inventario (tag: 'a' en el dashboard, 'button' en inventarios) =====
function cardHTML(i, tag) {
    const href = tag === 'a' ? ` href="inventario.html?id=${i.id}"` : '';
    return `
        <${tag} class="inventory-item${i.baja ? ' is-baja' : ''}" data-id="${i.id}"${href}>
            <div class="inventory-card">
                ${i.baja ? '<span class="badge">De baja</span>' : ''}
                <div class="card-number">${i.productos}</div>
                <div class="card-label">productos</div>
            </div>
            <div class="inventory-text">
                <span class="inventory-name">${esc(i.nombre)}</span>
                <span class="inventory-desc">${esc(i.descripcion || '')}</span>
            </div>
        </${tag}>`;
}

// ===== Aviso con "Deshacer" =====
function toast(msg, onUndo) {
    let t = document.getElementById('toast');
    if (!t) {
        t = document.createElement('div');
        t.id = 'toast';
        t.className = 'toast';
        t.setAttribute('role', 'status');
        document.body.appendChild(t);
    }
    t.innerHTML = '<span></span><button class="toast-btn">Deshacer</button>';
    t.firstChild.textContent = msg;
    t.querySelector('button').onclick = () => { onUndo(); t.classList.remove('show'); };
    t.classList.add('show');
    clearTimeout(t._t);
    t._t = setTimeout(() => t.classList.remove('show'), 6000);
}

// ===== Ventana de confirmación =====
function confirmar(titulo, texto, okLabel, onOk) {
    let d = document.getElementById('dlg-confirm');
    if (!d) {
        d = document.createElement('dialog');
        d.id = 'dlg-confirm';
        d.innerHTML = '<h3></h3><p class="dlg-text"></p><div class="dialog-actions"><button class="btn" data-no>Cancelar</button><button class="btn btn-primary" data-ok></button></div>';
        document.body.appendChild(d);
        d.querySelector('[data-no]').onclick = () => d.close();
    }
    d.querySelector('h3').textContent = titulo;
    d.querySelector('.dlg-text').textContent = texto;
    const ok = d.querySelector('[data-ok]');
    ok.textContent = okLabel;
    ok.onclick = () => { d.close(); onOk(); };
    d.showModal();
}

// ===== Layout: sidebar + topbar alrededor de <main class="content"> =====
// activo: 'dashboard' | 'inventarios' | 'productos' | 'insumos'
// buscar: texto del placeholder de la barra de búsqueda
// inventario: id del inventario abierto (solo en inventario.html), para resaltarlo en el menú
function montarLayout({ activo = '', buscar = 'Buscar', inventario = null } = {}) {
    const main = document.querySelector('main.content');

    const link = (href, clave, texto) =>
        `<a href="${href}" class="nav-item${activo === clave ? ' active' : ''}"${activo === clave ? ' aria-current="page"' : ''}>${texto}</a>`;

    const layout = document.createElement('div');
    layout.className = 'app-layout';
    layout.innerHTML = `
        <aside class="sidebar">
            <h1>Usuario</h1>
            <nav class="nav-menu">
                <div class="nav-item">Menú</div>
                ${link('index.html', 'dashboard', 'Dashboard')}
                <div class="nav-row">
                    ${link('inventarios.html', 'inventarios', 'Inventarios')}
                    <button class="nav-toggle" id="nav-toggle" aria-expanded="true" aria-label="Mostrar u ocultar inventarios">
                        <svg class="icon" viewBox="0 0 24 24"><path d="m6 9 6 6 6-6"/></svg>
                    </button>
                </div>
                <ul class="nav-sub" id="nav-inventarios"></ul>
                ${link('productos.html', 'productos', 'Productos')}
                ${link('insumos.html', 'insumos', 'Insumos')}
            </nav>
        </aside>
        <div class="scrim" id="scrim"></div>
        <div class="main-wrapper">
            <header class="topbar">
                <div class="topbar-left">
                    <button class="menu-btn" id="menu-btn" aria-label="Abrir menú">
                        <svg class="icon" viewBox="0 0 24 24"><path d="M4 7h16M4 12h16M4 17h16"/></svg>
                    </button>
                    <a href="index.html">
                        <img class="brand-logo" src="logo.png" alt="Elementos con alquimia">
                    </a>
                </div>
                <div class="topbar-controls">
                    <div class="search-bar">
                        <input type="text" id="buscar" aria-label="${esc(buscar)}" placeholder="${esc(buscar)}">
                        <span class="search-icon"></span>
                    </div>
                    <div class="user-profile">U</div>
                </div>
            </header>
        </div>`;

    // El contenido de la página se mueve dentro del layout
    layout.querySelector('.main-wrapper').appendChild(main);
    document.body.prepend(layout);

    // Submenú plegable y menú móvil
    document.getElementById('nav-toggle').addEventListener('click', e => {
        const ul = document.getElementById('nav-inventarios');
        ul.hidden = !ul.hidden;
        e.currentTarget.setAttribute('aria-expanded', !ul.hidden);
    });

    const alternarMenu = () => document.body.classList.toggle('menu-open');
    document.getElementById('menu-btn').addEventListener('click', alternarMenu);
    document.getElementById('scrim').addEventListener('click', alternarMenu);

    invActivoId = inventario;
    renderSidebar();
}


// =====================================================
// Datos de productos, insumos y recetas
// (los usan inventario.html y producto-insumos.html)
// Mismas claves de localStorage que productos.html e insumos.html.
// Los nombres son distintos a los de esas pantallas para no chocar con ellos.
// =====================================================
const LS_PRODUCTOS = 'eca_productos_v1';
const LS_INSUMOS = 'eca_insumos_v1';
const LS_RECETAS = 'eca_recetas_v1';   // { idProducto: [ { id, insumoId, cantidad, baja } ] }

const SEMILLA_PRODUCTOS = [
    { id: 1, nombre: 'Producto 1', precio: 150, stock: 10, baja: false },
    { id: 2, nombre: 'Producto 2', precio: 150, stock: 10, baja: false },
    { id: 3, nombre: 'Producto 3', precio: 150, stock: 10, baja: false }
];
const SEMILLA_INSUMOS = [
    { id: 1, nombre: 'Insumo 1', unidad: 'Kilo', stock: 2, baja: false },
    { id: 2, nombre: 'Insumo 2', unidad: 'Gramo', stock: 4, baja: false },
    { id: 3, nombre: 'Insumo 3', unidad: 'Litro', stock: 1, baja: false },
    { id: 4, nombre: 'Insumo 4', unidad: 'Kilo', stock: 2, baja: false },
    { id: 5, nombre: 'Insumo 5', unidad: 'Gramo', stock: 4, baja: false }
];
const SEMILLA_RECETAS = {
    1: [
        { id: 1, insumoId: 1, cantidad: 2, baja: false },
        { id: 2, insumoId: 2, cantidad: 4, baja: false },
        { id: 3, insumoId: 3, cantidad: 1, baja: false }
    ]
};

function guardarLS(key, valor) {
    try { localStorage.setItem(key, JSON.stringify(valor)); } catch (e) {}
}
