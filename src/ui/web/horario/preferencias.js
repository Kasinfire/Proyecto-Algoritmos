// Subpaso 3 del horario: como quieres tu horario.
// A la izquierda las preferencias y la funcion objetivo que resulta; a la derecha todas las
// secciones de tus materias en la semana, con lo que vas a evitar rayado encima.

const PREFERENCIAS = (() => {
  const el = Object.fromEntries([
    "preferencias", "dias-libres", "muertas", "muertas-valor", "solo-cupo-pref", "formula",
    "opciones-titulo", "leyenda", "semana-opciones"
  ].map((id) => [id.replace(/-/g, "_"), document.getElementById(id)]));

  // Pesos fijos de la funcion objetivo; el de las horas muertas lo elige la persona.
  const PESOS = { fuera: 2, dia_libre: 5, carga: 10, choque: 100 };
  const SUPER = "⁰¹²³⁴⁵⁶⁷⁸⁹";

  const valores = {
    entrada: 9, salida: 19, dias_libres: [false, false, false, false, false, false],
    peso_muertas: 1, max_materias_dia: 3, max_horas_seguidas: 4, solo_cupo: true
  };
  const estado = { materias: [], rango: { desde: 7, hasta: 21 } };
  let avisar_cambio = () => {};

  // Limites de cada contador; dependen de la oferta y de las materias elegidas.
  const LIMITES = {
    entrada: () => [estado.rango.desde, valores.salida - 1],
    salida: () => [valores.entrada + 1, estado.rango.hasta],
    max_materias_dia: () => [1, Math.max(1, estado.materias.length)],
    max_horas_seguidas: () => [1, 10]
  };
  const FORMATO = {
    entrada: (v) => `${String(v).padStart(2, "0")}:00`,
    salida: (v) => `${String(v).padStart(2, "0")}:00`,
    max_materias_dia: String,
    max_horas_seguidas: (v) => `${v} h`
  };

  // ---------- Datos ----------

  function poner(materias, rango) {
    estado.materias = materias;
    estado.rango = rango;
    Object.keys(LIMITES).forEach((clave) => { valores[clave] = acotar(clave, valores[clave]); });
    dibujar();
    avisar_cambio();
  }

  function acotar(clave, v) {
    const [menor, mayor] = LIMITES[clave]();
    return Math.min(mayor, Math.max(menor, v));
  }

  function cambiar(clave, v) {
    valores[clave] = v;
    dibujar();
    avisar_cambio();
  }

  const n_bits = () => estado.materias.reduce((n, m) => n + m.secciones.length, 0);
  const sin_lugar = (s) => valores.solo_cupo && s.disponibles <= 0;

  // ---------- Dibujo ----------

  function dibujar() {
    dibujar_controles();
    dibujar_formula();
    dibujar_opciones();
  }

  function dibujar_controles() {
    el.preferencias.querySelectorAll("[data-contador]").forEach((caja) => {
      const clave = caja.dataset.contador;
      const [menor, mayor] = LIMITES[clave]();
      caja.querySelector("output").textContent = FORMATO[clave](valores[clave]);
      caja.querySelector("[data-paso='-1']").disabled = valores[clave] <= menor;
      caja.querySelector("[data-paso='1']").disabled = valores[clave] >= mayor;
    });
    el.dias_libres.querySelectorAll("[data-dia]").forEach((b) => {
      b.setAttribute("aria-pressed", String(valores.dias_libres[Number(b.dataset.dia)]));
    });
    el.muertas.querySelectorAll("[data-peso]").forEach((b) => {
      const peso = Number(b.dataset.peso);
      b.classList.toggle("lleno", peso <= valores.peso_muertas);
      b.setAttribute("aria-checked", String(peso === valores.peso_muertas));
      b.tabIndex = peso === valores.peso_muertas ? 0 : -1;
    });
    el.muertas_valor.textContent = valores.peso_muertas;
    el.solo_cupo_pref.checked = valores.solo_cupo;
  }

  // Un renglon por castigo, en palabras; los que no aplican (peso 0, sin dias libres) no salen.
  function dibujar_formula() {
    const hora = (h) => String(h).padStart(2, "0");
    const castigos = [
      [valores.peso_muertas, "Horas muertas"],
      [PESOS.fuera, `Horas fuera de ${hora(valores.entrada)}–${hora(valores.salida)}`],
      [valores.dias_libres.some(Boolean) ? PESOS.dia_libre : 0, "Clases en tus días libres"],
      [PESOS.carga, "Materias o horas seguidas de más"],
      [PESOS.choque, "Choques o materia sin sección", "regla"]
    ].filter(([peso]) => peso > 0);
    el.formula.innerHTML = castigos.map(([peso, texto, clase]) =>
      `<li${clase ? ` class="${clase}"` : ""}><span>${TEXTO.esc(texto)}</span><b>×${peso}</b></li>`).join("");
  }

  function dibujar_opciones() {
    const n = n_bits();
    el.opciones_titulo.textContent = `${TEXTO.plural(n, "sección", "secciones")} de ${TEXTO.plural(estado.materias.length, "materia", "materias")}`;
    el.leyenda.innerHTML = estado.materias.map((m) =>
      `<li style="--color: ${m.color}">${TEXTO.esc(m.nombre)}</li>`).join("");

    const { desde, hasta } = estado.rango;
    const horas = hasta - desde;
    const secciones = estado.materias.flatMap((m) => m.secciones.map((s) => ({ ...s, materia_ui: m })));
    const columnas = SEMANA.DIAS.map((_, d) => {
      const libre = valores.dias_libres[d];
      const bloques = SEMANA.bloques_del_dia(secciones, d).map(bloque).join("");
      const zonas = libre ? `<span class="zona libre" style="top: 0; height: 100%"></span>`
        : zona(desde, valores.entrada, desde, horas) + zona(valores.salida, hasta, desde, horas);
      return `<div class="dia${libre ? " dia-libre" : ""}">${bloques}${zonas}</div>`;
    });

    el.semana_opciones.style.setProperty("--horas", horas);
    el.semana_opciones.innerHTML = `
      <span></span>
      ${SEMANA.DIAS.map((d, i) => `<span class="dia-cabeza${valores.dias_libres[i] ? " libre" : ""}">${d}</span>`).join("")}
      ${SEMANA.etiquetas(estado.rango)}
      ${columnas.join("")}`;
  }

  function zona(de, a, desde, horas) {
    if (a <= de) return "";
    return `<span class="zona" style="top: ${(100 * (de - desde)) / horas}%; height: ${(100 * (a - de)) / horas}%"></span>`;
  }

  // Con muchas secciones encimadas solo cabe la seccion, y con mas ni eso.
  function bloque(b) {
    const m = b.s.materia_ui;
    const apagado = sin_lugar(b.s);
    const texto = b.carriles <= 2 ? `${TEXTO.siglas(m.nombre)} ${b.s.seccion}`
      : b.carriles <= 5 ? b.s.seccion : "";
    return `<div class="bloque opcion-bloque${apagado ? " sin-cupo" : ""}" data-nrc="${TEXTO.esc(b.s.nrc)}"
      style="${SEMANA.caja(b, estado.rango)}; --color: ${m.color}"
      title="${TEXTO.esc(`${m.nombre}\n${SEMANA.titulo(b)}`)}">${TEXTO.esc(texto)}</div>`;
  }

  // ---------- Eventos ----------

  el.preferencias.addEventListener("click", (e) => {
    const paso = e.target.closest("[data-paso]");
    const dia = e.target.closest("[data-dia]");
    const peso = e.target.closest("[data-peso]");
    if (paso) {
      const clave = paso.closest("[data-contador]").dataset.contador;
      cambiar(clave, acotar(clave, valores[clave] + Number(paso.dataset.paso)));
    } else if (dia) {
      const d = Number(dia.dataset.dia);
      const libres = [...valores.dias_libres];
      libres[d] = !libres[d];
      cambiar("dias_libres", libres);
    } else if (peso) {
      cambiar("peso_muertas", Number(peso.dataset.peso));
    }
  });

  // Flechas en la escala de horas muertas, como en un grupo de radios.
  el.muertas.addEventListener("keydown", (e) => {
    const paso = { ArrowRight: 1, ArrowUp: 1, ArrowLeft: -1, ArrowDown: -1 }[e.key];
    if (!paso) return;
    e.preventDefault();
    const v = Math.min(5, Math.max(0, valores.peso_muertas + paso));
    cambiar("peso_muertas", v);
    el.muertas.querySelector(`[data-peso="${v}"]`).focus();
  });

  el.solo_cupo_pref.addEventListener("change", () => cambiar("solo_cupo", el.solo_cupo_pref.checked));

  SEMANA.resaltar_secciones(el.semana_opciones);

  // ---------- Para horario.js ----------

  function al_cambiar(fn) { avisar_cambio = () => fn({ ...valores, dias_libres: [...valores.dias_libres] }); }

  function resumen() {
    const n = String(n_bits()).split("").map((c) => SUPER[Number(c)]).join("");
    return ["x ∈ {0,1}" + n, "una sección por materia", "sin choques",
      valores.solo_cupo ? "solo secciones con cupo" : ""].filter(Boolean).join(" · ");
  }

  // Materias que se quedan sin opcion con lo elegido: f las castiga, pero conviene avisar.
  function aviso() {
    const sin_opcion = estado.materias.filter((m) => m.secciones.every(sin_lugar));
    if (sin_opcion.length === 0) return "";
    const nombres = sin_opcion.map((m) => m.nombre);
    const lista = nombres.length > 2 ? `${nombres.slice(0, 2).join(", ")} y ${nombres.length - 2} más` : nombres.join(" y ");
    return `${lista} no ${nombres.length === 1 ? "tiene" : "tienen"} secciones con cupo.`;
  }

  return { poner, al_cambiar, resumen, aviso };
})();
