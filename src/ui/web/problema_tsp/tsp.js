// Pantalla 2 para el TSP: numero de ciudades, semilla de la instancia o un CSV, y el mapa.
// Las coordenadas siempre las da MATLAB (ciudades_al_azar.m o leer_ciudades_csv.m); aqui
// solo se dibujan.
//
// Eventos que llegan de MATLAB:
//   "datos"     { tipo, problemas: [{id, nombre, formula, descripcion, dim_min, dim_max,
//                 dim_defecto, disponible, datos: {semilla}}], seleccion, n_guardadas }
//   "ciudades"  { x, y, dim, semilla, archivo }   (archivo = "" si se generaron con la semilla)
//   "aviso"     { texto }                         (MATLAB rechazo la configuracion o el CSV)
// Eventos que se mandan a MATLAB:
//   "lista"        la pagina ya puede recibir datos
//   "generar"      { dim, semilla }
//   "siguiente"    { id: "tsp", x, y, dim, semilla, archivo, editada }
//   "cargar_csv", "regresar", "ir_a_paso" { paso }, "comparar", "ayuda"

const SEMILLA_MAX = 4294967295;

const estado = {
  problema: null, n_guardadas: 0, con_matlab: false, aviso: "",
  dim: "", semilla: "",      // tal como se escribieron
  archivo: "",               // nombre del CSV si las ciudades vienen de ahi
  editada: false,            // true si el usuario movio alguna ciudad
  x: [], y: [], dominio: [0, 100, 0, 100],
  pedido: ""                 // "dim:semilla" de la ultima instancia pedida a MATLAB
};

const el = Object.fromEntries([
  "nombre", "descripcion", "dim", "dim-menos", "dim-mas", "semilla", "origen", "cargar-csv",
  "mapa", "ciudades", "formula", "rutas", "resumen", "regresar", "siguiente"
].map((id) => [id.replace(/-/g, "_"), document.getElementById(id)]));

// ---------- Validacion (las mismas reglas de armar_problema_permutacion.m) ----------

function errores() {
  const p = estado.problema;
  const n = leer_numero(estado.dim);
  const s = leer_numero(estado.semilla);
  let dim = "";
  if (estado.dim.trim() === "") dim = "Falta el número de ciudades.";
  else if (!(Number.isInteger(n) && n >= p.dim_min && n <= p.dim_max)) {
    dim = estado.archivo
      ? `El CSV trae ${n} ciudades; el TSP admite entre ${p.dim_min} y ${p.dim_max}.`
      : `El número de ciudades debe ser un entero entre ${p.dim_min} y ${p.dim_max}.`;
  }
  let semilla = "";
  if (!estado.archivo) {
    if (estado.semilla.trim() === "") semilla = "Falta la semilla.";
    else if (!(Number.isInteger(s) && s >= 0 && s <= SEMILLA_MAX)) {
      semilla = "La semilla debe ser un entero mayor o igual que 0.";
    }
  }
  return { dim, semilla, texto: dim || semilla };
}

function marcar(entrada, texto, error) {
  entrada.setAttribute("aria-invalid", String(!!error && String(texto).trim() !== ""));
}

// ---------- Dibujo ----------

function dibujar() {
  const p = estado.problema;
  dibujar_riel(document.getElementById("riel"), 1, estado.n_guardadas,
    (paso) => puente.enviar("ir_a_paso", { paso }));
  el.nombre.textContent = p ? p.nombre : "";
  el.descripcion.textContent = p ? p.descripcion : "No hay problemas de permutación todavía.";
  el.formula.textContent = p ? p.formula : "";
  el.dim.value = estado.dim;
  el.semilla.value = estado.semilla;
  dibujar_mapa();
  actualizar();
}

// El dominio (en coordenadas de la instancia) se estira a todo el mapa, con y hacia arriba.
// Las ciudades al azar viven en [0, 100] x [0, 100]; las de un CSV, en su propio rango.
function vista() {
  const ancho = el.mapa.clientWidth;
  const alto = el.mapa.clientHeight;
  const r = estado.x.length > 40 ? 8 : 11;
  const margen = r + 14;
  const [x0, x1, y0, y1] = estado.dominio;
  const ex = (ancho - 2 * margen) / (x1 - x0 || 1);
  const ey = (alto - 2 * margen) / (y1 - y0 || 1);
  return {
    ancho, alto, r,
    a_pantalla: (x, y) => [margen + (x - x0) * ex, alto - margen - (y - y0) * ey],
    a_dominio: (px, py) => [
      Math.min(x1, Math.max(x0, x0 + (px - margen) / ex)),
      Math.min(y1, Math.max(y0, y0 + (alto - margen - py) / ey))
    ]
  };
}

function dominio_de(x, y, archivo) {
  if (!archivo) return [0, 100, 0, 100];
  return [Math.min(...x), Math.max(...x), Math.min(...y), Math.max(...y)];
}

function dibujar_mapa() {
  const { x, y } = estado;
  const v = vista();
  el.ciudades.setAttribute("viewBox", `0 0 ${v.ancho} ${v.alto}`);
  if (x.length === 0 || v.ancho === 0) { el.ciudades.innerHTML = ""; return; }

  const chica = x.length > 40 ? " chica" : "";
  el.ciudades.innerHTML = x.map((_, i) =>
    `<g class="ciudad${chica}" data-i="${i}"><title></title>
      <circle r="${v.r}"/><text>${i + 1}</text></g>`).join("");
  el.ciudades.querySelectorAll(".ciudad").forEach((g, i) => colocar(g, i, v));
}

function colocar(g, i, v) {
  const [cx, cy] = v.a_pantalla(estado.x[i], estado.y[i]);
  g.setAttribute("transform", `translate(${cx.toFixed(1)} ${cy.toFixed(1)})`);
  g.querySelector("title").textContent =
    `Ciudad ${i + 1}: (${formato_numero(estado.x[i])}, ${formato_numero(estado.y[i])})`;
}

// Arrastrar una ciudad cambia sus coordenadas; la instancia deja de ser la de la semilla.
let arrastre = null;
el.ciudades.addEventListener("pointerdown", (e) => {
  const g = e.target.closest(".ciudad");
  if (!g || el.mapa.classList.contains("cargando")) return;
  e.preventDefault();
  arrastre = { g, i: Number(g.dataset.i), v: vista() };
  el.ciudades.setPointerCapture(e.pointerId);
  g.classList.add("arrastrando");
  el.ciudades.appendChild(g);
});
el.ciudades.addEventListener("pointermove", (e) => {
  if (!arrastre) return;
  const caja = el.ciudades.getBoundingClientRect();
  const [x, y] = arrastre.v.a_dominio(e.clientX - caja.left, e.clientY - caja.top);
  estado.x[arrastre.i] = Math.round(x * 100) / 100;
  estado.y[arrastre.i] = Math.round(y * 100) / 100;
  colocar(arrastre.g, arrastre.i, arrastre.v);
  if (!estado.editada) { estado.editada = true; estado.aviso = ""; actualizar(); }
});
const soltar = () => {
  if (!arrastre) return;
  arrastre.g.classList.remove("arrastrando");
  arrastre = null;
};
el.ciudades.addEventListener("pointerup", soltar);
el.ciudades.addEventListener("pointercancel", soltar);

// Rutas distintas con n ciudades: (n - 1)! / 2, en notacion cientifica si es grande.
function texto_rutas(n) {
  if (!(n >= 3)) return "";
  let log = Math.log10(0.5);
  for (let k = 2; k < n; k++) log += Math.log10(k);
  if (log < 6) return `Rutas posibles: ${Math.round(10 ** log).toLocaleString("es-MX")}`;
  const exp = Math.floor(log);
  const sup = String(exp).replace(/\d/g, (d) => "⁰¹²³⁴⁵⁶⁷⁸⁹"[d]);
  return `Rutas posibles: (n − 1)!/2 ≈ ${(10 ** (log - exp)).toFixed(1)} × 10${sup}`;
}

function actualizar() {
  const p = estado.problema;
  if (!p) { el.siguiente.disabled = true; return; }
  const e = errores();
  const n = leer_numero(estado.dim);
  marcar(el.dim, estado.dim, e.dim);
  marcar(el.semilla, estado.semilla, e.semilla);
  el.dim_menos.disabled = !(n > p.dim_min);
  el.dim_mas.disabled = !(n < p.dim_max);
  el.semilla.placeholder = estado.archivo ? "—" : "";
  el.origen.textContent = [estado.archivo && `Ciudades de ${estado.archivo}`,
    estado.editada && "movidas a mano"].filter(Boolean).join(", ")
    || "Arrastra una ciudad para moverla.";

  const listas = !e.texto && estado.x.length === n && !el.mapa.classList.contains("cargando");
  el.rutas.textContent = e.dim ? "" : texto_rutas(n);
  el.siguiente.disabled = !p.disponible || !listas;

  el.resumen.classList.toggle("aviso", !!(e.texto || estado.aviso));
  if (estado.aviso) {
    el.resumen.textContent = estado.aviso;
  } else if (e.texto) {
    el.resumen.textContent = e.texto;
  } else if (!p.disponible) {
    el.resumen.textContent = `${p.nombre} todavía está en desarrollo: falta su función en src/problemas/permutacion.`;
  } else {
    const origen = estado.archivo ? `de ${estado.archivo}` : `al azar (semilla ${leer_numero(estado.semilla)})`;
    el.resumen.textContent = `TSP con ${n} ciudades ${origen}${estado.editada ? ", movidas a mano" : ""}.`;
  }
}

// ---------- Acciones ----------

// Pide a MATLAB las ciudades de la instancia escrita; mientras llegan, el mapa se atenua.
let espera = null;
function pedir_ciudades() {
  clearTimeout(espera);
  estado.aviso = "";
  if (errores().texto) { actualizar(); return; }
  const dim = leer_numero(estado.dim);
  const semilla = leer_numero(estado.semilla);
  estado.pedido = `${dim}:${semilla}`;
  el.mapa.classList.add("cargando");
  actualizar();
  espera = setTimeout(() => {
    if (estado.con_matlab) puente.enviar("generar", { dim, semilla });
    else puente.recibir("ciudades", DEMO.ciudades(dim, semilla));
  }, 150);
}

// Al tocar el numero de ciudades o la semilla se deja el CSV y se vuelve a la semilla.
function dejar_csv() {
  if (!estado.archivo) return;
  estado.archivo = "";
  if (estado.semilla.trim() === "") {
    estado.semilla = el.semilla.value = String(estado.problema.datos.semilla);
  }
}

function mover_dim(paso) {
  const p = estado.problema;
  const n = leer_numero(estado.dim);
  const base = Number.isInteger(n) ? n : p.dim_defecto;
  dejar_csv();
  estado.dim = el.dim.value = String(Math.min(p.dim_max, Math.max(p.dim_min, base + paso)));
  pedir_ciudades();
}

function continuar() {
  if (el.siguiente.disabled) return;
  puente.enviar("siguiente", {
    id: estado.problema.id, x: estado.x, y: estado.y, dim: estado.x.length,
    semilla: estado.archivo ? null : leer_numero(estado.semilla), archivo: estado.archivo,
    editada: estado.editada
  });
}

el.dim.addEventListener("input", () => { dejar_csv(); estado.dim = el.dim.value; pedir_ciudades(); });
el.dim.addEventListener("keydown", (e) => {
  const paso = { ArrowUp: 1, ArrowDown: -1 }[e.key];
  if (paso) { e.preventDefault(); mover_dim(paso); }
});
el.dim_menos.addEventListener("click", () => mover_dim(-1));
el.dim_mas.addEventListener("click", () => mover_dim(1));
el.semilla.addEventListener("input", () => {
  estado.archivo = "";
  estado.semilla = el.semilla.value;
  pedir_ciudades();
});
el.cargar_csv.addEventListener("click", () => {
  if (estado.con_matlab) {
    puente.enviar("cargar_csv");
  } else {
    estado.aviso = "Cargar un CSV necesita MATLAB; en el navegador solo se ve el diseño.";
    actualizar();
  }
});

document.querySelector(".tarjeta").addEventListener("keydown", (e) => {
  if (e.key === "Enter" && e.target.matches("input")) continuar();
});
el.regresar.addEventListener("click", () => puente.enviar("regresar"));
el.siguiente.addEventListener("click", continuar);
new ResizeObserver(dibujar_mapa).observe(el.mapa);

puente.escuchar("datos", (datos) => {
  estado.problema = como_lista(datos.problemas)[0] || null;
  estado.n_guardadas = Number(datos.n_guardadas) || 0;
  const p = estado.problema;
  if (!p) { dibujar(); return; }

  const s = datos.seleccion || {};
  if (s.id === p.id && s.x !== undefined) {
    estado.x = como_lista(s.x);
    estado.y = como_lista(s.y);
    estado.archivo = s.archivo || "";
    estado.editada = !!s.editada;
    estado.dominio = dominio_de(estado.x, estado.y, estado.archivo);
    estado.dim = String(estado.x.length);
    estado.semilla = estado.archivo || s.semilla === undefined ? "" : String(s.semilla);
    dibujar();
    return;
  }
  estado.dim = String(s.id === p.id && s.dim ? s.dim : p.dim_defecto);
  estado.semilla = String(s.id === p.id && s.semilla !== undefined ? s.semilla : p.datos.semilla);
  dibujar();
  pedir_ciudades();
});

puente.escuchar("ciudades", (datos) => {
  // Solo cuenta la ultima instancia pedida; un CSV siempre se acepta.
  if (!datos.archivo && `${datos.dim}:${datos.semilla}` !== estado.pedido) return;
  estado.x = como_lista(datos.x);
  estado.y = como_lista(datos.y);
  estado.archivo = datos.archivo || "";
  estado.editada = false;
  estado.dominio = dominio_de(estado.x, estado.y, estado.archivo);
  if (estado.archivo) {
    estado.dim = el.dim.value = String(estado.x.length);
    estado.semilla = el.semilla.value = "";
    estado.pedido = "";
    estado.aviso = "";
  }
  el.mapa.classList.remove("cargando");
  dibujar_mapa();
  actualizar();
});

puente.escuchar("aviso", (datos) => {
  estado.aviso = datos.texto;
  actualizar();
});

puente.al_iniciar((con_matlab) => {
  estado.con_matlab = con_matlab;
  if (con_matlab) {
    puente.enviar("lista");
  } else {
    puente.recibir("datos", DEMO.datos);
  }
});
