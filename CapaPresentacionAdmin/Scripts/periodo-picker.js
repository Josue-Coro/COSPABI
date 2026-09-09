/*
 * PeriodoPicker — selector de períodos MM/yyyy para el admin de COSPABI.
 *
 * Reemplaza visualmente un <select> de períodos por un botón + panel con
 * navegación por año y una grilla de 12 meses. El <select> original sigue
 * siendo la fuente de verdad: queda oculto, conserva su id/value/onchange y
 * las vistas siguen leyéndolo con $('#selPeriodo').val() sin cambios.
 *
 * Uso: agregar data-periodo-picker al <select>. Las <option> se leen tal
 * como están (texto "MM/yyyy"); si el select tiene una opción con value=""
 * ("Todos los períodos", "-- Seleccione --"), se ofrece como fila especial.
 * Las opciones que se agregan después por AJAX se detectan solas.
 */
(function () {
    'use strict';

    var MESES = ['Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
                 'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'];
    var MESES_CORTO = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
                       'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];

    var abierto = null; // instancia con el panel desplegado

    function parsePeriodo(txt) {
        var m = /^(\d{2})\/(\d{4})$/.exec((txt || '').trim());
        if (!m) return null;
        return { mes: parseInt(m[1], 10), anio: parseInt(m[2], 10) };
    }

    function etiquetaLarga(p) { return MESES[p.mes - 1] + ' ' + p.anio; }

    function Picker(select) {
        this.select = select;
        this.opciones = [];   // { value, mes, anio }
        this.vacia = null;    // { value:'', texto } si existe opción "todos"/"seleccione"
        this.anioVista = null;
        this.construir();
        this.leerOpciones();
        this.observar();
    }

    Picker.prototype.construir = function () {
        var s = this.select;
        var wrap = document.createElement('div');
        wrap.className = 'pp-wrap';

        var btn = document.createElement('button');
        btn.type = 'button';
        btn.className = 'pp-btn';
        btn.setAttribute('aria-haspopup', 'dialog');
        btn.setAttribute('aria-expanded', 'false');
        btn.innerHTML =
            '<svg class="pp-ico" fill="none" stroke="currentColor" viewBox="0 0 24 24">' +
              '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" ' +
              'd="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z"/></svg>' +
            '<span class="pp-label"></span>' +
            '<svg class="pp-chev" fill="none" stroke="currentColor" viewBox="0 0 24 24">' +
              '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7"/></svg>';

        var panel = document.createElement('div');
        panel.className = 'pp-panel';
        panel.setAttribute('role', 'dialog');
        panel.hidden = true;
        panel.innerHTML =
            '<div class="pp-head">' +
              '<button type="button" class="pp-nav pp-prev" aria-label="Año anterior">' +
                '<svg fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7"/></svg>' +
              '</button>' +
              '<span class="pp-anio"></span>' +
              '<button type="button" class="pp-nav pp-next" aria-label="Año siguiente">' +
                '<svg fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7"/></svg>' +
              '</button>' +
            '</div>' +
            '<div class="pp-grid"></div>' +
            '<div class="pp-foot" hidden><button type="button" class="pp-todos"></button></div>';

        s.parentNode.insertBefore(wrap, s);
        wrap.appendChild(s);
        wrap.appendChild(btn);
        wrap.appendChild(panel);
        s.classList.add('pp-hidden');
        if (s.classList.contains('w-full')) wrap.classList.add('pp-block');

        this.wrap = wrap;
        this.btn = btn;
        this.panel = panel;
        this.lbl = btn.querySelector('.pp-label');
        this.anioEl = panel.querySelector('.pp-anio');
        this.grid = panel.querySelector('.pp-grid');
        this.foot = panel.querySelector('.pp-foot');
        this.btnTodos = panel.querySelector('.pp-todos');

        var self = this;
        btn.addEventListener('click', function (e) { e.stopPropagation(); self.toggle(); });
        panel.addEventListener('click', function (e) { e.stopPropagation(); });
        panel.querySelector('.pp-prev').addEventListener('click', function () { self.moverAnio(-1); });
        panel.querySelector('.pp-next').addEventListener('click', function () { self.moverAnio(1); });
        this.btnTodos.addEventListener('click', function () { self.elegir(''); });
        s.addEventListener('change', function () { self.pintarLabel(); if (!self.panel.hidden) self.pintarGrid(); });
        btn.addEventListener('keydown', function (e) {
            if (e.key === 'ArrowDown' || e.key === 'Enter' || e.key === ' ') { e.preventDefault(); self.abrir(); }
        });
        panel.addEventListener('keydown', function (e) {
            if (e.key === 'Escape') { self.cerrar(); self.btn.focus(); }
            if (e.key === 'ArrowLeft' && e.altKey) self.moverAnio(-1);
            if (e.key === 'ArrowRight' && e.altKey) self.moverAnio(1);
        });
    };

    Picker.prototype.leerOpciones = function () {
        var ops = [], vacia = null;
        Array.prototype.forEach.call(this.select.options, function (o) {
            if (o.value === '') { vacia = { value: '', texto: o.textContent.trim() }; return; }
            var p = parsePeriodo(o.textContent);
            if (p) ops.push({ value: o.value, mes: p.mes, anio: p.anio });
        });
        this.opciones = ops;
        this.vacia = vacia;
        this.anios = ops.map(function (o) { return o.anio; })
                        .filter(function (a, i, arr) { return arr.indexOf(a) === i; })
                        .sort(function (a, b) { return a - b; });
        this.btn.disabled = ops.length === 0 && !vacia;
        this.pintarLabel();
        if (!this.panel.hidden) this.pintarGrid();
    };

    Picker.prototype.observar = function () {
        var self = this;
        if (!window.MutationObserver) return;
        new MutationObserver(function () { self.leerOpciones(); })
            .observe(this.select, { childList: true, subtree: true, characterData: true });
    };

    Picker.prototype.seleccionada = function () {
        var v = this.select.value;
        for (var i = 0; i < this.opciones.length; i++) if (this.opciones[i].value === v) return this.opciones[i];
        return null;
    };

    Picker.prototype.pintarLabel = function () {
        var sel = this.seleccionada();
        if (sel) {
            this.lbl.textContent = etiquetaLarga(sel);
            this.btn.classList.add('pp-has-value');
        } else {
            this.lbl.textContent = this.vacia ? this.vacia.texto : 'Seleccionar período';
            this.btn.classList.remove('pp-has-value');
        }
    };

    Picker.prototype.pintarGrid = function () {
        var self = this;
        var sel = this.seleccionada();
        if (this.anioVista === null || this.anios.indexOf(this.anioVista) === -1) {
            this.anioVista = sel ? sel.anio : (this.anios.length ? this.anios[this.anios.length - 1] : new Date().getFullYear());
        }
        this.anioEl.textContent = this.anioVista;
        this.panel.querySelector('.pp-prev').disabled = this.anios.indexOf(this.anioVista) <= 0;
        this.panel.querySelector('.pp-next').disabled = this.anios.indexOf(this.anioVista) >= this.anios.length - 1;

        var porMes = {};
        this.opciones.forEach(function (o) { if (o.anio === self.anioVista) porMes[o.mes] = o; });

        var html = '';
        for (var m = 1; m <= 12; m++) {
            var o = porMes[m];
            var cls = 'pp-mes' + (o ? '' : ' pp-off') + (sel && o && o.value === sel.value ? ' pp-sel' : '');
            html += '<button type="button" class="' + cls + '"' + (o ? ' data-value="' + o.value + '"' : ' disabled') +
                    ' title="' + MESES[m - 1] + ' ' + this.anioVista + '">' + MESES_CORTO[m - 1] + '</button>';
        }
        this.grid.innerHTML = html;
        Array.prototype.forEach.call(this.grid.querySelectorAll('.pp-mes[data-value]'), function (b) {
            b.addEventListener('click', function () { self.elegir(b.getAttribute('data-value')); });
        });

        if (this.vacia) {
            this.foot.hidden = false;
            this.btnTodos.textContent = this.vacia.texto;
            this.btnTodos.classList.toggle('pp-sel', !sel);
        } else {
            this.foot.hidden = true;
        }
    };

    Picker.prototype.moverAnio = function (d) {
        var i = this.anios.indexOf(this.anioVista) + d;
        if (i < 0 || i >= this.anios.length) return;
        this.anioVista = this.anios[i];
        this.pintarGrid();
    };

    Picker.prototype.elegir = function (value) {
        if (this.select.value !== value) {
            this.select.value = value;
            // Evento nativo: dispara tanto onchange="..." inline como $(sel).on('change')
            this.select.dispatchEvent(new Event('change', { bubbles: true }));
        }
        this.pintarLabel();
        this.cerrar();
        this.btn.focus();
    };

    Picker.prototype.abrir = function () {
        if (abierto && abierto !== this) abierto.cerrar();
        this.anioVista = null;
        this.pintarGrid();
        this.panel.hidden = false;
        this.btn.setAttribute('aria-expanded', 'true');
        abierto = this;
        var f = this.grid.querySelector('.pp-sel') || this.grid.querySelector('.pp-mes:not([disabled])');
        if (f) f.focus();
    };

    Picker.prototype.cerrar = function () {
        this.panel.hidden = true;
        this.btn.setAttribute('aria-expanded', 'false');
        if (abierto === this) abierto = null;
    };

    Picker.prototype.toggle = function () { this.panel.hidden ? this.abrir() : this.cerrar(); };

    document.addEventListener('click', function () { if (abierto) abierto.cerrar(); });

    function init(root) {
        Array.prototype.forEach.call((root || document).querySelectorAll('select[data-periodo-picker]'), function (s) {
            if (!s._periodoPicker) s._periodoPicker = new Picker(s);
        });
    }

    window.PeriodoPicker = {
        init: init,
        /** Vuelve a leer value/options si el select se cambió por código sin evento (p.ej. $(sel).val(x)). */
        sync: function (sel) {
            var s = typeof sel === 'string' ? document.querySelector(sel) : sel;
            if (s && s._periodoPicker) s._periodoPicker.leerOpciones();
        }
    };

    if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', function () { init(); });
    else init();
})();
