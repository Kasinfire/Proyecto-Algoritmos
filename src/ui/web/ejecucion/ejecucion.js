// Pantalla 4: ejecucion. MATLAB corre el algoritmo completo y manda el historial;
// aqui solo se reproduce, por eso se puede pausar, adelantar y regresar.
//
// Eventos que llegan de MATLAB:
//   "datos"  { algoritmo: {id, nombre, siglas, individuos, simbolo, continuidad},
//              problema: {nombre, dim, lb, ub, sentido, representacion, f_optimo, x_optimo},
//              parametros: [{nombre, etiqueta, corta, valor, comun}], iteraciones, motivo,
//              historial: {mejor_valor, mejor_solucion, distancia, poblacion,
//                          paso_poblacion, n_individuos}, mapa, n_guardadas }
//            mejor_solucion trae a lo mas 3 coordenadas y distancia es al optimo ([] si
//            no se conoce). poblacion trae solo x1 y x2 de cada solucion, de una iteracion
//            cada paso_poblacion (mas la ultima) y a lo mas 500 por iteracion.
//            mapa sale de mapa_de_busqueda.m ({tipo: 'ninguno'} si no es continuo).
//   "aviso"  { texto }   (el algoritmo fallo)
// Eventos que se mandan a MATLAB:
//   "lista", "resultados" { iteracion }, "regresar", "ir_a_paso" { paso }, "comparar", "ayuda"

const SEGUNDOS_POR_EJECUCION = 14;
const VENTANA_CAMBIO = 10;
const MS_POR_CUADRO = 33;

const estado = {
  datos: null,
  total: 0,
  t: 0,                 // iteracion actual; con decimales mientras se anima
  reproduciendo: false,
  alcanzada: 0,         // la iteracion mas lejana que ya se vio (revela los momentos)
  detenido_en: null,    // iteracion donde se presiono Detener
  ultimo_cuadro: 0,
  temporizador: null,
  escala: null,
  imagen: null,         // imagen del mapa ya cargada, para las miniaturas
  cambios_ruta: []      // iteraciones donde el mejor cambio de lugar (la ruta del mapa)
};

const el = Object.fromEntries([
  "titulo", "subtitulo", "escenario", "mapa-imagen", "mapa", "barra-color", "z-max", "z-min",
  "degradado", "leyenda", "leyenda-poblacion", "mensaje-mapa", "iteracion", "total",
  "etiqueta-mejor", "mejor", "cambio", "etiqueta-posicion", "posicion", "distancia",
  "etiqueta-parametros", "parametros", "ver-configuracion", "configuracion",
  "cerrar-configuracion", "lista-configuracion", "convergencia", "momentos", "reiniciar",
  "anterior", "reproducir", "siguiente", "detener", "hitos", "pista", "regla", "avance",
  "vedado", "perilla", "estado", "regresar", "resultados"
].map((id) => [id.replace(/-/g, "_"), document.getElementById(id)]));

// jsonencode manda un vector como [a, b] y una matriz como [[a, b], ...]; esto deja
// siempre una lista de filas.
function como_filas(valor) {
  const lista = como_lista(valor);
  return lista.map((fila) => (Array.isArray(fila) ? fila : [fila]));
}

function fin() {
  return estado.detenido_en ?? estado.total;
}

function hist() {
  return estado.datos.historial;
}

function momentos() {
  const n = estado.total;
  return [
    { nombre: "Inicio", corto: "Inicio", it: 0 },
    { nombre: "⅓", corto: "1/3", it: Math.round(n / 3) },
    { nombre: "⅔", corto: "2/3", it: Math.round(2 * n / 3) },
    { nombre: "Final", corto: "Final", it: fin() }
  ];
}

// dim: coordenadas que tiene el punto aunque x traiga menos.
function texto_punto(x, dim = x.length, max_coordenadas = 3) {
  const coords = x.slice(0, max_coordenadas).map(formato_corto);
  if (dim > max_coordenadas) coords.push("…");
  return dim === 1 ? coords[0] : `(${coords.join(", ")})`;
}

// ---------------------------------------------------------------- inicio

function iniciar(datos) {
  const h = datos.historial;
  h.mejor_valor = como_lista(h.mejor_valor).map(Number);
  h.mejor_solucion = como_lista(h.mejor_solucion).map((x) => como_lista(x).map(Number));
  h.distancia = como_lista(h.distancia).map((v) => (v === null ? NaN : Number(v)));
  h.poblacion = como_lista(h.poblacion).map(como_filas);
  h.paso_poblacion = Number(h.paso_poblacion) || 1;
  datos.parametros = como_lista(datos.parametros);
  datos.problema.x_optimo = como_lista(datos.problema.x_optimo);

  estado.datos = datos;
  estado.total = Number(datos.iteraciones);
  estado.escala = escala_convergencia(h.mejor_valor);
  estado.t = 0;
  estado.alcanzada = 0;
  estado.detenido_en = null;
  estado.cambios_ruta = h.mejor_solucion.map((x, k) => k).filter((k) => k === 0
    || h.mejor_solucion[k].slice(0, 2).some((v, j) => v !== h.mejor_solucion[k - 1][j]));

  dibujar_riel(document.getElementById("riel"), 3, Number(datos.n_guardadas) || 0,
    (paso) => puente.enviar("ir_a_paso", { paso }));
  dibujar_textos();
  preparar_mapa();
  dibujar_regla();
  [el.reiniciar, el.anterior, el.reproducir, el.siguiente, el.detener].forEach((b) => { b.disabled = false; });
  actualizar(true);
}

function dibujar_textos() {
  const { algoritmo, problema, parametros } = estado.datos;
  const verbo = problema.sentido === "max" ? "maximizando" : "minimizando";
  const dims = problema.dim === 1 ? "una dimensión" : `${problema.dim} dimensiones`;
  el.titulo.textContent = algoritmo.nombre;
  el.subtitulo.textContent = problema.representacion === "continuo"
    ? `${problema.nombre} en ${dims}, ${verbo} dentro de [${formato_corto(problema.lb)}, ${formato_corto(problema.ub)}]`
    : `${problema.nombre} con n = ${problema.dim}, ${verbo}`;
  document.title = `Ejecución · ${algoritmo.siglas}`;

  const g = algoritmo.simbolo;
  el.etiqueta_mejor.textContent = `Mejor f(${g})`;
  el.etiqueta_posicion.textContent = `Mejor posición ${g}`;
  el.etiqueta_parametros.textContent = `Parámetros de ${algoritmo.siglas}`;
  el.total.textContent = estado.total;
  const n = Number(hist().n_individuos), dibujados = hist().poblacion[0].length;
  el.leyenda_poblacion.textContent = `${n} ${algoritmo.individuos}`
    + (dibujados < n ? ` (se dibujan ${dibujados})` : "");

  // Resumen: los parametros propios con simbolo corto (w, c1, F...); si no hay, los dos primeros.
  const propios = parametros.filter((p) => !p.comun);
  const con_simbolo = propios.filter((p) => p.corta).slice(0, 3);
  el.parametros.innerHTML = (con_simbolo.length ? con_simbolo : propios.slice(0, 2))
    .map((p) => `<span class="simbolo">${p.corta || p.etiqueta}</span> ${valor_parametro(p.valor)}`)
    .join(" ");

  const fila = (p) => `<dt>${p.etiqueta}${p.corta ? ` (${p.corta})` : ""}</dt><dd>${valor_parametro(p.valor)}</dd>`;
  el.lista_configuracion.innerHTML =
    `<span class="grupo">${algoritmo.siglas}</span>${propios.map(fila).join("")}` +
    `<span class="grupo">Comunes</span>${parametros.filter((p) => p.comun).map(fila).join("")}`;
}

function valor_parametro(v) {
  return typeof v === "number" ? formato_corto(v) : String(v);
}

function preparar_mapa() {
  const mapa = estado.datos.mapa;
  const hay_mapa = mapa.tipo !== "ninguno";
  el.leyenda.hidden = !hay_mapa;
  el.mapa.hidden = !hay_mapa;
  el.mensaje_mapa.textContent = hay_mapa ? ""
    : "La vista del espacio de búsqueda es para problemas continuos. La convergencia sí se muestra.";
  el.barra_color.hidden = mapa.tipo !== "superficie";
  el.mapa_imagen.hidden = mapa.tipo !== "superficie";

  if (mapa.tipo === "superficie") {
    const colores = como_lista(mapa.colores);
    el.degradado.style.background = `linear-gradient(to top, ${colores.join(", ")})`;
    el.z_max.textContent = `f = ${formato_corto(mapa.z[1])}`;
    el.z_min.textContent = formato_corto(mapa.z[0]);
    estado.imagen = new Image();
    estado.imagen.addEventListener("load", () => {
      el.momentos.dataset.firma = "";
      dibujar_momentos();
    });
    estado.imagen.src = mapa.imagen;
    el.mapa_imagen.src = mapa.imagen;
    if (estado.datos.problema.dim > 2) {
      el.subtitulo.textContent += ". El mapa es un corte en x₁, x₂ con las demás variables en su mejor valor";
    }
  }
}

function dibujar_regla() {
  el.pista.setAttribute("aria-valuemax", String(estado.total));
  el.regla.style.backgroundSize = `calc(100% / ${Math.min(40, Math.max(estado.total, 1))}) 100%`;
}

// ---------------------------------------------------------------- dibujo por cuadro

// Posiciones de la poblacion en t. Solo llega una iteracion cada paso_poblacion; si las
// soluciones conservan su identidad entre iteraciones (PSO, DE), se interpola para que el
// movimiento se vea continuo y si no, se usa la mas cercana.
function poblacion_en(t) {
  const { poblacion: P, paso_poblacion: paso } = hist();
  const iteracion_de = (k) => Math.min(k * paso, estado.total);
  const i = Math.min(Math.floor(t / paso), P.length - 1);
  if (i + 1 >= P.length) return P[i];
  const frac = (t - iteracion_de(i)) / (iteracion_de(i + 1) - iteracion_de(i));
  if (frac === 0) return P[i];
  if (!estado.datos.algoritmo.continuidad || P[i].length !== P[i + 1].length) {
    return P[frac < 0.5 ? i : i + 1];
  }
  return P[i].map((p, k) => p.map((v, j) => v + (P[i + 1][k][j] - v) * frac));
}

function vista(i, t = i, miniatura = false) {
  const h = hist();
  const ruta = miniatura ? null
    : estado.cambios_ruta.filter((k) => k <= i).map((k) => h.mejor_solucion[k]);
  return {
    mapa: estado.datos.mapa,
    poblacion: poblacion_en(miniatura ? i : t),
    mejor: h.mejor_solucion[i],
    valor_mejor: h.mejor_valor[i],
    ruta,
    imagen: miniatura ? estado.imagen : null,
    miniatura
  };
}

function dibujar_escenario() {
  if (estado.datos.mapa.tipo === "ninguno") return;
  const v = vista(Math.floor(estado.t), estado.t);
  const caja = el.escenario.getBoundingClientRect(), ley = el.leyenda.getBoundingClientRect();
  v.evitar = { x: ley.left - caja.left, y: ley.top - caja.top, w: ley.width, h: ley.height };
  dibujar_mapa(el.mapa, v);
}

let iteracion_dibujada = -1;

// Redibuja lo que depende de la iteracion entera solo cuando cambia; todo = true lo fuerza.
function actualizar(todo = false) {
  const i = Math.floor(estado.t);
  dibujar_escenario();
  dibujar_linea_tiempo();
  if (i !== iteracion_dibujada || todo) {
    iteracion_dibujada = i;
    dibujar_lecturas(i);
    dibujar_convergencia(el.convergencia, hist().mejor_valor, i, estado.total, estado.escala,
      `Mejor f(${estado.datos.algoritmo.simbolo})${estado.escala.tipo === "log" ? ", escala log" : ""}`);
    dibujar_momentos();
  }
  dibujar_controles();
}

function dibujar_lecturas(i) {
  const { mejor_valor, mejor_solucion, distancia } = hist();
  const problema = estado.datos.problema;
  el.iteracion.textContent = i;
  el.mejor.textContent = formato_corto(mejor_valor[i]);

  const atras = Math.min(VENTANA_CAMBIO, i);
  const antes = mejor_valor[i - atras];
  const cambio = mejor_valor[i] === antes ? 0 : mejor_valor[i] - antes;
  el.cambio.classList.toggle("mejora", cambio !== 0);
  el.cambio.textContent = atras === 0 ? "posición inicial"
    : cambio === 0 ? `sin cambio en las últimas ${atras} it`
    : `${cambio > 0 ? "+" : ""}${formato_corto(cambio)} en las últimas ${atras} it`;

  const x = mejor_solucion[i];
  el.posicion.textContent = texto_punto(x, problema.dim);
  const optimo = problema.x_optimo;
  if (distancia.length) {
    const iguales = optimo.every((v) => v === optimo[0]);
    const punto = iguales && optimo.length > 2 ? `(${formato_corto(optimo[0])}, …)` : texto_punto(optimo);
    el.distancia.textContent = `a ${formato_corto(distancia[i])} del óptimo ${punto}`;
  } else {
    el.distancia.textContent = "óptimo desconocido con estos datos";
  }
}

function dibujar_momentos() {
  if (!estado.datos) return;
  const hay_mapa = estado.datos.mapa.tipo !== "ninguno";
  const lista = momentos();
  const firma = lista.map((m) => `${m.it}:${estado.alcanzada >= m.it && m.it <= fin()}`).join("|");
  const cambio_tamano = el.momentos.dataset.ancho !== String(el.momentos.clientWidth);
  if (el.momentos.dataset.firma === firma && !cambio_tamano) return;
  el.momentos.dataset.firma = firma;
  el.momentos.dataset.ancho = String(el.momentos.clientWidth);

  el.momentos.innerHTML = "";
  lista.forEach((m, k) => {
    const listo = estado.alcanzada >= m.it && m.it <= fin();
    const fuera = m.it > fin();
    const boton = document.createElement("button");
    boton.type = "button";
    boton.className = "momento" + (listo ? " listo" : "");
    boton.disabled = !listo;
    const valor = listo ? `f = ${formato_corto(hist().mejor_valor[m.it])}` : "";
    const texto = fuera ? "no se llegó"
      : k === 0 && !listo ? "al iniciar" : `llega en la iteración ${m.it}`;
    boton.innerHTML = `<span class="momento-cabeza"><span>${m.nombre}</span><span>${valor}</span></span>
      <span class="momento-cuadro">${listo ? (hay_mapa ? "<canvas></canvas>" : `it ${m.it}`) : texto}</span>`;
    boton.setAttribute("aria-label", listo ? `${m.nombre}: iteración ${m.it}, ${valor}` : `${m.nombre}: ${texto}`);
    boton.addEventListener("click", () => { pausar(); ir_a(m.it); });
    el.momentos.appendChild(boton);
    const canvas = boton.querySelector("canvas");
    const sin_imagen = estado.datos.mapa.tipo === "superficie" && !(estado.imagen && estado.imagen.complete);
    if (canvas && !sin_imagen) dibujar_mapa(canvas, vista(m.it, m.it, true));
  });
}

function dibujar_linea_tiempo() {
  const total = Math.max(estado.total, 1);
  const pct = (v) => `${(v / total * 100).toFixed(3)}%`;
  el.avance.style.width = pct(estado.t);
  el.perilla.style.left = pct(estado.t);
  el.vedado.style.width = estado.detenido_en === null ? "0" : pct(estado.total - estado.detenido_en);
  el.pista.setAttribute("aria-valuenow", String(Math.floor(estado.t)));
  el.pista.setAttribute("aria-valuetext", `Iteración ${Math.floor(estado.t)} de ${estado.total}`);

  const lista = momentos();
  if (el.hitos.childElementCount !== lista.length) {
    el.hitos.innerHTML = lista.map(() => '<button type="button" class="hito"></button>').join("");
    [...el.hitos.children].forEach((b, k) => b.addEventListener("click", () => {
      pausar();
      ir_a(momentos()[k].it);
    }));
  }
  [...el.hitos.children].forEach((b, k) => {
    const m = lista[k];
    // La pastilla de Final queda en la orilla aunque se haya detenido antes.
    const it = k === lista.length - 1 ? estado.total : m.it;
    b.style.left = pct(it);
    b.textContent = `${m.corto} · ${m.it}`;
    b.classList.toggle("alcanzado", Math.floor(estado.t) === m.it);
    b.disabled = m.it > fin();
  });
}

function dibujar_controles() {
  const i = Math.floor(estado.t);
  el.reproducir.classList.toggle("reproduciendo", estado.reproduciendo);
  el.reproducir.setAttribute("aria-label", estado.reproduciendo ? "Pausar" : "Reproducir");
  el.anterior.disabled = i <= 0;
  el.siguiente.disabled = i >= fin();
  el.detener.disabled = estado.detenido_en !== null || i >= estado.total;
  el.resultados.disabled = estado.alcanzada < fin();

  el.estado.classList.remove("aviso");
  if (estado.reproduciendo) {
    el.estado.textContent = "Reproduciendo";
  } else if (i < fin()) {
    el.estado.textContent = "En pausa";
  } else if (estado.detenido_en !== null) {
    el.estado.textContent = `Detenido en ${estado.detenido_en}`;
  } else {
    el.estado.textContent = estado.datos.motivo === "convergencia" ? "Sin mejora: paró" : "Terminó";
  }
}

// ---------------------------------------------------------------- reproduccion

function ir_a(t) {
  estado.t = Math.max(0, Math.min(fin(), t));
  estado.alcanzada = Math.max(estado.alcanzada, Math.floor(estado.t));
  actualizar();
}

function velocidad() {
  return Math.max(6, estado.total / SEGUNDOS_POR_EJECUCION);
}

// Se avanza con setTimeout y no con requestAnimationFrame, que se queda quieto
// mientras la ventana de MATLAB no esta visible.
function cuadro() {
  if (!estado.reproduciendo) return;
  const ahora = performance.now();
  const dt = Math.min(0.1, (ahora - estado.ultimo_cuadro) / 1000);
  estado.ultimo_cuadro = ahora;
  ir_a(estado.t + dt * velocidad());
  if (estado.t >= fin()) {
    pausar();
  } else {
    estado.temporizador = setTimeout(cuadro, MS_POR_CUADRO);
  }
}

function reproducir() {
  if (!estado.datos || estado.reproduciendo) return;
  if (estado.t >= fin()) estado.t = 0;
  estado.reproduciendo = true;
  estado.ultimo_cuadro = performance.now();
  estado.temporizador = setTimeout(cuadro, MS_POR_CUADRO);
  dibujar_controles();
}

function pausar() {
  if (!estado.reproduciendo) return;
  estado.reproduciendo = false;
  clearTimeout(estado.temporizador);
  estado.t = Math.floor(estado.t);
  actualizar();
}

function alternar() {
  if (estado.reproduciendo) pausar(); else reproducir();
}

function paso(n) {
  pausar();
  ir_a(Math.floor(estado.t) + n);
}

function detener() {
  pausar();
  estado.detenido_en = Math.floor(estado.t);
  estado.alcanzada = Math.max(estado.alcanzada, estado.detenido_en);
  actualizar(true);
}

function reiniciar() {
  pausar();
  estado.t = 0;
  estado.alcanzada = 0;
  estado.detenido_en = null;
  actualizar(true);
}

// Arrastrar sobre la pista mueve la iteracion.
function t_desde_puntero(e) {
  const caja = el.pista.getBoundingClientRect();
  return Math.round((e.clientX - caja.left) / caja.width * estado.total);
}

el.pista.addEventListener("pointerdown", (e) => {
  if (!estado.datos) return;
  pausar();
  el.pista.setPointerCapture(e.pointerId);
  ir_a(t_desde_puntero(e));
});
el.pista.addEventListener("pointermove", (e) => {
  if (el.pista.hasPointerCapture(e.pointerId)) ir_a(t_desde_puntero(e));
});
el.pista.addEventListener("keydown", (e) => {
  const salto = { ArrowRight: 1, ArrowUp: 1, ArrowLeft: -1, ArrowDown: -1,
                  PageUp: 10, PageDown: -10 }[e.key];
  if (salto) { e.preventDefault(); paso(salto); }
  if (e.key === "Home") { e.preventDefault(); pausar(); ir_a(0); }
  if (e.key === "End") { e.preventDefault(); pausar(); ir_a(fin()); }
});

document.addEventListener("keydown", (e) => {
  if (e.key === "Escape" && !el.configuracion.hidden) cerrar_configuracion();
  const en_control = e.target.closest && e.target.closest("button, [role='slider']");
  if (e.key === " " && !en_control && estado.datos) { e.preventDefault(); alternar(); }
});

function abrir_configuracion() {
  el.configuracion.hidden = false;
  el.ver_configuracion.setAttribute("aria-expanded", "true");
  el.cerrar_configuracion.focus();
}

function cerrar_configuracion() {
  el.configuracion.hidden = true;
  el.ver_configuracion.setAttribute("aria-expanded", "false");
  el.ver_configuracion.focus();
}

el.ver_configuracion.addEventListener("click", abrir_configuracion);
document.addEventListener("pointerdown", (e) => {
  if (!el.configuracion.hidden && !el.configuracion.contains(e.target)
      && !el.ver_configuracion.contains(e.target)) cerrar_configuracion();
});
el.cerrar_configuracion.addEventListener("click", cerrar_configuracion);
el.reproducir.addEventListener("click", alternar);
el.anterior.addEventListener("click", () => paso(-1));
el.siguiente.addEventListener("click", () => paso(1));
el.detener.addEventListener("click", detener);
el.reiniciar.addEventListener("click", reiniciar);
el.regresar.addEventListener("click", () => puente.enviar("regresar"));
el.resultados.addEventListener("click", () => {
  pausar();
  puente.enviar("resultados", { iteracion: fin() });
});

[el.reiniciar, el.anterior, el.reproducir, el.siguiente, el.detener].forEach((b) => { b.disabled = true; });

new ResizeObserver(() => { if (estado.datos) actualizar(true); }).observe(el.escenario);
new ResizeObserver(() => { if (estado.datos) actualizar(true); }).observe(el.convergencia.parentElement);

// Mientras MATLAB corre el algoritmo (con poblaciones grandes tarda) se cuentan los segundos.
let reloj_calculo = null;

function mostrar_calculando() {
  const inicio = performance.now();
  const pintar = () => {
    const s = Math.floor((performance.now() - inicio) / 1000);
    el.mensaje_mapa.textContent = `Calculando la búsqueda… ${s} s`
      + (s >= 4 ? ". Con poblaciones grandes o muchas iteraciones puede tardar un poco." : "");
  };
  pintar();
  reloj_calculo = setInterval(pintar, 1000);
}

function quitar_calculando() {
  clearInterval(reloj_calculo);
  el.mensaje_mapa.textContent = "";
}

puente.escuchar("datos", (datos) => {
  quitar_calculando();
  iniciar(datos);
});
puente.escuchar("aviso", (datos) => {
  quitar_calculando();
  el.estado.textContent = datos.texto;
  el.estado.classList.add("aviso");
});

puente.al_iniciar((con_matlab) => {
  if (con_matlab) {
    mostrar_calculando();
    puente.enviar("lista");
  } else {
    puente.recibir("datos", DEMO.datos());
  }
});
