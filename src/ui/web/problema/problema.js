// Pantalla 2: problema y sus datos.
//
// Eventos que llegan de MATLAB:
//   "datos"   { tipo: {id, nombre, notacion}, problemas: [{id, nombre, formula, forma, descripcion,
//               lb, ub, sentido, dim_min, dim_max, dim_defecto, f_optimo, x_optimo, disponible}],
//               seleccion, n_guardadas }
//             f_optimo trae un valor por dimension (f_optimo[n - 1], null si no se conoce).
//   "aviso"   { texto }   (MATLAB rechazo la configuracion)
// Eventos que se mandan a MATLAB:
//   "lista"       la pagina ya puede recibir datos
//   "siguiente"   { id, dim, lb, ub, sentido }
//   "regresar", "ir_a_paso" { paso }, "comparar", "ayuda"
//
// Las superficies son PNG que genera MATLAB una sola vez (generar_imagenes_problemas.m).

const CARPETA_IMAGENES = "problema/imagenes/";

const SUBTITULOS = {
  continuo: "Funciones continuas. Elige una y ajusta sus datos.",
  binario: "Problemas binarios. Elige uno y ajusta sus datos.",
  permutacion: "Problemas de permutación. Elige uno y ajusta sus datos."
};

const estado = {
  tipo: null, problemas: [], n_guardadas: 0,
  id: "", dim: "", lb: "", ub: "", sentido: "min", aviso: ""
};

const el = Object.fromEntries([
  "subtitulo", "lista", "detalle", "nombre", "descripcion", "sentido", "datos", "dim",
  "dim-menos", "dim-mas", "lb", "ub", "restablecer", "imagen", "mensaje-imagen",
  "formula", "optimo", "resumen", "regresar", "siguiente"
].map((id) => [id.replace("-", "_"), document.getElementById(id)]));

// Acepta el signo menos tipografico y la coma decimal.
function leer_numero(texto) {
  const t = String(texto).trim().replace(/−/g, "-").replace(",", ".");
  return t === "" ? NaN : Number(t);
}

function formato_numero(v) {
  if (v === null || v === undefined || Number.isNaN(v)) return "";
  const abs = Math.abs(v);
  const texto = abs !== 0 && (abs >= 1e5 || abs < 1e-3) ? v.toExponential(1) : String(Number(v.toPrecision(5)));
  return texto.replace(/-/g, "−");
}

function problema_actual() {
  return estado.problemas.find((p) => p.id === estado.id) || null;
}

function limites() {
  const p = problema_actual();
  return p ? { min: p.dim_min, max: p.dim_max, defecto: p.dim_defecto } : { min: 1, max: 1, defecto: 1 };
}

function configuracion() {
  return { id: estado.id, dim: leer_numero(estado.dim), lb: leer_numero(estado.lb),
           ub: leer_numero(estado.ub), sentido: estado.sentido };
}

// Mismas reglas que armar_problema.m; MATLAB vuelve a validar al presionar Siguiente.
function errores() {
  const c = configuracion();
  const { min, max } = limites();
  const texto_dim = min === max
    ? `Este problema solo existe con dimensión ${min}.`
    : `La dimensión debe ser un entero entre ${min} y ${max}.`;
  return {
    dim: Number.isInteger(c.dim) && c.dim >= min && c.dim <= max ? "" : texto_dim,
    rango: Number.isFinite(c.lb) && Number.isFinite(c.ub) && c.lb < c.ub
      ? "" : "El límite inferior debe ser menor que el superior."
  };
}

// El optimo conocido solo sigue valiendo si el rango cabe en el original, lo contiene
// y no se cambio el sentido (la misma regla de armar_problema.m).
function optimo_vigente(p) {
  const c = configuracion();
  const f = como_lista(p.f_optimo)[c.dim - 1];
  if (typeof f !== "number" || c.sentido !== p.sentido || c.lb < p.lb || c.ub > p.ub) return null;
  const x = como_lista(p.x_optimo);
  return x.every((v) => v >= c.lb && v <= c.ub) ? { f, x } : null;
}

// Si todas las coordenadas son iguales basta con una: x = (0, …).
function texto_optimo({ f, x }, dim) {
  const iguales = x.every((v) => v === x[0]);
  const punto = iguales
    ? (dim === 1 ? formato_numero(x[0]) : `(${formato_numero(x[0])}, …)`)
    : `(${x.map(formato_numero).join(", ")})`;
  return `Óptimo conocido: f = ${formato_numero(f)} en x = ${punto}`;
}

function dibujar() {
  dibujar_riel(document.getElementById("riel"), 1, estado.n_guardadas,
    (paso) => puente.enviar("ir_a_paso", { paso }));
  el.subtitulo.textContent = SUBTITULOS[estado.tipo.id] || "";
  dibujar_lista();
  dibujar_detalle();
  actualizar_acciones();
}

function dibujar_lista() {
  el.lista.innerHTML = "";
  estado.problemas.forEach((p) => {
    const elegido = p.id === estado.id;
    const fila = document.createElement("div");
    fila.className = "fila";
    fila.setAttribute("role", "radio");
    fila.setAttribute("aria-checked", String(elegido));
    fila.setAttribute("aria-disabled", String(!p.disponible));
    fila.tabIndex = elegido ? 0 : -1;
    fila.dataset.id = p.id;
    const mini = p.disponible
      ? `<img class="fila-mini" src="${CARPETA_IMAGENES}${p.id}_mini.png" alt="">`
      : `<span class="fila-mini-vacia"></span>`;
    fila.innerHTML = `${mini}<span>${p.nombre}</span>${p.disponible ? "" : '<span class="fila-nota">en desarrollo</span>'}`;
    const img = fila.querySelector("img");
    if (img) img.addEventListener("error", () => { img.className = "fila-mini-vacia"; img.removeAttribute("src"); });
    if (p.disponible) fila.addEventListener("click", () => elegir(p.id));
    el.lista.appendChild(fila);
  });
  if (!estado.id && el.lista.firstChild) el.lista.firstChild.tabIndex = 0;
}

function dibujar_detalle() {
  const p = problema_actual();
  [el.sentido.parentElement, el.datos, el.formula.parentElement].forEach((x) => { x.hidden = !p; });
  if (!p) {
    el.nombre.textContent = "Sin problemas todavía";
    el.descripcion.textContent = `Los problemas de tipo ${estado.tipo.nombre.toLowerCase()} están en desarrollo. Regresa y elige otro tipo.`;
    mostrar_imagen(null);
    return;
  }
  el.nombre.textContent = p.nombre;
  el.descripcion.textContent = p.descripcion;
  el.formula.textContent = p.formula;
  el.dim.value = estado.dim;
  el.lb.value = estado.lb;
  el.ub.value = estado.ub;
  el.sentido.querySelectorAll("button").forEach((b) =>
    b.setAttribute("aria-checked", String(b.dataset.sentido === estado.sentido)));
  mostrar_imagen(p);
  actualizar_datos();
}

function mostrar_imagen(p) {
  el.mensaje_imagen.textContent = "";
  if (!p) {
    el.imagen.hidden = true;
    el.imagen.removeAttribute("src");
    return;
  }
  el.imagen.hidden = false;
  el.imagen.alt = p.dim_defecto === 1 ? `Curva de ${p.nombre} en una dimensión`
                                       : `Superficie de ${p.nombre} en dos dimensiones`;
  el.imagen.src = `${CARPETA_IMAGENES}${p.id}.png`;
}

el.imagen.addEventListener("error", () => {
  if (!el.imagen.getAttribute("src")) return;
  el.imagen.hidden = true;
  el.mensaje_imagen.textContent = "Falta la imagen de este problema. Créala en MATLAB con generar_imagenes_problemas.";
});

// Lo que depende de los valores escritos: marcas de error, botones y optimo.
function actualizar_datos() {
  const p = problema_actual();
  if (!p) return;
  const e = errores();
  const dim = leer_numero(estado.dim);
  el.dim.setAttribute("aria-invalid", String(!!e.dim));
  el.lb.setAttribute("aria-invalid", String(!!e.rango));
  el.ub.setAttribute("aria-invalid", String(!!e.rango));
  el.dim_menos.disabled = !(dim > limites().min);
  el.dim_mas.disabled = !(dim < limites().max);
  el.restablecer.hidden = leer_numero(estado.lb) === p.lb && leer_numero(estado.ub) === p.ub;
  const optimo = optimo_vigente(p);
  el.optimo.textContent = optimo ? texto_optimo(optimo, dim) : "Óptimo desconocido con estos datos";
}

function actualizar_acciones() {
  const p = problema_actual();
  const e = errores();
  const error = p ? e.dim || e.rango : "";
  el.siguiente.disabled = !p || !!error;
  el.resumen.classList.toggle("aviso", !!(error || estado.aviso));
  if (estado.aviso) {
    el.resumen.textContent = estado.aviso;
  } else if (!p) {
    el.resumen.textContent = "";
  } else if (error) {
    el.resumen.textContent = error;
  } else {
    const c = configuracion();
    const verbo = c.sentido === "min" ? "minimizar" : "maximizar";
    el.resumen.textContent = `${p.nombre} con n = ${c.dim}, ${verbo} en [${formato_numero(c.lb)}, ${formato_numero(c.ub)}].`;
  }
}

function cambio() {
  estado.aviso = "";
  actualizar_datos();
  actualizar_acciones();
}

function elegir(id) {
  if (id === estado.id) return;
  const p = estado.problemas.find((q) => q.id === id);
  estado.id = id;
  estado.dim = String(p.dim_defecto);
  estado.lb = formato_numero(p.lb);
  estado.ub = formato_numero(p.ub);
  estado.sentido = p.sentido;
  el.lista.querySelectorAll(".fila").forEach((f) => {
    const elegido = f.dataset.id === id;
    f.setAttribute("aria-checked", String(elegido));
    f.tabIndex = elegido ? 0 : -1;
  });
  estado.aviso = "";
  dibujar_detalle();
  actualizar_acciones();
}

function continuar() {
  if (!el.siguiente.disabled) puente.enviar("siguiente", configuracion());
}

function mover_dim(paso) {
  const dim = leer_numero(estado.dim);
  const { min, max, defecto } = limites();
  const base = Number.isInteger(dim) ? dim : defecto;
  estado.dim = String(Math.min(max, Math.max(min, base + paso)));
  el.dim.value = estado.dim;
  cambio();
}

el.lista.addEventListener("keydown", (e) => {
  const filas = [...el.lista.querySelectorAll('.fila:not([aria-disabled="true"])')];
  const i = filas.indexOf(document.activeElement);
  if (i < 0) return;
  const paso = { ArrowDown: 1, ArrowRight: 1, ArrowUp: -1, ArrowLeft: -1 }[e.key];
  if (paso) {
    e.preventDefault();
    const siguiente = filas[(i + paso + filas.length) % filas.length];
    siguiente.focus();
    elegir(siguiente.dataset.id);
  } else if (e.key === " " || e.key === "Enter") {
    e.preventDefault();
    elegir(document.activeElement.dataset.id);
    if (e.key === "Enter") continuar();
  }
});

el.dim.addEventListener("input", () => { estado.dim = el.dim.value; cambio(); });
el.dim.addEventListener("keydown", (e) => {
  const paso = { ArrowUp: 1, ArrowDown: -1 }[e.key];
  if (paso) { e.preventDefault(); mover_dim(paso); }
});
el.dim_menos.addEventListener("click", () => mover_dim(-1));
el.dim_mas.addEventListener("click", () => mover_dim(1));
el.lb.addEventListener("input", () => { estado.lb = el.lb.value; cambio(); });
el.ub.addEventListener("input", () => { estado.ub = el.ub.value; cambio(); });
el.restablecer.addEventListener("click", () => {
  const p = problema_actual();
  estado.lb = el.lb.value = formato_numero(p.lb);
  estado.ub = el.ub.value = formato_numero(p.ub);
  cambio();
});
el.sentido.querySelectorAll("button").forEach((b) => b.addEventListener("click", () => {
  estado.sentido = b.dataset.sentido;
  el.sentido.querySelectorAll("button").forEach((x) => x.setAttribute("aria-checked", String(x === b)));
  cambio();
}));
[el.dim, el.lb, el.ub].forEach((entrada) => entrada.addEventListener("keydown", (e) => {
  if (e.key === "Enter") continuar();
}));
el.regresar.addEventListener("click", () => puente.enviar("regresar"));
el.siguiente.addEventListener("click", continuar);

puente.escuchar("datos", (datos) => {
  estado.tipo = datos.tipo;
  estado.problemas = como_lista(datos.problemas);
  estado.n_guardadas = Number(datos.n_guardadas) || 0;

  const s = datos.seleccion || {};
  const p = estado.problemas.find((q) => q.id === s.id && q.disponible)
    || estado.problemas.find((q) => q.disponible);
  estado.id = p ? p.id : "";
  estado.dim = String(s.dim || (p ? p.dim_defecto : ""));
  estado.lb = p ? formato_numero(s.lb ?? p.lb) : "";
  estado.ub = p ? formato_numero(s.ub ?? p.ub) : "";
  estado.sentido = s.sentido || (p ? p.sentido : "min");
  dibujar();
});

puente.escuchar("aviso", (datos) => {
  estado.aviso = datos.texto;
  actualizar_acciones();
});

puente.al_iniciar((con_matlab) => {
  if (con_matlab) {
    puente.enviar("lista");
  } else {
    puente.recibir("datos", DEMO.datos);
  }
});
