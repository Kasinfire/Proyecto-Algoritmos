// Pantalla 2 para problemas binarios: mochila y OneMax.
//
// Eventos que llegan de MATLAB:
//   "datos"    { tipo: {id, nombre, notacion}, problemas: [{id, nombre, formula, descripcion, sentido,
//                dim_min, dim_max, dim_defecto, f_optimo, disponible, datos}], seleccion, n_guardadas }
//              En la mochila, datos trae el ejemplo inicial { pesos, valores, capacidad }.
//   "objetos"  { pesos, valores }   (leidos de un CSV)
//   "aviso"    { texto }            (MATLAB rechazo la configuracion o el CSV)
// Eventos que se mandan a MATLAB:
//   "lista"        la pagina ya puede recibir datos
//   "siguiente"    { id: "mochila", pesos, valores, capacidad } o { id: "onemax", dim }
//   "cargar_csv", "regresar", "ir_a_paso" { paso }, "comparar", "ayuda"

const estado = {
  tipo: null, problemas: [], n_guardadas: 0, con_matlab: false, aviso: "",
  id: "",
  capacidad: "", objetos: [],   // mochila: objetos = [{ peso, valor }] tal como se escribieron
  dim: "", bits: []             // OneMax: bits de ejemplo que el usuario puede cambiar
};

const el = Object.fromEntries([
  "subtitulo", "pestanas", "descripcion", "panel-mochila", "panel-onemax",
  "capacidad", "texto-capacidad", "barra-capacidad", "cargar-csv", "filas", "agregar",
  "dim", "dim-menos", "dim-mas", "bits", "bits-nota",
  "formula", "optimo", "resumen", "regresar", "siguiente"
].map((id) => [id.replace(/-/g, "_"), document.getElementById(id)]));

function problema_actual() {
  return estado.problemas.find((p) => p.id === estado.id) || null;
}

function limites() {
  const p = problema_actual();
  return p ? { min: p.dim_min, max: p.dim_max, defecto: p.dim_defecto } : { min: 1, max: 1, defecto: 1 };
}

// ---------- Validacion (las mismas reglas de armar_problema_binario.m) ----------

// Por campo: "" si esta bien, "falta" si esta vacio o el mensaje de error.
function revisar(texto, valido, falta, mensaje) {
  if (String(texto).trim() === "") return falta;
  return valido(leer_numero(texto)) ? "" : mensaje;
}

function errores_mochila() {
  const { min, max } = limites();
  const n = estado.objetos.length;
  const positivo = (v) => Number.isFinite(v) && v > 0;
  const no_negativo = (v) => Number.isFinite(v) && v >= 0;

  const pesos = estado.objetos.map((o, i) =>
    revisar(o.peso, positivo, `Falta el peso del objeto ${i + 1}.`,
      `El peso del objeto ${i + 1} debe ser un número mayor que 0.`));
  const valores = estado.objetos.map((o, i) =>
    revisar(o.valor, no_negativo, `Falta el valor del objeto ${i + 1}.`,
      `El valor del objeto ${i + 1} debe ser un número mayor o igual que 0.`));
  const capacidad = revisar(estado.capacidad, positivo, "Falta la capacidad.",
    "La capacidad debe ser un número mayor que 0.");
  const cantidad = n < min ? `La mochila necesita al menos ${min} objetos.`
    : n > max ? `La mochila admite hasta ${max} objetos.` : "";

  const texto = cantidad || capacidad || [...pesos, ...valores].find((e) => e) || "";
  return { pesos, valores, capacidad, texto };
}

function errores_onemax() {
  const { min, max } = limites();
  const n = leer_numero(estado.dim);
  const ok = Number.isInteger(n) && n >= min && n <= max;
  return { texto: ok ? "" : `El número de bits debe ser un entero entre ${min} y ${max}.` };
}

function errores() {
  return estado.id === "mochila" ? errores_mochila() : errores_onemax();
}

// Solo se pinta de error lo que ya tiene texto; lo vacio se avisa abajo.
function marcar(entrada, texto, error) {
  entrada.setAttribute("aria-invalid", String(!!error && String(texto).trim() !== ""));
}

// ---------- Dibujo ----------

function dibujar() {
  dibujar_riel(document.getElementById("riel"), 1, estado.n_guardadas,
    (paso) => puente.enviar("ir_a_paso", { paso }));
  el.subtitulo.textContent = "Problemas binarios. Elige uno y ajusta sus datos.";
  dibujar_pestanas();
  dibujar_panel();
}

function dibujar_pestanas() {
  el.pestanas.innerHTML = "";
  estado.problemas.forEach((p) => {
    const b = document.createElement("button");
    const elegida = p.id === estado.id;
    b.type = "button";
    b.setAttribute("role", "tab");
    b.setAttribute("aria-selected", String(elegida));
    b.setAttribute("aria-controls", `panel-${p.id}`);
    b.tabIndex = elegida ? 0 : -1;
    b.dataset.id = p.id;
    b.textContent = p.nombre;
    b.addEventListener("click", () => elegir(p.id));
    el.pestanas.appendChild(b);
  });
}

function dibujar_panel() {
  const p = problema_actual();
  el.panel_mochila.hidden = estado.id !== "mochila";
  el.panel_onemax.hidden = estado.id !== "onemax";
  el.descripcion.textContent = p ? p.descripcion : "No hay problemas binarios todavía.";
  el.formula.textContent = p ? p.formula : "";
  if (estado.id === "mochila") {
    el.capacidad.value = estado.capacidad;
    dibujar_filas();
  } else if (estado.id === "onemax") {
    el.dim.value = estado.dim;
    ajustar_bits();
    dibujar_bits();
  }
  actualizar();
}

function dibujar_filas() {
  el.filas.innerHTML = estado.objetos.map((o, i) => `
    <div class="objeto" role="row">
      <span role="cell">${i + 1}</span>
      <span role="cell"><input class="entrada" data-i="${i}" data-campo="peso" inputmode="decimal"
        autocomplete="off" aria-label="Peso del objeto ${i + 1}"></span>
      <span role="cell"><input class="entrada" data-i="${i}" data-campo="valor" inputmode="decimal"
        autocomplete="off" aria-label="Valor del objeto ${i + 1}"></span>
      <span role="cell" class="barra"><span class="barra-relleno"></span></span>
      <span role="cell" class="razon"></span>
      <span role="cell"><button type="button" class="quitar" data-i="${i}"
        aria-label="Quitar el objeto ${i + 1}">×</button></span>
    </div>`).join("");
  // Los valores van por propiedad para no meter texto del usuario en el HTML.
  el.filas.querySelectorAll("input").forEach((entrada) => {
    entrada.value = estado.objetos[entrada.dataset.i][entrada.dataset.campo];
  });
}

// Mantiene un bit por dimension: conserva los que ya estaban y sortea los nuevos.
function ajustar_bits() {
  const n = leer_numero(estado.dim);
  const { min, max } = limites();
  if (!Number.isInteger(n) || n < min || n > max) return;
  while (estado.bits.length < n) estado.bits.push(Math.random() < 0.5 ? 1 : 0);
  estado.bits.length = n;
}

function dibujar_bits() {
  el.bits.innerHTML = estado.bits.map((b, i) =>
    `<button type="button" class="bit" data-i="${i}" aria-pressed="${b === 1}"
      aria-label="Bit ${i + 1}">${b}</button>`).join("");
}

// Lo que depende de los valores escritos: marcas de error, medidores, botones y resumen.
function actualizar() {
  if (estado.id === "mochila") actualizar_mochila();
  if (estado.id === "onemax") actualizar_onemax();
  actualizar_acciones();
}

function actualizar_mochila() {
  const e = errores_mochila();
  const { min, max } = limites();
  marcar(el.capacidad, estado.capacidad, e.capacidad);

  const pesos = estado.objetos.map((o) => leer_numero(o.peso));
  const valores = estado.objetos.map((o) => leer_numero(o.valor));
  const razones = pesos.map((w, i) => (!e.pesos[i] && !e.valores[i] ? valores[i] / w : NaN));
  const razon_max = Math.max(0, ...razones.filter(Number.isFinite));

  el.filas.querySelectorAll(".objeto").forEach((fila, i) => {
    const [peso, valor] = fila.querySelectorAll("input");
    marcar(peso, estado.objetos[i].peso, e.pesos[i]);
    marcar(valor, estado.objetos[i].valor, e.valores[i]);
    const r = razones[i];
    fila.querySelector(".barra-relleno").style.width =
      Number.isFinite(r) && razon_max > 0 ? `${(r / razon_max) * 100}%` : "0";
    fila.querySelector(".razon").textContent = Number.isFinite(r) ? r.toFixed(2) : "—";
    fila.querySelector(".quitar").disabled = estado.objetos.length <= min;
  });
  el.agregar.disabled = estado.objetos.length >= max;

  actualizar_medidor(e, pesos);
}

function actualizar_medidor(e, pesos) {
  const medidor = el.texto_capacidad.parentElement;
  const capacidad = leer_numero(estado.capacidad);
  const total = pesos.reduce((a, w) => a + w, 0);
  medidor.classList.remove("lleno");
  if (e.capacidad || e.pesos.some((x) => x) || pesos.length === 0) {
    el.texto_capacidad.textContent = "";
    el.barra_capacidad.style.width = "0";
    return;
  }
  const ligero = Math.min(...pesos);
  if (capacidad >= total) {
    medidor.classList.add("lleno");
    el.texto_capacidad.textContent = `Caben todos los objetos (peso total ${formato_numero(total)}).`;
  } else if (capacidad < ligero) {
    el.texto_capacidad.textContent = `No cabe ningún objeto: el más ligero pesa ${formato_numero(ligero)}.`;
  } else {
    const parte = Math.round((capacidad / total) * 100);
    el.texto_capacidad.textContent = `Cabe ${parte} % del peso total (${formato_numero(total)}).`;
  }
  el.barra_capacidad.style.width = `${Math.min(100, (capacidad / total) * 100)}%`;
}

function actualizar_onemax() {
  const p = problema_actual();
  const e = errores_onemax();
  const n = leer_numero(estado.dim);
  marcar(el.dim, estado.dim, e.texto);
  el.dim_menos.disabled = !(n > limites().min);
  el.dim_mas.disabled = !(n < limites().max);
  const unos = estado.bits.reduce((a, b) => a + b, 0);
  el.bits_nota.innerHTML = `<strong>f(x) = ${unos}</strong> de ${estado.bits.length} posibles. Toca un bit para cambiarlo.`;
  const f = e.texto ? null : como_lista(p.f_optimo)[n - 1];
  el.optimo.textContent = typeof f === "number" ? `Óptimo conocido: f = ${f} en x = (1, …, 1)` : "";
}

function actualizar_acciones() {
  const p = problema_actual();
  const error = p ? errores().texto : "";
  if (estado.id !== "onemax") el.optimo.textContent = "";
  el.siguiente.disabled = !p || !p.disponible || !!error;
  el.resumen.classList.toggle("aviso", !!(error || estado.aviso));
  if (estado.aviso) {
    el.resumen.textContent = estado.aviso;
  } else if (!p) {
    el.resumen.textContent = "";
  } else if (error) {
    el.resumen.textContent = error;
  } else if (!p.disponible) {
    el.resumen.textContent = `${p.nombre} todavía está en desarrollo: falta su función en src/problemas/binario.`;
  } else if (p.id === "mochila") {
    el.resumen.textContent = `Mochila con ${estado.objetos.length} objetos y capacidad ${formato_numero(leer_numero(estado.capacidad))}.`;
  } else {
    el.resumen.textContent = `OneMax con ${leer_numero(estado.dim)} bits.`;
  }
}

// ---------- Acciones ----------

function cambio() {
  estado.aviso = "";
  actualizar();
}

function elegir(id) {
  if (id === estado.id) return;
  estado.id = id;
  estado.aviso = "";
  dibujar_pestanas();
  dibujar_panel();
}

function configuracion() {
  if (estado.id === "mochila") {
    return { id: "mochila", pesos: estado.objetos.map((o) => leer_numero(o.peso)),
             valores: estado.objetos.map((o) => leer_numero(o.valor)),
             capacidad: leer_numero(estado.capacidad) };
  }
  return { id: "onemax", dim: leer_numero(estado.dim) };
}

function continuar() {
  if (!el.siguiente.disabled) puente.enviar("siguiente", configuracion());
}

function cargar_objetos(pesos, valores) {
  pesos = como_lista(pesos);
  valores = como_lista(valores);
  estado.objetos = pesos.map((w, i) => ({ peso: formato_numero(w), valor: formato_numero(valores[i]) }));
}

function agregar_objeto() {
  estado.objetos.push({ peso: "", valor: "" });
  dibujar_filas();
  cambio();
  const ultima = el.filas.lastElementChild;
  ultima.scrollIntoView({ block: "nearest" });
  ultima.querySelector("input").focus();
}

function quitar_objeto(i) {
  estado.objetos.splice(i, 1);
  dibujar_filas();
  cambio();
  const botones = el.filas.querySelectorAll(".quitar");
  const siguiente = botones[Math.min(i, botones.length - 1)];
  (siguiente && !siguiente.disabled ? siguiente : el.agregar).focus();
}

function mover_dim(paso) {
  const dim = leer_numero(estado.dim);
  const { min, max, defecto } = limites();
  const base = Number.isInteger(dim) ? dim : defecto;
  estado.dim = el.dim.value = String(Math.min(max, Math.max(min, base + paso)));
  ajustar_bits();
  dibujar_bits();
  cambio();
}

el.pestanas.addEventListener("keydown", (e) => {
  const pestanas = [...el.pestanas.querySelectorAll('[role="tab"]')];
  const i = pestanas.indexOf(document.activeElement);
  const paso = { ArrowRight: 1, ArrowLeft: -1 }[e.key];
  if (i < 0 || !paso) return;
  e.preventDefault();
  const siguiente = pestanas[(i + paso + pestanas.length) % pestanas.length];
  elegir(siguiente.dataset.id);
  el.pestanas.querySelector(`[data-id="${siguiente.dataset.id}"]`).focus();
});

el.capacidad.addEventListener("input", () => { estado.capacidad = el.capacidad.value; cambio(); });
el.filas.addEventListener("input", (e) => {
  const { i, campo } = e.target.dataset;
  if (campo) { estado.objetos[i][campo] = e.target.value; cambio(); }
});
el.filas.addEventListener("click", (e) => {
  const boton = e.target.closest(".quitar");
  if (boton && !boton.disabled) quitar_objeto(Number(boton.dataset.i));
});
el.agregar.addEventListener("click", agregar_objeto);
el.cargar_csv.addEventListener("click", () => {
  if (estado.con_matlab) {
    puente.enviar("cargar_csv");
  } else {
    estado.aviso = "Cargar un CSV necesita MATLAB; en el navegador solo se ve el diseño.";
    actualizar_acciones();
  }
});

el.dim.addEventListener("input", () => {
  estado.dim = el.dim.value;
  ajustar_bits();
  dibujar_bits();
  cambio();
});
el.dim.addEventListener("keydown", (e) => {
  const paso = { ArrowUp: 1, ArrowDown: -1 }[e.key];
  if (paso) { e.preventDefault(); mover_dim(paso); }
});
el.dim_menos.addEventListener("click", () => mover_dim(-1));
el.dim_mas.addEventListener("click", () => mover_dim(1));
el.bits.addEventListener("click", (e) => {
  const bit = e.target.closest(".bit");
  if (!bit) return;
  const i = Number(bit.dataset.i);
  estado.bits[i] = 1 - estado.bits[i];
  bit.setAttribute("aria-pressed", String(estado.bits[i] === 1));
  bit.textContent = estado.bits[i];
  actualizar();
});

document.querySelector(".tarjeta").addEventListener("keydown", (e) => {
  if (e.key === "Enter" && e.target.matches("input")) continuar();
});
el.regresar.addEventListener("click", () => puente.enviar("regresar"));
el.siguiente.addEventListener("click", continuar);

puente.escuchar("datos", (datos) => {
  estado.tipo = datos.tipo;
  estado.problemas = como_lista(datos.problemas);
  estado.n_guardadas = Number(datos.n_guardadas) || 0;

  const s = datos.seleccion || {};
  const mochila = estado.problemas.find((p) => p.id === "mochila");
  const onemax = estado.problemas.find((p) => p.id === "onemax");
  const elegido = estado.problemas.find((p) => p.id === s.id) || estado.problemas[0];
  estado.id = elegido ? elegido.id : "";

  if (mochila) {
    const origen = s.id === "mochila" ? s : mochila.datos || {};
    cargar_objetos(origen.pesos, origen.valores);
    estado.capacidad = formato_numero(origen.capacidad);
  }
  if (onemax) {
    estado.dim = String(s.id === "onemax" && s.dim ? s.dim : onemax.dim_defecto);
  }
  dibujar();
});

puente.escuchar("objetos", (datos) => {
  cargar_objetos(datos.pesos, datos.valores);
  estado.aviso = "";
  dibujar_filas();
  actualizar();
});

puente.escuchar("aviso", (datos) => {
  estado.aviso = datos.texto;
  actualizar_acciones();
});

puente.al_iniciar((con_matlab) => {
  estado.con_matlab = con_matlab;
  if (con_matlab) {
    puente.enviar("lista");
  } else {
    puente.recibir("datos", DEMO.datos);
  }
});
