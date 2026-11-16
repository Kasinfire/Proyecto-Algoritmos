// Cuentas de la semana que comparten Materias y Preferencias: horas en minutos, el rango de
// horas de la oferta y el reparto en carriles de las sesiones que se enciman.

const SEMANA = (() => {
  const DIAS = ["Lun", "Mar", "Mié", "Jue", "Vie", "Sáb"];
  const INICIALES = ["L", "M", "I", "J", "V", "S"];

  const con_horario = (s) => como_lista(s.sesiones).length > 0;

  // 1455 -> 895. SIIAU termina las clases a las :55; fin() lo redondea a la hora.
  function minutos(hhmm) { return Math.floor(hhmm / 100) * 60 + (hhmm % 100); }
  function fin(x) { return minutos(x.fin) + 5; }

  // Horas que abarca la oferta completa, para que la escala no cambie entre materias.
  function rango_de_horas(secciones) {
    const sesiones = secciones.flatMap((s) => como_lista(s.sesiones));
    if (sesiones.length === 0) return { desde: 7, hasta: 21 };
    const desde = Math.floor(Math.min(...sesiones.map((x) => minutos(x.inicio))) / 60);
    const hasta = Math.ceil(Math.max(...sesiones.map(fin)) / 60);
    return { desde: Math.min(desde, 7), hasta: Math.max(hasta, 21) };
  }

  function etiquetas(rango) {
    const horas = rango.hasta - rango.desde;
    const lista = [];
    for (let h = rango.desde; h <= rango.hasta; h += 2) {
      lista.push(`<span class="hora" style="top: ${(100 * (h - rango.desde)) / horas}%">${String(h).padStart(2, "0")}:00</span>`);
    }
    return `<div class="horas" aria-hidden="true">${lista.join("")}</div>`;
  }

  // Sesiones de un dia con su carril: las que se enciman se reparten el ancho de la columna.
  function bloques_del_dia(secciones, d) {
    const sesiones = secciones.flatMap((s) => como_lista(s.sesiones)
      .filter((x) => x.dias[d] && x.dias[d] !== ".")
      .map((x) => ({ s, x, ini: minutos(x.inicio), fin: fin(x) })))
      .sort((a, b) => a.ini - b.ini || a.fin - b.fin);

    let grupo = [];
    let fin_del_grupo = -1;
    const cerrar_grupo = () => {
      const carriles = [];
      grupo.forEach((b) => {
        let k = carriles.findIndex((f) => f <= b.ini);
        if (k < 0) k = carriles.length;
        carriles[k] = b.fin;
        b.carril = k;
      });
      grupo.forEach((b) => { b.carriles = carriles.length; });
      grupo = [];
    };
    sesiones.forEach((b) => {
      if (b.ini >= fin_del_grupo) cerrar_grupo();
      grupo.push(b);
      fin_del_grupo = Math.max(fin_del_grupo, b.fin);
    });
    cerrar_grupo();
    return sesiones;
  }

  // Posicion de un bloque en % de la columna del dia.
  function caja(b, rango) {
    const total = (rango.hasta - rango.desde) * 60;
    const ancho = 100 / b.carriles;
    return `top: ${(100 * (b.ini - rango.desde * 60)) / total}%; height: ${(100 * (b.fin - b.ini)) / total}%;`
      + ` left: ${ancho * b.carril}%; width: ${ancho}%`;
  }

  function titulo(b) {
    return [
      `${b.s.seccion} · NRC ${b.s.nrc}`,
      `${TEXTO.hhmm(b.x.inicio, true)}-${TEXTO.hhmm(b.x.fin, true)} · ${b.x.edificio} ${b.x.aula}`,
      b.s.profesor || "Sin profesor",
      `${b.s.disponibles} de ${b.s.cupo} lugares`
    ].join("\n");
  }

  function tinte(hex, alfa) {
    const [r, g, b] = [1, 3, 5].map((i) => parseInt(hex.slice(i, i + 2), 16));
    return `rgba(${r}, ${g}, ${b}, ${alfa})`;
  }

  // Al pasar sobre una sesion se resaltan las demas sesiones de la misma seccion.
  function resaltar_secciones(semana) {
    semana.addEventListener("mouseover", (e) => {
      const b = e.target.closest(".bloque");
      semana.querySelectorAll(".bloque").forEach((x) => {
        x.classList.toggle("resaltado", Boolean(b) && x.dataset.nrc === b.dataset.nrc);
      });
      semana.classList.toggle("con-resalte", Boolean(b));
    });
    semana.addEventListener("mouseleave", () => {
      semana.classList.remove("con-resalte");
      semana.querySelectorAll(".resaltado").forEach((x) => x.classList.remove("resaltado"));
    });
  }

  return { DIAS, INICIALES, con_horario, minutos, rango_de_horas, etiquetas, bloques_del_dia,
    caja, titulo, tinte, resaltar_secciones };
})();
