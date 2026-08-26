/* ============================================================
   Portal del Socio COSPABI - utilidades compartidas.
   Antes estaban copiadas en Avisos, Pagos y Notificaciones.
   ============================================================ */
(function (window, $) {
    'use strict';

    // Todo el texto que sale de la BD (periodos, metodos, titulos y mensajes
    // que escribe un administrador) se inserta como TEXTO, nunca como HTML.
    // Sin esta escapada, una notificacion con etiquetas se ejecutaria en el
    // navegador del socio (XSS almacenado admin -> socio).
    function esc(v) {
        if (v === null || v === undefined) return '';
        return String(v).replace(/[&<>"']/g, function (c) {
            return { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c];
        });
    }

    // Importes en formato boliviano: 1.234,56
    function fmt(n) {
        return (n == null ? 0 : n).toLocaleString('es-BO', {
            minimumFractionDigits: 2,
            maximumFractionDigits: 2
        });
    }

    function bs(n) { return 'Bs. ' + fmt(n); }

    // Las fechas viajan como /Date(ms)/ en el JSON de System.Web.Mvc
    function parseNet(v) {
        if (!v) return null;
        var m = /\/Date\((\d+)\)\//.exec(v);
        var d = m ? new Date(parseInt(m[1], 10)) : new Date(v);
        return isNaN(d) ? null : d;
    }

    function ffecha(v) {
        var d = parseNet(v);
        return d ? d.toLocaleDateString('es-BO') : '-';
    }

    function ffechaLarga(v) {
        var d = parseNet(v);
        if (!d) return '-';
        return d.toLocaleDateString('es-BO', { day: '2-digit', month: 'short', year: 'numeric' });
    }

    function fhora(v) {
        var d = parseNet(v);
        return d ? d.toLocaleString('es-BO') : '-';
    }

    // Icono del sprite definido una sola vez en el _Layout
    function icono(nombre, clases) {
        return '<svg class="ic ' + (clases || '') + '" aria-hidden="true"><use href="#ic-' + nombre + '"></use></svg>';
    }

    window.Portal = {
        esc: esc,
        fmt: fmt,
        bs: bs,
        parseNet: parseNet,
        ffecha: ffecha,
        ffechaLarga: ffechaLarga,
        fhora: fhora,
        icono: icono
    };

})(window, jQuery);
