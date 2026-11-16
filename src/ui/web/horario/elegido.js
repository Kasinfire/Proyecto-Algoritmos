// Semana con un horario ya elegido (una solucion del problema). La comparten la ejecucion y
// los resultados del horario; todo llega de horario_para_ui.m y aqui solo se dibuja.
//
// h = { materias: [{clave, nombre, color}],
//       secciones: [{nrc, seccion, profesor, cupo, disponibles, materia, sesiones}],
//       preferencias: {entrada, salida, dias_libres}, cambios, soluciones }
// Cada solucion trae elegidas (indices de secciones), bits y su desglose de f.

const HORARIO = (() => {
  function preparar(h) {
    h.materias = como_lista(h.materias);
    h.secciones = como_lista(h.secciones).map((s) => ({
      ...s, sesiones: como_lista(s.sesiones), materia_ui: null
    }));
    h.secciones.forEach((s) => { s.materia_ui = h.materias[s.materia]; });
    h.cambios = como_lista(h.cambios).map(Number);
    h.soluciones = como_lista(h.soluciones).map((x) => ({
      ...x, elegidas: como_lista(x.elegidas).map(Number), bits: como_lista(x.bits).map(Number)
    }));
    h.preferencias.dias_libres = como_lista(h.preferencias.dias_libres).map(Boolean);
    h.rango = SEMANA.rango_de_horas(h.secciones);
    return h;
  }

  // La solucion vigente en la iteracion i: la del ultimo cambio que no la pasa.
  function indice_en(h, i) {
    let k = 0;
    while (k + 1 < h.cambios.length && h.cambios[k + 1] <= i) k++;
    return k;
  }

  function solucion_en(h, i) {
    return h.soluciones[indice_en(h, i)];
  }

  function secciones_de(h, solucion) {
    return solucion.elegidas.map((k) => h.secciones[k]);
  }

  // "L I 13:00–14:55"; con varias sesiones en horas distintas se separan con coma.
  function horario_texto(s) {
    return s.sesiones.map((x) => {
      const dias = [...x.dias].map((c, d) => (c && c !== "." ? SEMANA.INICIALES[d] : "")).filter(Boolean).join(" ");
      return `${dias} ${TEXTO.hhmm(x.inicio, true)}–${TEXTO.hhmm(x.fin, true)}`;
    }).join(", ");
  }

  function zona(de, a, rango) {
    if (a <= de) return "";
    const horas = rango.hasta - rango.desde;
    return `<span class="zona" style="top: ${(100 * (de - rango.desde)) / horas}%; height: ${(100 * (a - de)) / horas}%"></span>`;
  }

  // Las sesiones que comparten carril se enciman: eso es un choque y se raya.
  function bloque(b, rango, mini) {
    const m = b.s.materia_ui;
    const choque = b.carriles > 1;
    const clase = `bloque bloque-elegido${choque ? " choque angosto" : ""}`;
    const texto = mini ? "" : `<b>${TEXTO.esc(TEXTO.como_titulo(m.nombre))}</b>`
      + `<span>${TEXTO.esc(b.s.seccion)} · NRC ${TEXTO.esc(b.s.nrc)}</span>`;
    const titulo = mini ? "" : ` title="${TEXTO.esc(`${TEXTO.como_titulo(m.nombre)}\n${SEMANA.titulo(b)}`)}"`;
    return `<div class="${clase}" data-nrc="${TEXTO.esc(b.s.nrc)}" style="${SEMANA.caja(b, rango)}; --color: ${m.color}"${titulo}>${texto}</div>`;
  }

  // HTML de la semana. Con mini no hay horas ni textos (miniaturas de los momentos).
  function semana(h, solucion, mini = false) {
    const { rango, preferencias: p } = h;
    const secciones = secciones_de(h, solucion);
    const columnas = SEMANA.DIAS.map((_, d) => {
      const libre = p.dias_libres[d];
      const bloques = SEMANA.bloques_del_dia(secciones, d).map((b) => bloque(b, rango, mini)).join("");
      const zonas = libre ? '<span class="zona libre" style="top: 0; height: 100%"></span>'
        : zona(rango.desde, p.entrada, rango) + zona(p.salida, rango.hasta, rango);
      return `<div class="dia">${zonas}${bloques}</div>`;
    }).join("");
    if (mini) return columnas;
    return `<span></span>
      ${SEMANA.DIAS.map((d, i) => `<span class="dia-cabeza${p.dias_libres[i] ? " libre" : ""}">${d}</span>`).join("")}
      ${SEMANA.etiquetas(rango)}
      ${columnas}`;
  }

  function dibujar_semana(contenedor, h, solucion, mini = false) {
    contenedor.classList.add("semana");
    contenedor.classList.toggle("mini", mini);
    contenedor.style.setProperty("--horas", h.rango.hasta - h.rango.desde);
    contenedor.innerHTML = semana(h, solucion, mini);
  }

  function leyenda(h) {
    const hay_libre = h.preferencias.dias_libres.some(Boolean);
    return [
      '<li><i class="muestra muestra-choque"></i>Choque</li>',
      '<li><i class="muestra muestra-fuera"></i>Fuera de tu rango</li>',
      hay_libre ? '<li><i class="muestra muestra-libre"></i>Día libre</li>' : ""
    ].join("");
  }

  return { preparar, indice_en, solucion_en, secciones_de, horario_texto, dibujar_semana, leyenda };
})();
