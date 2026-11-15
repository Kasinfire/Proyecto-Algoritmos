// Pantalla 5: resultados de una ejecucion terminada. Todo llega calculado de MATLAB.
//
// Eventos que llegan de MATLAB:
//   "datos"  { algoritmo: {id, nombre, siglas, individuos, simbolo},
//              problema: {nombre, dim, sentido, representacion, f_optimo, x_optimo},
//              parametros: [{nombre, etiqueta, corta, valor, comun}],
//              mejor_valor, mejor_solucion, iteraciones, motivo, evaluaciones, tiempo,
//              convergencia, mejoras: {iteracion, valor, solucion, total},
//              inicio, ruta, mapa, numero, n_guardadas }
//            mejor_solucion y mejoras.solucion traen a lo mas 3 coordenadas; inicio y ruta
//            solo x1, x2. mapa sale de mapa_de_busqueda.m ({tipo: 'ninguno'} si no es continuo).
//   "exportado" { texto, ok }
// Eventos que se mandan a MATLAB:
//   "lista", "exportar" { formato: 'csv' | 'json' }, "comparar", "ir_a_paso" { paso }, "ayuda"

const MOTIVOS = {
  max_iteraciones: "llegó al límite",
  convergencia: "paró sin mejora",
  detenido: "detenida a mano"
};

const el = Object.fromEntries([
  "subtitulo", "cuerpo", "escenario", "mapa-imagen", "mapa", "leyenda", "leyenda-inicio",
  "etiqueta-mejor", "mejor", "sentido", "etiqueta-solucion", "solucion", "optimo",
  "iteraciones", "motivo", "convergencia", "th-valor", "historial", "nota-historial",
  "configuracion", "estado", "exportar-csv", "exportar-json", "comparar"
].map((id) => [id.replace(/-/g, "_"), document.getElementById(id)]));

const pestanas = [...document.querySelectorAll('[role="tab"]')];

let datos = null;

// jsonencode manda un vector como [a, b] y una matriz como [[a, b], ...]; esto deja
// siempre una lista de filas.
function como_filas(valor) {
  return como_lista(valor).map((fila) => (Array.isArray(fila) ? fila : [fila]));
}

// Numeros que pueden venir como texto ('Infinity') desde numeros_para_js.m.
function numeros(valor) {
  return como_lista(valor).map(Number);
}

// dim: coordenadas que tiene el punto aunque x traiga menos.
function texto_punto(x, dim = x.length, max_coordenadas = 3) {
  const coords = x.slice(0, max_coordenadas).map(formato_corto);
  if (dim > max_coordenadas) coords.push("…");
  return dim === 1 ? coords[0] : `(${coords.join(", ")})`;
}

function valor_parametro(v) {
  return typeof v === "number" ? formato_corto(v) : String(v);
}

// ---------------------------------------------------------------- inicio

function iniciar(d) {
  d.mejor_valor = numeros(d.mejor_valor)[0];
  d.mejor_solucion = numeros(d.mejor_solucion);
  d.convergencia = numeros(d.convergencia);
  d.parametros = como_lista(d.parametros);
  d.problema.x_optimo = numeros(d.problema.x_optimo);
  d.mejoras.iteracion = numeros(d.mejoras.iteracion);
  d.mejoras.valor = numeros(d.mejoras.valor);
  d.mejoras.solucion = como_lista(d.mejoras.solucion).map(numeros);
  d.inicio = como_filas(d.inicio);
  d.ruta = como_filas(d.ruta);
  d.escala = escala_convergencia(d.convergencia);
  datos = d;

  dibujar_riel(document.getElementById("riel"), 4, Number(d.n_guardadas) || 0,
    (paso) => puente.enviar("ir_a_paso", { paso }));
  dibujar_textos();
  dibujar_lecturas();
  dibujar_historial();
  dibujar_configuracion();
  preparar_mapa();
  dibujar_graficas();
}

function dibujar_textos() {
  const { algoritmo, problema, numero, n_guardadas } = datos;
  const dims = problema.dim === 1 ? "una dimensión"
    : problema.representacion === "continuo" ? `${problema.dim} dimensiones` : `n = ${problema.dim}`;
  el.subtitulo.textContent = `${algoritmo.nombre} sobre ${problema.nombre}, ${dims}.`;
  if (datos.mapa.tipo === "superficie" && problema.dim > 2) {
    el.subtitulo.textContent += " El mapa es un corte en x₁, x₂ por la mejor solución.";
  }
  document.title = `Resultados · ${algoritmo.siglas}`;

  el.estado.textContent = numero > 0
    ? `Guardada como ejecución ${String(numero).padStart(2, "0")}.`
    : "Esta ejecución no se guardó para comparar.";
  el.comparar.disabled = !(n_guardadas > 0);
}

function dibujar_lecturas() {
  const { algoritmo, problema } = datos;
  const g = algoritmo.simbolo;
  el.etiqueta_mejor.textContent = `Mejor f(${g})`;
  el.mejor.textContent = formato_corto(datos.mejor_valor);
  el.sentido.textContent = problema.sentido === "max" ? "maximizando" : "minimizando";

  el.etiqueta_solucion.textContent = `Mejor solución ${g}`;
  // Arriba caben dos coordenadas con su exponente; el punto completo esta en Historial y el CSV.
  el.solucion.textContent = texto_punto(datos.mejor_solucion, problema.dim, 2);
  el.solucion.title = el.solucion.textContent;
  const x = problema.x_optimo;
  if (x.length === problema.dim) {
    const iguales = x.every((v) => v === x[0]);
    const punto = iguales && x.length > 2 ? `(${formato_corto(x[0])}, …)` : texto_punto(x);
    el.optimo.textContent = `óptimo: ${punto}`;
  } else if (Number.isFinite(Number(problema.f_optimo))) {
    el.optimo.textContent = `óptimo: f = ${formato_corto(Number(problema.f_optimo))}`;
  } else {
    el.optimo.textContent = "óptimo desconocido";
  }

  el.iteraciones.textContent = datos.iteraciones;
  el.motivo.textContent = MOTIVOS[datos.motivo] || datos.motivo;
}

function dibujar_historial() {
  const { iteracion, valor, solucion, total } = datos.mejoras;
  const g = datos.algoritmo.simbolo;
  el.th_valor.textContent = `Mejor f(${g})`;
  el.historial.innerHTML = iteracion.map((it, k) =>
    `<tr><td>${it}</td><td>${formato_corto(valor[k])}</td><td>${texto_punto(solucion[k], datos.problema.dim)}</td></tr>`
  ).join("");
  el.nota_historial.textContent = iteracion.length < total
    ? `Se muestran ${iteracion.length} de las ${total} veces que mejoró; el CSV trae todas las iteraciones.`
    : "";
}

function dibujar_configuracion() {
  const { algoritmo, parametros } = datos;
  const fila = (etiqueta, valor) => `<dt>${etiqueta}</dt><dd>${valor}</dd>`;
  const param = (p) => fila(`${p.etiqueta}${p.corta ? ` (${p.corta})` : ""}`, valor_parametro(p.valor));
  const tiempo = datos.tiempo < 1 ? `${formato_corto(datos.tiempo * 1000)} ms` : `${formato_corto(datos.tiempo)} s`;
  el.configuracion.innerHTML =
    `<span class="grupo">${algoritmo.siglas}</span>${parametros.filter((p) => !p.comun).map(param).join("")}` +
    `<span class="grupo">Comunes</span>${parametros.filter((p) => p.comun).map(param).join("")}` +
    `<span class="grupo">Ejecución</span>` +
    fila("Evaluaciones de f", formato_corto(datos.evaluaciones)) +
    fila("Tiempo", tiempo);
}

function preparar_mapa() {
  const mapa = datos.mapa;
  const hay_mapa = mapa.tipo !== "ninguno";
  el.cuerpo.classList.toggle("sin-mapa", !hay_mapa);
  el.leyenda.hidden = !hay_mapa;
  el.mapa_imagen.hidden = mapa.tipo !== "superficie";
  el.leyenda_inicio.textContent = `${datos.algoritmo.individuos} al inicio`;
  if (mapa.tipo === "superficie") {
    el.mapa_imagen.addEventListener("load", dibujar_escenario, { once: true });
    el.mapa_imagen.src = mapa.imagen;
  }
}

// ---------------------------------------------------------------- graficas

function dibujar_escenario() {
  if (!datos || datos.mapa.tipo === "ninguno") return;
  const caja = el.escenario.getBoundingClientRect(), ley = el.leyenda.getBoundingClientRect();
  dibujar_mapa(el.mapa, {
    mapa: datos.mapa,
    poblacion: datos.inicio,
    poblacion_tenue: true,
    mejor: datos.mejor_solucion,
    valor_mejor: datos.mejor_valor,
    ruta: datos.ruta,
    evitar: { x: ley.left - caja.left, y: ley.top - caja.top, w: ley.width, h: ley.height }
  });
}

function dibujar_graficas() {
  if (!datos) return;
  dibujar_escenario();
  const g = datos.algoritmo.simbolo;
  dibujar_convergencia(el.convergencia, datos.convergencia, datos.convergencia.length - 1,
    datos.iteraciones, datos.escala,
    `Mejor f(${g})${datos.escala.tipo === "log" ? ", escala log" : ""}`, false);
}

// ---------------------------------------------------------------- pestanas

function elegir_pestana(boton) {
  pestanas.forEach((b) => {
    const activa = b === boton;
    b.setAttribute("aria-selected", String(activa));
    b.tabIndex = activa ? 0 : -1;
    document.getElementById(b.getAttribute("aria-controls")).hidden = !activa;
  });
  dibujar_graficas();
}

pestanas.forEach((b, k) => {
  b.addEventListener("click", () => elegir_pestana(b));
  b.addEventListener("keydown", (e) => {
    const salto = { ArrowRight: 1, ArrowLeft: -1 }[e.key];
    if (!salto) return;
    const otra = pestanas[(k + salto + pestanas.length) % pestanas.length];
    otra.focus();
    elegir_pestana(otra);
  });
});

// ---------------------------------------------------------------- acciones

el.exportar_csv.addEventListener("click", () => puente.enviar("exportar", { formato: "csv" }));
el.exportar_json.addEventListener("click", () => puente.enviar("exportar", { formato: "json" }));
el.comparar.addEventListener("click", () => puente.enviar("comparar"));

new ResizeObserver(dibujar_graficas).observe(el.escenario);
new ResizeObserver(dibujar_graficas).observe(el.convergencia.parentElement);

puente.escuchar("datos", iniciar);
puente.escuchar("exportado", ({ texto, ok }) => {
  el.estado.textContent = texto;
  el.estado.classList.toggle("error", !ok);
});

puente.al_iniciar((con_matlab) => {
  if (con_matlab) {
    puente.enviar("lista");
  } else {
    puente.recibir("datos", DEMO_RESULTADOS.datos());
  }
});
