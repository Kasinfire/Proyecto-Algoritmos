// Pantalla 3: algoritmo y sus parametros.
//
// Eventos que llegan de MATLAB:
//   "datos"   { problema: {nombre, representacion, dim},
//               algoritmos: [{id, nombre, siglas, descripcion, disponible, nota,
//                             parametros: [{nombre, etiqueta, ayuda, tipo, valor, min, max,
//                                           opciones: [{valor, texto}], solo_si}]}],
//               horario: {materias} o {}, seleccion: {id, valores}, n_guardadas }
//             tipo es "entero", "real" u "opcion". solo_si = {nombre, valor} si el
//             parametro solo cuenta con esa opcion elegida (k del torneo, alfa de BLX).
//             Con horario la pantalla muestra el problema en etiquetas y el
//             presupuesto de evaluaciones.
//   "aviso"   { texto }   (MATLAB rechazo los parametros)
// Eventos que se mandan a MATLAB:
//   "lista"      la pagina ya puede recibir datos
//   "ejecutar"   { id, valores: {nombre: valor} }
//   "regresar", "ir_a_paso" { paso }, "comparar", "ayuda"

const estado = {
  problema: null, algoritmos: [], n_guardadas: 0, horario: null,
  id: "", valores: {}, aviso: ""
};

const el = Object.fromEntries([
  "subtitulo", "etiquetas", "lista", "nombre", "flujo", "por-defecto", "descripcion",
  "parametros", "presupuesto", "presupuesto-cuenta", "presupuesto-nota", "resumen",
  "regresar", "ejecutar"
].map((id) => [id.replace("-", "_"), document.getElementById(id)]));

const SUPERINDICES = "⁰¹²³⁴⁵⁶⁷⁸⁹";

function algoritmo_actual() {
  return estado.algoritmos.find((a) => a.id === estado.id) || null;
}

function parametros(a) {
  return a ? como_lista(a.parametros) : [];
}

// Potencias de 2 grandes (la semilla llega a 2^31) se leen mejor como 2³¹.
function formato_limite(v) {
  const exponente = Math.log2(v);
  if (v >= 65536 && Number.isInteger(exponente)) {
    return "2" + String(exponente).split("").map((d) => SUPERINDICES[d]).join("");
  }
  return formato_numero(v);
}

function texto_valor(p, v) {
  if (p.tipo === "opcion") return String(v);
  return p.tipo === "entero" ? String(v) : formato_numero(v);
}

function valores_por_defecto(a) {
  return Object.fromEntries(parametros(a).map((p) => [p.nombre, texto_valor(p, p.valor)]));
}

function visible(p, valores) {
  return !(p.solo_si && p.solo_si.nombre) || valores[p.solo_si.nombre] === p.solo_si.valor;
}

// Mismas reglas que armar_parametros.m; MATLAB vuelve a validar al ejecutar.
function error_de(p, texto) {
  if (p.tipo === "opcion") return "";
  const v = leer_numero(texto);
  const dentro = Number.isFinite(v) && v >= p.min && v <= p.max;
  const rango = `${formato_limite(p.min)} y ${formato_limite(p.max)}`;
  if (p.tipo === "entero") return dentro && Number.isInteger(v) ? "" : `Usa un entero entre ${rango}.`;
  return dentro ? "" : `Usa un valor entre ${rango}.`;
}

function errores(a) {
  const valores = estado.valores[a.id];
  return parametros(a).filter((p) => visible(p, valores) && error_de(p, valores[p.nombre]));
}

// Lo que se manda a MATLAB. Un parametro oculto con un valor invalido regresa a su
// valor por defecto: no se usa, pero armar_parametros.m lo revisa igual.
function valores_para_matlab(a) {
  const valores = estado.valores[a.id];
  return Object.fromEntries(parametros(a).map((p) => {
    if (p.tipo === "opcion") return [p.nombre, valores[p.nombre]];
    const v = leer_numero(valores[p.nombre]);
    return [p.nombre, error_de(p, valores[p.nombre]) ? p.valor : v];
  }));
}

function subtitulo(problema) {
  const n = problema.dim;
  if (estado.horario) {
    const m = estado.horario.materias;
    const de = m ? ` de ${m} ${m === 1 ? "materia" : "materias"}` : "";
    return `${n} secciones${de}. Solo aparecen activos los algoritmos que trabajan con vectores binarios.`;
  }
  switch (problema.representacion) {
    case "binario": return `Para ${problema.nombre}, binario con ${n} bits.`;
    case "permutacion": return `Para ${problema.nombre}, permutación de ${n} elementos.`;
    default: return `Para ${problema.nombre}, continuo en ${n} ${n === 1 ? "dimensión" : "dimensiones"}.`;
  }
}

function dibujar() {
  dibujar_riel(document.getElementById("riel"), 2, estado.n_guardadas,
    (paso) => puente.enviar("ir_a_paso", { paso }));
  el.subtitulo.textContent = subtitulo(estado.problema);
  dibujar_etiquetas();
  dibujar_lista();
  dibujar_configuracion();
  actualizar_acciones();
}

function dibujar_etiquetas() {
  el.etiquetas.hidden = !estado.horario;
  if (!estado.horario) return;
  const p = estado.problema;
  el.etiquetas.innerHTML = "";
  [[p.nombre, ""], [`n = ${p.dim} bits`, "mono"], [p.sentido === "max" ? "Maximizar" : "Minimizar", ""]]
    .forEach(([texto, clase]) => {
      const li = document.createElement("li");
      li.textContent = texto;
      if (clase) li.className = clase;
      el.etiquetas.appendChild(li);
    });
}

function dibujar_lista() {
  el.lista.innerHTML = "";
  estado.algoritmos.forEach((a) => {
    const elegido = a.id === estado.id;
    const fila = document.createElement("div");
    fila.className = "algoritmo";
    fila.setAttribute("role", "radio");
    fila.setAttribute("aria-checked", String(elegido));
    fila.setAttribute("aria-disabled", String(!a.disponible));
    fila.tabIndex = elegido ? 0 : -1;
    fila.dataset.id = a.id;
    const nota = a.nota ? `${a.siglas}, ${a.nota}` : a.siglas;
    fila.innerHTML = `<span class="algoritmo-icono">${ICONOS_ALGORITMO[a.id] || ""}</span>
      <span class="algoritmo-textos"><span class="algoritmo-nombre">${a.nombre}</span>
      <span class="algoritmo-nota">${nota}</span></span>`;
    if (a.disponible) fila.addEventListener("click", () => elegir(a.id));
    el.lista.appendChild(fila);
  });
  if (!estado.id && el.lista.firstChild) el.lista.firstChild.tabIndex = 0;
}

function dibujar_configuracion() {
  const a = algoritmo_actual();
  el.parametros.innerHTML = "";
  if (!a) {
    el.nombre.textContent = "Sin algoritmos todavía";
    el.descripcion.textContent = "Ningún algoritmo maneja este tipo de problema por ahora. Regresa y elige otro problema.";
    el.por_defecto.hidden = true;
    el.flujo.hidden = true;
    el.presupuesto.hidden = true;
    return;
  }
  el.nombre.textContent = a.nombre;
  el.descripcion.textContent = a.descripcion;

  const valores = estado.valores[a.id];
  const visibles = parametros(a).filter((p) => visible(p, valores));
  // Filas de 3 tarjetas; lo que sobra se reparte en filas de 2 para no dejar huecos.
  const sobran = { 0: 0, 1: 4, 2: 2 }[visibles.length % 3];
  visibles.forEach((p, i) => el.parametros.appendChild(tarjeta(p, valores, i >= visibles.length - sobran)));
  actualizar_parametros();
}

function tarjeta(p, valores, ancha) {
  const t = document.createElement("div");
  t.className = ancha ? "tarjeta ancha" : "tarjeta";
  t.dataset.nombre = p.nombre;
  const id_campo = `campo-${p.nombre}`;
  const id_ayuda = `ayuda-${p.nombre}`;

  if (p.tipo === "opcion") {
    const botones = como_lista(p.opciones).map((o) =>
      `<button type="button" role="radio" data-valor="${o.valor}" aria-checked="${o.valor === valores[p.nombre]}">${o.texto}</button>`).join("");
    t.innerHTML = `<div class="tarjeta-cabeza"><span class="etiqueta" id="${id_campo}">${p.etiqueta}</span></div>
      <div class="segmento" role="radiogroup" aria-labelledby="${id_campo}" aria-describedby="${id_ayuda}">${botones}</div>
      <p class="tarjeta-ayuda" id="${id_ayuda}">${p.ayuda}</p>`;
    t.querySelectorAll("[data-valor]").forEach((b) =>
      b.addEventListener("click", () => elegir_opcion(p, b.dataset.valor)));
    return t;
  }

  t.innerHTML = `<div class="tarjeta-cabeza"><label for="${id_campo}">${p.etiqueta}</label>
      <span class="rango">${formato_limite(p.min)} a ${formato_limite(p.max)}</span></div>
    <div class="control">
      <input id="${id_campo}" inputmode="${p.tipo === "entero" ? "numeric" : "decimal"}" autocomplete="off"
        aria-describedby="${id_ayuda}">
      <button type="button" class="boton-mini" data-paso="-1" aria-label="Bajar ${p.etiqueta}">−</button>
      <button type="button" class="boton-mini" data-paso="1" aria-label="Subir ${p.etiqueta}">+</button>
    </div>
    <p class="tarjeta-ayuda" id="${id_ayuda}"></p>`;
  const entrada = t.querySelector("input");
  entrada.value = valores[p.nombre];
  entrada.addEventListener("input", () => { valores[p.nombre] = entrada.value; cambio(); });
  entrada.addEventListener("keydown", (e) => {
    const paso = { ArrowUp: 1, ArrowDown: -1 }[e.key];
    if (paso) { e.preventDefault(); mover(p, paso); }
    if (e.key === "Enter") ejecutar();
  });
  t.querySelectorAll("[data-paso]").forEach((b) =>
    b.addEventListener("click", () => mover(p, Number(b.dataset.paso))));
  return t;
}

// Marcas de error, ayudas, botones +/- y el enlace de valores por defecto.
function actualizar_parametros() {
  const a = algoritmo_actual();
  if (!a) return;
  const valores = estado.valores[a.id];
  parametros(a).forEach((p) => {
    const t = el.parametros.querySelector(`[data-nombre="${p.nombre}"]`);
    if (!t || p.tipo === "opcion") return;
    const error = error_de(p, valores[p.nombre]);
    const v = leer_numero(valores[p.nombre]);
    t.querySelector(".control").classList.toggle("invalido", !!error);
    t.querySelector("input").setAttribute("aria-invalid", String(!!error));
    const ayuda = t.querySelector(".tarjeta-ayuda");
    ayuda.textContent = error || p.ayuda;
    ayuda.classList.toggle("error", !!error);
    t.querySelector('[data-paso="-1"]').disabled = Number.isFinite(v) && v <= p.min;
    t.querySelector('[data-paso="1"]').disabled = Number.isFinite(v) && v >= p.max;
  });
  actualizar_flujo(a, valores);
  actualizar_presupuesto(a, valores);
  const defecto = valores_por_defecto(a);
  el.por_defecto.hidden = parametros(a).every((p) =>
    p.tipo === "opcion" ? valores[p.nombre] === defecto[p.nombre]
                        : leer_numero(valores[p.nombre]) === p.valor);
}

// Lo que hace cada generacion con las opciones elegidas. En PSO y DE solo se muestra
// como un vector de numeros se vuelve bits o ruta; en continuo no hay nada que decir.
const CRUZAS = { un_punto: "cruza en un punto", uniforme: "cruza uniforme",
                 blx: "cruza BLX-α", aritmetica: "cruza aritmética" };
const MUTACIONES = { swap: "intercambio", inversion: "inversión" };

function flujo(a, valores, representacion) {
  switch (a.id) {
    case "ga": {
      const cruza = representacion === "permutacion" ? "cruza OX" : CRUZAS[valores.tipo_cruza];
      const mutacion = { continuo: "mutación gaussiana", binario: "mutación de bits",
                         permutacion: MUTACIONES[valores.tipo_mutacion] }[representacion];
      return [valores.seleccion === "ruleta" ? "ruleta" : "torneo", cruza, mutacion,
              ...(leer_numero(valores.n_elite) > 0 ? ["elitismo"] : [])].join(" → ");
    }
    case "pso":
      if (representacion === "binario") return "velocidad → sigmoide → bits";
      if (representacion === "permutacion") return "llaves en [0, 1] → ordenar → ruta";
      return "";
    case "de":
      if (representacion === "binario") return "vector en [0, 1] → umbral 0.5 → bits";
      if (representacion === "permutacion") return "llaves en [0, 1] → ordenar → ruta";
      return "";
    default: return "";
  }
}

function actualizar_flujo(a, valores) {
  const texto = flujo(a, valores, estado.problema.representacion) || "";
  el.flujo.hidden = !texto;
  el.flujo.textContent = texto;
}

function con_miles(n) {
  return String(n).replace(/\B(?=(\d{3})+(?!\d))/g, "\u202f");
}

// Cada algoritmo evalua su poblacion inicial y luego una poblacion por iteracion
// (tam x (iteraciones + 1)); con paciencia puede parar antes, por eso es un maximo.
function actualizar_presupuesto(a, valores) {
  el.presupuesto.hidden = !estado.horario;
  if (!estado.horario) return;
  const p_tam = parametros(a).find((p) => p.nombre === "tam_poblacion" || p.nombre === "n_particulas");
  const p_iter = parametros(a).find((p) => p.nombre === "n_iteraciones");
  const tam = p_tam && leer_numero(valores[p_tam.nombre]);
  const iter = p_iter && leer_numero(valores[p_iter.nombre]);
  const listos = p_tam && p_iter && !error_de(p_tam, valores[p_tam.nombre]) && !error_de(p_iter, valores[p_iter.nombre]);
  el.presupuesto_cuenta.innerHTML = listos
    ? `<b>${con_miles(tam * (iter + 1))}</b> evaluaciones de f como máximo (${tam} × ${iter + 1})`
    : "Corrige el tamaño y las iteraciones para calcularlo.";
  const otros = estado.algoritmos.filter((x) => x.disponible && x.id !== a.id).map((x) => x.siglas);
  el.presupuesto_nota.textContent = otros.length
    ? `Para comparar con ${otros.join(" y ")}, usa la misma semilla y presupuesto.`
    : "";
}

function actualizar_acciones() {
  const a = algoritmo_actual();
  const invalidos = a ? errores(a) : [];
  el.ejecutar.disabled = !a || invalidos.length > 0;
  el.resumen.classList.toggle("aviso", !!(estado.aviso || invalidos.length));
  if (estado.aviso) {
    el.resumen.textContent = estado.aviso;
  } else if (!a) {
    el.resumen.textContent = "";
  } else if (invalidos.length) {
    const otros = invalidos.length > 1 ? ` y ${invalidos.length - 1} más` : "";
    el.resumen.textContent = `Corrige ${invalidos[0].etiqueta}${otros} para poder ejecutar.`;
  } else {
    el.resumen.textContent = `${a.nombre} sobre ${estado.problema.nombre}, listo para ejecutar.`;
  }
}

function cambio() {
  estado.aviso = "";
  actualizar_parametros();
  actualizar_acciones();
}

// Paso de los botones +/-: de uno en uno para enteros chicos, de diez en diez desde
// 100, etc.; los reales avanzan 0.1, 0.05 o 0.01 segun su rango y su tamano.
function paso_de(p, v) {
  if (p.tipo === "entero") return Math.max(1, 10 ** (Math.floor(Math.log10(Math.max(Math.abs(v), 1))) - 1));
  if (Math.abs(v) < 0.1) return 0.01;
  return p.max - p.min >= 2 ? 0.1 : 0.05;
}

function mover(p, direccion) {
  const valores = estado.valores[estado.id];
  const actual = leer_numero(valores[p.nombre]);
  const base = Number.isFinite(actual) ? actual : p.valor;
  const nuevo = Math.min(p.max, Math.max(p.min, Number((base + direccion * paso_de(p, base)).toFixed(6))));
  valores[p.nombre] = texto_valor(p, p.tipo === "entero" ? Math.round(nuevo) : nuevo);
  el.parametros.querySelector(`[data-nombre="${p.nombre}"] input`).value = valores[p.nombre];
  cambio();
}

// Una opcion puede mostrar u ocultar otros parametros, asi que se redibuja la rejilla.
function elegir_opcion(p, valor) {
  estado.valores[estado.id][p.nombre] = valor;
  estado.aviso = "";
  dibujar_configuracion();
  actualizar_acciones();
  const boton = el.parametros.querySelector(`[data-nombre="${p.nombre}"] [data-valor="${CSS.escape(valor)}"]`);
  if (boton) boton.focus();
}

function elegir(id) {
  if (id === estado.id) return;
  estado.id = id;
  el.lista.querySelectorAll(".algoritmo").forEach((f) => {
    const elegido = f.dataset.id === id;
    f.setAttribute("aria-checked", String(elegido));
    f.tabIndex = elegido ? 0 : -1;
  });
  estado.aviso = "";
  dibujar_configuracion();
  actualizar_acciones();
}

function ejecutar() {
  const a = algoritmo_actual();
  if (a && !el.ejecutar.disabled) puente.enviar("ejecutar", { id: a.id, valores: valores_para_matlab(a) });
}

el.lista.addEventListener("keydown", (e) => {
  const filas = [...el.lista.querySelectorAll('.algoritmo:not([aria-disabled="true"])')];
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
    if (e.key === "Enter") ejecutar();
  }
});

el.por_defecto.addEventListener("click", () => {
  const a = algoritmo_actual();
  estado.valores[a.id] = valores_por_defecto(a);
  estado.aviso = "";
  dibujar_configuracion();
  actualizar_acciones();
});
el.regresar.addEventListener("click", () => puente.enviar("regresar"));
el.ejecutar.addEventListener("click", ejecutar);

puente.escuchar("datos", (datos) => {
  estado.problema = datos.problema;
  estado.algoritmos = como_lista(datos.algoritmos);
  estado.n_guardadas = Number(datos.n_guardadas) || 0;
  estado.horario = datos.horario && "materias" in datos.horario ? datos.horario : null;
  estado.valores = Object.fromEntries(estado.algoritmos.map((a) => [a.id, valores_por_defecto(a)]));

  const s = datos.seleccion || {};
  const a = estado.algoritmos.find((x) => x.id === s.id && x.disponible)
    || estado.algoritmos.find((x) => x.disponible);
  estado.id = a ? a.id : "";
  if (a && s.id === a.id && s.valores) {
    parametros(a).forEach((p) => {
      if (p.nombre in s.valores) estado.valores[a.id][p.nombre] = texto_valor(p, s.valores[p.nombre]);
    });
  }
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
    puente.recibir("datos", location.search.includes("horario") ? DEMO.horario : DEMO.datos);
  }
});
