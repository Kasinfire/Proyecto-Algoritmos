// Subpaso 2 del horario: elegir las materias que vas a cursar.
// A la izquierda se busca en la oferta y se arma la lista "Tus materias"; a la derecha
// se ven las secciones de la materia enfocada en la semana, para decidir con el horario
// a la vista. Cada seccion con horario de una materia elegida es un bit del problema.

const MATERIAS = (() => {
  const el = Object.fromEntries([
    "buscar", "buscar-etiqueta", "nota-repetidas", "resultados",
    "elegidas-titulo", "bits", "elegidas", "secciones-titulo", "secciones-nota", "semana"
  ].map((id) => [id.replace(/-/g, "_"), document.getElementById(id)]));

  const COLORES = ["#0072BD", "#D95319", "#7E2F8E", "#2B9FD0", "#A2142F", "#4E8A22", "#B07A0C", "#4A4D57"];
  const ICONO_MAS = '<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" aria-hidden="true"><path d="M12 5v14M5 12h14"/></svg>';
  const ICONO_LISTO = '<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M5 12.5l4.5 4.5L19 7.5"/></svg>';
  const ICONO_QUITAR = '<svg width="10" height="10" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.6" stroke-linecap="round" aria-hidden="true"><path d="M6 6l12 12M18 6L6 18"/></svg>';

  const estado = {
    materias: new Map(),   // clave -> { clave, nombre, secciones, con_horario }
    elegidas: [],          // claves en el orden en que se agregaron
    colores: new Map(),    // clave -> color, fijo mientras la materia siga elegida
    enfocada: null,
    rango: { desde: 7, hasta: 21 },
    total_con_horario: 0
  };
  let avisar_cambio = () => {};

  const con_horario = SEMANA.con_horario;

  // ---------- Datos ----------

  function poner_oferta(secciones) {
    estado.materias = new Map();
    secciones.forEach((s) => {
      if (!estado.materias.has(s.clave)) {
        estado.materias.set(s.clave, { clave: s.clave, nombre: TEXTO.como_titulo(s.materia), secciones: [] });
      }
      estado.materias.get(s.clave).secciones.push(s);
    });
    estado.materias.forEach((m) => { m.con_horario = m.secciones.filter(con_horario).length; });
    estado.total_con_horario = secciones.filter(con_horario).length;
    estado.rango = SEMANA.rango_de_horas(secciones);

    elegir(estado.elegidas);
    el.buscar_etiqueta.textContent = `Buscar en ${estado.materias.size} materias`;
  }

  // ---------- Elegir y enfocar ----------

  function elegir(claves) {
    estado.elegidas = como_lista(claves).filter((c) => estado.materias.has(c));
    estado.colores.forEach((_, clave) => { if (!estado.elegidas.includes(clave)) estado.colores.delete(clave); });
    estado.elegidas.forEach(dar_color);
    if (!estado.materias.has(estado.enfocada)) estado.enfocada = estado.elegidas[0] ?? null;
    dibujar();
    avisar_cambio();
  }

  function dar_color(clave) {
    if (estado.colores.has(clave)) return;
    const usados = new Set(estado.colores.values());
    const libre = COLORES.find((c) => !usados.has(c)) ?? COLORES[estado.colores.size % COLORES.length];
    estado.colores.set(clave, libre);
  }

  function alternar(clave) {
    if (estado.elegidas.includes(clave)) {
      quitar(clave);
      return;
    }
    estado.elegidas.push(clave);
    dar_color(clave);
    estado.enfocada = clave;
    dibujar();
    avisar_cambio();
  }

  function quitar(clave) {
    estado.elegidas = estado.elegidas.filter((c) => c !== clave);
    estado.colores.delete(clave);
    if (estado.enfocada === clave) estado.enfocada = estado.elegidas.at(-1) ?? null;
    dibujar();
    avisar_cambio();
  }

  function enfocar(clave) {
    estado.enfocada = clave;
    dibujar();
  }

  function n_bits() {
    return estado.elegidas.reduce((n, c) => n + estado.materias.get(c).con_horario, 0);
  }

  // ---------- Dibujo ----------

  function dibujar() {
    dibujar_resultados();
    dibujar_elegidas();
    dibujar_semana();
  }

  function coincidencias() {
    const consulta = TEXTO.plano(el.buscar.value).trim();
    const todas = [...estado.materias.values()].sort((a, b) => a.nombre.localeCompare(b.nombre, "es"));
    if (!consulta) return todas;
    return todas.filter((m) => TEXTO.plano(`${m.nombre} ${m.clave}`).includes(consulta));
  }

  function dibujar_resultados() {
    const lista = coincidencias();
    el.resultados.innerHTML = lista.length ? lista.map(resultado).join("")
      : `<li class="sin-resultados">Ninguna materia con “${TEXTO.esc(el.buscar.value.trim())}”.</li>`;
    el.nota_repetidas.textContent = nota_de_repetidas(lista);
  }

  function resultado(m) {
    const elegida = estado.elegidas.includes(m.clave);
    const clases = ["resultado", elegida ? "agregada" : "", m.clave === estado.enfocada ? "enfocada" : ""].join(" ");
    const detalle = m.con_horario ? `${m.clave} · ${m.con_horario} secc.` : `${m.clave} · sin horario`;
    const accion = elegida ? "Quitar" : "Agregar";
    return `<li class="${clases}">
      <button type="button" class="resultado-ver" data-ver="${TEXTO.esc(m.clave)}">
        <span>${TEXTO.esc(m.nombre)}</span><small>${TEXTO.esc(detalle)}</small>
      </button>
      <button type="button" class="resultado-marca" data-alternar="${TEXTO.esc(m.clave)}"
        aria-label="${accion} ${TEXTO.esc(m.nombre)}" aria-pressed="${elegida}"
        ${m.con_horario || elegida ? "" : "disabled"}>${elegida ? ICONO_LISTO : ICONO_MAS}</button>
    </li>`;
  }

  // SIIAU tiene materias con el mismo nombre y distinta clave (una por plan de estudios).
  function nota_de_repetidas(lista) {
    const claves_por_nombre = new Map();
    lista.forEach((m) => claves_por_nombre.set(m.nombre, [...(claves_por_nombre.get(m.nombre) ?? []), m.clave]));
    const repetida = [...claves_por_nombre].find(([, claves]) => claves.length > 1);
    if (!repetida) return "";
    const [nombre, claves] = repetida;
    const ejemplo = claves.slice(0, 3).join(", ") + (claves.length > 3 ? "…" : "");
    return `Hay materias con el mismo nombre y distinta clave (${nombre}: ${ejemplo}). Busca por la clave de tu plan.`;
  }

  function dibujar_elegidas() {
    el.elegidas_titulo.textContent = `Tus materias (${estado.elegidas.length})`;
    el.bits.textContent = `n = ${n_bits()} bits`;
    el.elegidas.innerHTML = estado.elegidas.map((clave) => {
      const m = estado.materias.get(clave);
      const enfocada = clave === estado.enfocada ? " enfocada" : "";
      return `<li class="elegida${enfocada}" style="--color: ${estado.colores.get(clave)}">
        <button type="button" class="elegida-ver" data-ver="${TEXTO.esc(clave)}">
          <span>${TEXTO.esc(m.nombre)}</span><small>${m.con_horario} secc.</small>
        </button>
        <button type="button" class="elegida-quitar" data-quitar="${TEXTO.esc(clave)}"
          aria-label="Quitar ${TEXTO.esc(m.nombre)}">${ICONO_QUITAR}</button>
      </li>`;
    }).join("");
  }

  function dibujar_semana() {
    const m = estado.materias.get(estado.enfocada);
    const { desde, hasta } = estado.rango;

    el.secciones_titulo.textContent = m ? `${m.nombre} · ${m.clave}` : "Elige una materia";
    el.secciones_nota.textContent = m ? nota_de_secciones(m) : "";

    const color = (m && estado.colores.get(m.clave)) || "#4A4D57";
    const por_dia = SEMANA.DIAS.map((_, d) => SEMANA.bloques_del_dia(m ? m.secciones : [], d));

    el.semana.style.setProperty("--horas", hasta - desde);
    el.semana.style.setProperty("--tinte", SEMANA.tinte(color, 0.16));
    el.semana.style.setProperty("--tinte-fuerte", SEMANA.tinte(color, 0.3));
    el.semana.innerHTML = `
      <span></span>
      ${SEMANA.DIAS.map((d) => `<span class="dia-cabeza">${d}</span>`).join("")}
      ${SEMANA.etiquetas(estado.rango)}
      ${por_dia.map((bloques) => `<div class="dia">${bloques.map(bloque).join("")}</div>`).join("")}`;
  }

  function nota_de_secciones(m) {
    const partes = [TEXTO.plural(m.con_horario, "sección", "secciones")];
    const sin_cupo = m.secciones.filter((s) => con_horario(s) && s.disponibles <= 0).length;
    const sin_horario = m.secciones.length - m.con_horario;
    if (sin_cupo) partes.push(`${sin_cupo} sin cupo`);
    if (sin_horario) partes.push(`${sin_horario} sin horario`);
    return partes.join(" · ");
  }

  function bloque(b) {
    const sin_cupo = b.s.disponibles <= 0;
    const lugares = sin_cupo ? "sin cupo" : `cupo ${b.s.disponibles}`;
    // Con varias secciones encimadas no cabe todo: primero se va el NRC, luego el profesor.
    const encabezado = b.carriles > 1 ? b.s.seccion : `${b.s.seccion} · NRC ${b.s.nrc}`;
    const detalle = b.carriles > 2 ? "" : b.carriles > 1 ? lugares
      : `${TEXTO.profesor_corto(b.s.profesor)} · ${lugares}`;
    return `<div class="bloque${sin_cupo ? " sin-cupo" : ""}${b.carriles > 1 ? " angosto" : ""}" data-nrc="${TEXTO.esc(b.s.nrc)}"
      style="${SEMANA.caja(b, estado.rango)}" title="${TEXTO.esc(SEMANA.titulo(b))}">
      <b>${TEXTO.esc(encabezado)}</b>
      ${detalle ? `<span>${TEXTO.esc(detalle)}</span>` : ""}
    </div>`;
  }

  // ---------- Eventos ----------

  el.buscar.addEventListener("input", dibujar_resultados);

  el.resultados.addEventListener("click", (e) => {
    const marca = e.target.closest("[data-alternar]");
    const ver = e.target.closest("[data-ver]");
    if (marca) alternar(marca.dataset.alternar);
    else if (ver) enfocar(ver.dataset.ver);
  });

  el.elegidas.addEventListener("click", (e) => {
    const quitar_boton = e.target.closest("[data-quitar]");
    const ver = e.target.closest("[data-ver]");
    if (quitar_boton) quitar(quitar_boton.dataset.quitar);
    else if (ver) enfocar(ver.dataset.ver);
  });

  SEMANA.resaltar_secciones(el.semana);

  function al_cambiar(fn) {
    avisar_cambio = () => fn({ claves: [...estado.elegidas], colores: estado.elegidas.map((c) => estado.colores.get(c)) });
  }

  function resumen() {
    if (estado.elegidas.length === 0) return "Agrega las materias que vas a cursar.";
    return `De ${estado.total_con_horario} secciones, al problema entran solo las ${n_bits()} de tus materias.`;
  }

  function lista() { return n_bits() > 0; }

  function enfocar_busqueda() { el.buscar.focus(); }

  // Lo que necesita Preferencias: las materias elegidas con su color y sus secciones con horario.
  function elegidas() {
    return estado.elegidas.map((clave) => {
      const m = estado.materias.get(clave);
      return { clave, nombre: m.nombre, color: estado.colores.get(clave), secciones: m.secciones.filter(con_horario) };
    });
  }

  function rango() { return estado.rango; }

  return { poner_oferta, elegir, al_cambiar, resumen, lista, enfocar_busqueda, elegidas, rango };
})();
