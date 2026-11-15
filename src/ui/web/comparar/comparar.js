// Comparar ejecuciones: las curvas y valores son los historiales reales que manda MATLAB.
//
// Eventos que llegan de MATLAB:
//   "datos" { ejecuciones: [{ numero, algoritmo: {id, nombre, siglas},
//                             problema: {nombre, dim, sentido, representacion, f_optimo},
//                             grupo, parametros: [{nombre, etiqueta, corta, valor, comun}],
//                             mejor_valor, iteraciones, n_iteraciones, semilla,
//                             evaluaciones, motivo, convergencia }],
//             elegida, n_guardadas }
//           grupo: ejecuciones con el mismo grupo tienen el mismo problema, dimension,
//           sentido, limites y datos; solo esas se pueden comparar entre si.
//   "exportado" { texto, ok }
// Eventos que se mandan a MATLAB:
//   "lista", "exportar" { numeros }, "volver", "ir_a_paso" { paso }, "comparar", "ayuda"

// Orden de colores de las graficas de MATLAB.
const COLORES = ["#0072BD", "#D95319", "#EDB120", "#7E2F8E", "#77AC30", "#4DBEEE", "#A2142F"];
const COLOR_AJENA = "#8A8D96";

const MOTIVOS = {
  max_iteraciones: "llegó al límite",
  convergencia: "paró sin mejora",
  detenido: "detenida a mano"
};

const el = Object.fromEntries([
  "subtitulo", "ejecuciones", "ficha-numero", "ficha-nombre", "ficha-lista",
  "convergencia", "tabla-seccion", "tabla", "estado", "volver", "exportar"
].map((id) => [id.replace(/-/g, "_"), document.getElementById(id)]));

let datos = null;
let viendo = null;
const marcadas = new Set();

function numeros(valor) {
  return como_lista(valor).map(Number);
}

function dos_cifras(n) {
  return String(n).padStart(2, "0");
}

function valor_parametro(v) {
  if (typeof v === "number") return formato_corto(v);
  if (typeof v === "boolean") return v ? "sí" : "no";
  return String(v);
}

function texto_dimension(p) {
  if (p.representacion !== "continuo") return `con n = ${p.dim}`;
  return p.dim === 1 ? "en una dimensión" : `en ${p.dim} dimensiones`;
}

// Primera iteracion en que la curva llega a su valor final (donde se ve que toca fondo).
function iteracion_del_mejor(valores) {
  return valores.indexOf(valores[valores.length - 1]);
}

// ---------------------------------------------------------------- inicio

function iniciar(d) {
  d.ejecuciones = como_lista(d.ejecuciones).map((e) => {
    e.convergencia = numeros(e.convergencia);
    e.mejor_valor = numeros(e.mejor_valor)[0];
    e.problema.f_optimo = numeros(e.problema.f_optimo)[0];
    e.parametros = como_lista(e.parametros);
    e.llego = iteracion_del_mejor(e.convergencia);
    return e;
  });
  nombrar(d.ejecuciones);
  datos = d;
  d.ejecuciones.forEach((e) => marcadas.add(e.numero));
  viendo = d.ejecuciones.find((e) => e.numero === d.elegida) || d.ejecuciones[d.ejecuciones.length - 1];

  dibujar_riel(document.getElementById("riel"), PASOS.length, Number(d.n_guardadas) || 0,
    (paso) => puente.enviar("ir_a_paso", { paso }));
  dibujar_todo();
}

// Nombre corto de cada ejecucion. Si hay varias del mismo algoritmo en el mismo grupo se
// distinguen por los parametros que cambian ("PSO, w = 0.7"); si cambian muchos o ninguno,
// por su numero ("PSO · 03").
function nombrar(ejecuciones) {
  const juntas = {};
  ejecuciones.forEach((e) => (juntas[`${e.grupo}|${e.algoritmo.id}`] ||= []).push(e));
  Object.values(juntas).forEach((lista) => {
    if (lista.length === 1) {
      lista[0].nombre = lista[0].algoritmo.nombre;
      return;
    }
    const cambian = lista[0].parametros.filter((p, k) =>
      lista.some((e) => valor_parametro(e.parametros[k].valor) !== valor_parametro(p.valor)));
    lista.forEach((e) => {
      const partes = cambian.map((p) => {
        const v = valor_parametro(e.parametros.find((q) => q.nombre === p.nombre).valor);
        return p.corta ? `${p.corta} = ${v}` : `${p.etiqueta.toLowerCase()} ${v}`;
      });
      e.nombre = partes.length && partes.length <= 2
        ? `${e.algoritmo.siglas}, ${partes.join(", ")}`
        : `${e.algoritmo.siglas} · ${dos_cifras(e.numero)}`;
    });
    lista.forEach((e) => {
      if (lista.some((o) => o !== e && o.nombre === e.nombre)) e.nombre += ` · ${dos_cifras(e.numero)}`;
    });
  });
}

// ---------------------------------------------------------------- estado

function comparables() {
  return datos.ejecuciones.filter((e) => e.grupo === viendo.grupo);
}

function activas() {
  return comparables().filter((e) => marcadas.has(e.numero));
}

function color_de(e) {
  const i = comparables().indexOf(e);
  return i < 0 ? COLOR_AJENA : COLORES[i % COLORES.length];
}

function razon(e) {
  const p = e.problema, ref = viendo.problema;
  if (p.nombre !== ref.nombre) return `Otro problema: ${p.nombre}`;
  if (p.dim !== ref.dim) return `Otra dimensión: ${p.dim}`;
  if (p.sentido !== ref.sentido) return p.sentido === "max" ? "Aquí se maximizó" : "Aquí se minimizó";
  return "Otros límites o datos del problema";
}

// Las que llegaron al mejor valor (con tolerancia) y, de ellas, la que llego primero.
function ganadoras(lista) {
  if (lista.length < 2) return { mejores: [], primera: null };
  const max = viendo.problema.sentido === "max";
  const finitos = lista.map((e) => e.mejor_valor).filter((v) => !Number.isNaN(v));
  if (!finitos.length) return { mejores: [], primera: null };
  const mejor = max ? Math.max(...finitos) : Math.min(...finitos);
  const tol = Number.isFinite(mejor) ? 1e-12 * Math.max(1, Math.abs(mejor)) : 0;
  const mejores = lista.filter((e) => e.mejor_valor === mejor || Math.abs(e.mejor_valor - mejor) <= tol);
  const primera = mejores.reduce((a, e) => (e.llego < a.llego ? e : a));
  return { mejores, primera, mejor };
}

// ---------------------------------------------------------------- dibujo

function dibujar_todo() {
  dibujar_subtitulo();
  dibujar_lista();
  dibujar_ficha();
  dibujar_tabla();
  dibujar_grafica();
  el.exportar.disabled = activas().length === 0;
}

function dibujar_subtitulo() {
  const p = viendo.problema;
  let texto = `Sobre ${p.nombre} ${texto_dimension(p)}, ${p.sentido === "max" ? "maximizando" : "minimizando"}.`;
  const lista = activas();
  if (lista.length) {
    const its = [...new Set(lista.map((e) => e.n_iteraciones))];
    const semillas = [...new Set(lista.map((e) => e.semilla))];
    const rango = `${Math.min(...its)} a ${Math.max(...its)}`;
    const quien = lista.length > 1 ? "Todas con" : "Con";
    if (its.length === 1 && semillas.length === 1) {
      texto += ` ${quien} ${its[0]} iteraciones y semilla ${semillas[0]}.`;
    } else if (its.length === 1) {
      texto += ` Todas con ${its[0]} iteraciones, con semillas distintas.`;
    } else if (semillas.length === 1) {
      texto += ` Semilla ${semillas[0]}, pero las iteraciones cambian (${rango}): la comparación no es pareja.`;
    } else {
      texto += ` Cambian las iteraciones (${rango}) y las semillas: la comparación no es pareja.`;
    }
  }
  el.subtitulo.textContent = texto;
}

function dibujar_lista() {
  el.ejecuciones.innerHTML = datos.ejecuciones.map((e) => {
    const ajena = e.grupo !== viendo.grupo;
    const marcada = !ajena && marcadas.has(e.numero);
    const clases = ["fila", e === viendo ? "viendo" : "", ajena ? "ajena" : "", !ajena && !marcada ? "apagada" : ""]
      .filter(Boolean).join(" ");
    return `<li class="${clases}" data-numero="${e.numero}">
      <button type="button" class="casilla" role="checkbox" aria-checked="${marcada}"
        aria-label="Mostrar ${e.nombre} en la gráfica"${ajena ? " disabled" : ""}
        style="--serie: ${color_de(e)}; --halo: ${color_de(e)}2E"><span class="punto" aria-hidden="true"></span></button>
      <button type="button" class="nombre" aria-pressed="${e === viendo}" title="Ver su configuración">
        <span>${e.nombre}</span>${ajena ? `<span class="razon">${razon(e)}</span>` : ""}
      </button>
      <span class="numero" title="Ejecución ${dos_cifras(e.numero)}">${dos_cifras(e.numero)}</span>
    </li>`;
  }).join("");
}

function dibujar_ficha() {
  const e = viendo;
  el.ficha_numero.textContent = `Configuración de la ejecución ${dos_cifras(e.numero)}`;
  el.ficha_nombre.textContent = e.algoritmo.nombre;
  const fila = (etiqueta, valor) => `<div class="ficha-fila"><dt>${etiqueta}</dt><dd>${valor}</dd></div>`;
  const param = (p) => fila(`${p.etiqueta}${p.corta ? ` ${p.corta}` : ""}`, valor_parametro(p.valor));
  el.ficha_lista.innerHTML =
    e.parametros.filter((p) => !p.comun).map(param).join("") +
    e.parametros.filter((p) => p.comun).map(param).join("") +
    fila("Iteraciones hechas", `${e.iteraciones}, ${MOTIVOS[e.motivo] || e.motivo}`) +
    fila("Evaluaciones de f", formato_corto(e.evaluaciones));
}

function dibujar_tabla() {
  dibujar_filas();
  const s = el.tabla_seccion;
  s.classList.remove("desborda");
  s.classList.toggle("desborda", s.scrollHeight > s.clientHeight + 1);
}

function dibujar_filas() {
  const lista = activas();
  if (!lista.length) {
    el.tabla.innerHTML = '<tr class="vacia"><td colspan="4">Marca al menos una ejecución.</td></tr>';
    el.estado.textContent = "Marca al menos una ejecución.";
    el.estado.classList.remove("error");
    return;
  }
  const { mejores, primera, mejor } = ganadoras(lista);
  el.tabla.innerHTML = lista.map((e) => {
    const f = mejores.includes(e) && mejores.length < lista.length ? ' class="destacado"' : "";
    const it = e === primera ? ' class="destacado"' : "";
    return `<tr>
      <td><span><span class="muestra" style="background: ${color_de(e)}"></span>${e.nombre}</span></td>
      <td${f}>${formato_corto(e.mejor_valor)}</td>
      <td${it}>${e.llego}</td>
      <td>${formato_corto(e.evaluaciones)}</td>
    </tr>`;
  }).join("");

  let resumen;
  if (lista.length === 1) {
    resumen = `Solo está marcada ${lista[0].nombre}; marca otra para comparar.`;
  } else if (mejores.length === 1) {
    resumen = `La de mejor valor fue ${primera.nombre}: f = ${formato_corto(mejor)}, en la iteración ${primera.llego}.`;
  } else {
    const cuantas = mejores.length === lista.length ? "Todas" : `${mejores.length}`;
    resumen = `${cuantas} llegaron a f = ${formato_corto(mejor)}; la más rápida fue ${primera.nombre}, en la iteración ${primera.llego}.`;
  }
  el.estado.textContent = resumen;
  el.estado.classList.remove("error");
}

// Al maximizar la escala es lineal. Al minimizar con optimo conocido distinto de 0 se grafica
// f − f* para poder usar escala log; si no, el mejor f tal cual.
function escala_de(lista) {
  const p = viendo.problema;
  const todos = lista.flatMap((e) => e.convergencia);
  if (p.sentido === "max") return { escala: escala_convergencia(todos, false), restar: 0 };
  const fopt = p.f_optimo;
  const tol = 1e-5 * Math.max(1, Math.abs(fopt));
  if (Number.isFinite(fopt) && fopt !== 0 && todos.filter(Number.isFinite).every((v) => v >= fopt - tol)) {
    return { escala: escala_convergencia(todos.map((v) => Math.max(0, v - fopt))), restar: fopt };
  }
  return { escala: escala_convergencia(todos), restar: 0 };
}

function dibujar_grafica() {
  if (!datos) return;
  const lista = activas();
  const { escala, restar } = escala_de(lista);
  const total = Math.max(1, ...lista.map((e) => e.convergencia.length - 1));
  const series = lista.map((e) => ({
    color: color_de(e),
    valores: restar ? e.convergencia.map((v) => Math.max(0, v - restar)) : e.convergencia
  }));
  const etiqueta = `Mejor f${restar ? " − f*" : ""}${escala.tipo === "log" ? ", escala log" : ""}`;
  dibujar_convergencias(el.convergencia, series, total, escala, etiqueta);
}

// ---------------------------------------------------------------- eventos

el.ejecuciones.addEventListener("click", (evento) => {
  const fila = evento.target.closest("[data-numero]");
  if (!fila) return;
  const e = datos.ejecuciones.find((x) => x.numero === Number(fila.dataset.numero));
  if (evento.target.closest(".casilla")) {
    if (marcadas.has(e.numero)) marcadas.delete(e.numero);
    else marcadas.add(e.numero);
  } else if (evento.target.closest(".nombre")) {
    viendo = e;
  } else {
    return;
  }
  dibujar_todo();
  const enfocar = evento.target.closest(".casilla") ? ".casilla" : ".nombre";
  el.ejecuciones.querySelector(`[data-numero="${e.numero}"] ${enfocar}`).focus();
});

el.volver.addEventListener("click", () => puente.enviar("volver"));
el.exportar.addEventListener("click", () =>
  puente.enviar("exportar", { numeros: activas().map((e) => e.numero) }));

new ResizeObserver(dibujar_grafica).observe(el.convergencia.parentElement);
new ResizeObserver(() => datos && dibujar_tabla()).observe(el.tabla_seccion);

puente.escuchar("datos", iniciar);
puente.escuchar("exportado", ({ texto, ok }) => {
  el.estado.textContent = texto;
  el.estado.classList.toggle("error", !ok);
});

puente.al_iniciar((con_matlab) => {
  if (con_matlab) {
    puente.enviar("lista");
  } else {
    puente.recibir("datos", DEMO_COMPARAR.datos());
  }
});
