// Graficas de las pantallas de ejecucion y resultados: mapa con la poblacion y convergencia.
// Solo pintan lo que MATLAB ya calculo (historial y mapa_de_busqueda.m).

const COLOR_MEJOR = "#D95319";

// Ajusta el canvas a su tamano en pantalla (nitido en pantallas de alta densidad).
function preparar_lienzo(canvas) {
  const caja = canvas.getBoundingClientRect();
  const k = window.devicePixelRatio || 1;
  const w = Math.max(1, Math.round(caja.width * k));
  const h = Math.max(1, Math.round(caja.height * k));
  if (canvas.width !== w || canvas.height !== h) {
    canvas.width = w;
    canvas.height = h;
  }
  const ctx = canvas.getContext("2d");
  ctx.setTransform(k, 0, 0, k, 0, 0);
  ctx.clearRect(0, 0, caja.width, caja.height);
  return { ctx, w: caja.width, h: caja.height };
}

// Marcas redondas (1, 2 o 5 por 10^k) dentro de [a, b].
function marcas(a, b, cuantas = 5) {
  const crudo = (b - a) / cuantas;
  const base = Math.pow(10, Math.floor(Math.log10(crudo)));
  const paso = [1, 2, 5, 10].map((m) => m * base).find((p) => p >= crudo);
  const lista = [];
  if (!(paso > 0) || !Number.isFinite(paso)) return lista;
  // Con a enorme y b - a diminuto, v + paso puede redondear a v: el tope evita ciclar.
  for (let v = Math.ceil(a / paso) * paso; v <= b + paso * 1e-9 && lista.length <= 2 * cuantas + 2; v += paso) {
    lista.push(Math.abs(v) < paso * 1e-9 ? 0 : v);
  }
  return lista;
}

function texto_marca(v) {
  return String(Number(v.toPrecision(4))).replace(/-/g, "−");
}

// Valor de la curva en x (interpolacion lineal entre las muestras de MATLAB).
function curva_en(curva, x) {
  const xs = curva.x, fs = curva.f;
  if (x <= xs[0]) return fs[0];
  if (x >= xs[xs.length - 1]) return fs[fs.length - 1];
  const t = (x - xs[0]) / (xs[xs.length - 1] - xs[0]) * (xs.length - 1);
  const i = Math.floor(t);
  return fs[i] + (fs[i + 1] - fs[i]) * (t - i);
}

// De coordenadas del problema a pixeles. En 'curva' el eje vertical es f y se deja aire.
function escala_mapa(mapa, w, h) {
  const [x0, x1] = mapa.x;
  let [y0, y1] = mapa.y;
  let margen = 0;
  if (mapa.tipo === "curva") {
    const aire = (y1 - y0 || 1) * 0.14;
    y0 -= aire;
    y1 += aire;
    margen = 18;
  }
  return {
    x: (v) => margen + (v - x0) / (x1 - x0) * (w - 2 * margen),
    y: (v) => h - margen - (v - y0) / (y1 - y0) * (h - 2 * margen),
    y0, y1
  };
}

// Posicion en el mapa de una solucion (en 'curva' se dibuja sobre la curva).
function punto_mapa(mapa, esc, p, valor) {
  if (mapa.tipo === "curva") {
    const f = valor === undefined ? curva_en(mapa.curva, p[0]) : valor;
    return [esc.x(p[0]), esc.y(f)];
  }
  return [esc.x(p[0]), esc.y(p[1])];
}

function dibujar_estrella(ctx, x, y, r) {
  ctx.beginPath();
  for (let k = 0; k < 10; k++) {
    const radio = k % 2 === 0 ? r : r * 0.45;
    const a = -Math.PI / 2 + k * Math.PI / 5;
    ctx.lineTo(x + radio * Math.cos(a), y + radio * Math.sin(a));
  }
  ctx.closePath();
  ctx.fillStyle = COLOR_MEJOR;
  ctx.strokeStyle = "#FFFFFF";
  ctx.lineWidth = r > 8 ? 2 : 1.2;
  ctx.lineJoin = "round";
  ctx.fill();
  ctx.stroke();
}

function dibujar_curva(ctx, mapa, esc, w, h, grosor) {
  ctx.fillStyle = "#EEF2F8";
  ctx.fillRect(0, 0, w, h);
  ctx.beginPath();
  mapa.curva.x.forEach((x, i) => ctx.lineTo(esc.x(x), esc.y(mapa.curva.f[i])));
  ctx.strokeStyle = "#0072BD";
  ctx.lineWidth = grosor;
  ctx.stroke();
}

// evitar: rectangulo {x, y, w, h} donde no se escriben marcas (la leyenda).
function dibujar_ejes(ctx, mapa, esc, w, h, evitar) {
  const libre = (x, y) => !evitar || x < evitar.x - 8 || x > evitar.x + evitar.w + 8
                                    || y < evitar.y - 8 || y > evitar.y + evitar.h + 8;
  ctx.font = "11px Geist, Inter, system-ui, sans-serif";
  const curva = mapa.tipo === "curva";
  ctx.fillStyle = curva ? "rgba(17, 19, 40, 0.6)" : "rgba(255, 255, 255, 0.92)";
  ctx.shadowColor = curva ? "transparent" : "rgba(0, 0, 0, 0.55)";
  ctx.shadowBlur = 3;

  ctx.textAlign = "center";
  ctx.textBaseline = "bottom";
  marcas(mapa.x[0], mapa.x[1], 6).forEach((v) => {
    const px = esc.x(v);
    if (px > 30 && px < w - 40 && libre(px, h - 16)) ctx.fillText(texto_marca(v), px, h - 10);
  });
  ctx.textAlign = "left";
  ctx.textBaseline = "middle";
  const [y0, y1] = curva ? [esc.y0, esc.y1] : mapa.y;
  marcas(y0, y1, 6).forEach((v) => {
    const py = esc.y(v);
    if (py > 30 && py < h - 34 && libre(16, py)) ctx.fillText(texto_marca(v), 12, py);
  });

  ctx.font = "italic 12px Geist, Inter, system-ui, sans-serif";
  ctx.textAlign = "right";
  ctx.textBaseline = "bottom";
  ctx.fillText(curva ? "x" : "x₁", w - 14, h - 10);
  ctx.textAlign = "left";
  ctx.textBaseline = "top";
  ctx.fillText(curva ? "f(x)" : "x₂", 12, 12);
  ctx.shadowColor = "transparent";
}

// vista: { mapa, poblacion: [[x, y]...], mejor: [x, y], valor_mejor, ruta: [[x, y]...],
//          imagen (solo miniaturas: la imagen del mapa ya cargada), miniatura, evitar,
//          poblacion_tenue (la poblacion como fantasma, para que destaquen estrella y ruta) }
function dibujar_mapa(canvas, vista) {
  const { ctx, w, h } = preparar_lienzo(canvas);
  const { mapa, miniatura } = vista;
  const esc = escala_mapa(mapa, w, h);

  if (mapa.tipo === "curva") {
    dibujar_curva(ctx, mapa, esc, w, h, miniatura ? 1.2 : 2);
  } else if (vista.imagen) {
    ctx.drawImage(vista.imagen, 0, 0, w, h);
  }
  if (!miniatura) dibujar_ejes(ctx, mapa, esc, w, h, vista.evitar);

  if (vista.ruta && vista.ruta.length > 1) {
    ctx.beginPath();
    vista.ruta.forEach((p) => ctx.lineTo(...punto_mapa(mapa, esc, p)));
    ctx.setLineDash(miniatura ? [2, 2] : [5, 4]);
    ctx.strokeStyle = mapa.tipo === "curva" ? "rgba(17, 19, 40, 0.55)" : "rgba(255, 255, 255, 0.95)";
    ctx.lineWidth = miniatura ? 1 : 2;
    ctx.stroke();
    ctx.setLineDash([]);
  }

  const radio = miniatura ? 2 : 5.5;
  ctx.fillStyle = vista.poblacion_tenue ? "rgba(255, 255, 255, 0.45)" : "#FFFFFF";
  ctx.strokeStyle = vista.poblacion_tenue ? "rgba(17, 19, 40, 0.45)" : "rgba(17, 19, 40, 0.8)";
  ctx.lineWidth = miniatura ? 0.8 : 1.6;
  vista.poblacion.forEach((p) => {
    const [x, y] = punto_mapa(mapa, esc, p);
    ctx.beginPath();
    ctx.arc(x, y, radio, 0, 2 * Math.PI);
    ctx.fill();
    ctx.stroke();
  });

  if (vista.mejor) {
    const [x, y] = punto_mapa(mapa, esc, vista.mejor, vista.valor_mejor);
    dibujar_estrella(ctx, x, y, miniatura ? 5 : 12);
  }
}

// Grafica de convergencia en SVG: el mejor valor acumulado hasta la iteracion i.
// escala: { tipo: 'log' | 'lineal', min, max } calculada una vez con todo el historial.
// con_punto marca la iteracion i con su valor (en resultados la curva va completa, sin marca).
function dibujar_convergencia(svg, valores, i, total, escala, etiqueta_y, con_punto = true) {
  const caja = svg.getBoundingClientRect();
  const w = caja.width, h = caja.height;
  if (w < 10 || h < 10) return;
  const m = { izq: 44, der: 14, arriba: 8, abajo: 34 };
  const ancho = w - m.izq - m.der, alto = h - m.arriba - m.abajo;
  const log = escala.tipo === "log";
  // En log, los ceros (optimo alcanzado) se dibujan en el piso de la grafica.
  const t = (v) => (log ? Math.log10(Math.max(v, escala.min)) : v);
  const [a, b] = [t(escala.min), t(escala.max)];
  const px = (k) => m.izq + k / Math.max(total, 1) * ancho;
  // Los valores fuera de escala (Inf) se dibujan en la orilla.
  const py = (v) => m.arriba + alto - Math.min(1, Math.max(0, (t(v) - a) / (b - a || 1))) * alto;

  const marcas_y = log
    ? Array.from({ length: b - a + 1 }, (_, k) => Math.pow(10, b - k))
        .filter((_, k, l) => l.length <= 6 || k % Math.ceil(l.length / 5) === 0)
    : marcas(escala.min, escala.max, 4);
  const texto_y = (v) => (log ? texto_potencia(v) : texto_marca(v));

  let s = "";
  marcas_y.forEach((v) => {
    const y = py(v).toFixed(1);
    s += `<line class="rejilla" x1="${m.izq}" x2="${w - m.der}" y1="${y}" y2="${y}"/>`;
    s += `<text x="${m.izq - 6}" y="${y}" text-anchor="end" dominant-baseline="middle">${texto_y(v)}</text>`;
  });
  marcas(0, total, 4).forEach((k) => {
    const x = px(k).toFixed(1);
    s += `<line class="rejilla" x1="${x}" x2="${x}" y1="${m.arriba}" y2="${m.arriba + alto}"/>`;
    s += `<text x="${x}" y="${m.arriba + alto + 14}" text-anchor="middle">${k}</text>`;
  });
  s += `<line class="eje" x1="${m.izq}" x2="${m.izq}" y1="${m.arriba}" y2="${m.arriba + alto}"/>`;
  s += `<line class="eje" x1="${m.izq}" x2="${w - m.der}" y1="${m.arriba + alto}" y2="${m.arriba + alto}"/>`;
  s += `<text class="eje-titulo" x="${m.izq + ancho / 2}" y="${h - 2}" text-anchor="middle">Iteración</text>`;
  s += `<text class="eje-titulo" transform="translate(10 ${m.arriba + alto / 2}) rotate(-90)" text-anchor="middle">${etiqueta_y}</text>`;

  // El mejor acumulado cambia a saltos: se dibuja en escalones, uno por cada cambio.
  let d = `M${px(0).toFixed(1)} ${py(valores[0]).toFixed(1)}`;
  for (let k = 1; k <= i; k++) {
    if (valores[k] !== valores[k - 1]) d += `H${px(k).toFixed(1)} V${py(valores[k]).toFixed(1)}`;
  }
  d += `H${px(i).toFixed(1)}`;
  s += `<path class="curva" d="${d}"/>`;
  if (!con_punto) {
    svg.innerHTML = s;
    return;
  }
  const xa = px(i), ya = py(valores[i]);
  const ancla = xa > m.izq + ancho - 60 ? "end" : "start";
  s += `<circle class="punto" cx="${xa.toFixed(1)}" cy="${ya.toFixed(1)}" r="4"/>`;
  s += `<text class="valor" x="${(xa + (ancla === "end" ? -8 : 8)).toFixed(1)}" y="${(ya - 8).toFixed(1)}" text-anchor="${ancla}">${formato_corto(valores[i])}</text>`;
  svg.innerHTML = s;
}

function texto_potencia(v) {
  const k = Math.round(Math.log10(v));
  if (k >= 0 && k <= 3) return String(Math.pow(10, k));
  if (k < 0 && k >= -2) return String(Number(Math.pow(10, k).toFixed(-k)));
  const sup = { "-": "⁻", 0: "⁰", 1: "¹", 2: "²", 3: "³", 4: "⁴", 5: "⁵", 6: "⁶", 7: "⁷", 8: "⁸", 9: "⁹" };
  return "10" + String(k).split("").map((c) => sup[c]).join("");
}

// Escala de la convergencia: logaritmica si ningun valor es negativo. Se calcula con los
// valores finitos y entre 1e-300 y 1e308: fuera de eso 10^k ya es 0 o Infinity.
function escala_convergencia(valores) {
  const finitos = valores.filter(Number.isFinite);
  if (!finitos.length) return { tipo: "lineal", min: 0, max: 1 };
  const min = finitos.reduce((a, v) => Math.min(a, v)), max = finitos.reduce((a, v) => Math.max(a, v));
  const positivos = finitos.filter((v) => v > 0);
  if (min >= 0 && positivos.length) {
    let a = Math.max(-300, Math.floor(Math.log10(positivos.reduce((p, v) => Math.min(p, v))))),
        b = Math.min(308, Math.max(a, Math.ceil(Math.log10(max))));
    if (a === b) { if (b < 308) b += 1; else a -= 1; }
    return { tipo: "log", min: Math.pow(10, a), max: Math.pow(10, b) };
  }
  const aire = (max - min || Math.abs(max) || 1) * 0.08;
  return { tipo: "lineal", min: min - aire, max: max + aire };
}

// Cuatro cifras significativas, con signo menos tipografico.
function formato_corto(v) {
  if (v === Infinity) return "∞";
  if (v === -Infinity) return "−∞";
  if (v === null || v === undefined || !Number.isFinite(v)) return "–";
  const abs = Math.abs(v);
  const texto = abs !== 0 && (abs >= 1e5 || abs < 1e-3) ? v.toExponential(2) : String(Number(v.toPrecision(4)));
  return texto.replace(/-/g, "−");
}
