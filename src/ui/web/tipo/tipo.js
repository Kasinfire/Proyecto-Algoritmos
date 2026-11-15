// Pantalla 1: tipo de problema.
//
// Eventos que llegan de MATLAB:
//   "datos"    { tipos: [{id, nombre, notacion, descripcion, problemas, algoritmos}],
//                real: {id, nombre, insignia, descripcion, algoritmos, detalle, disponible},
//                seleccionado, n_guardadas }
// Eventos que se mandan a MATLAB:
//   "lista"      la pagina ya puede recibir datos
//   "elegir"     { tipo }
//   "siguiente"  { tipo }
//   "ir_a_paso"  { paso }   (desde el riel)
//   "comparar", "ayuda"

const estado = { tipos: [], real: null, seleccionado: "", n_guardadas: 0 };

const tarjetas = document.getElementById("tarjetas");
const resumen = document.getElementById("resumen");
const boton_siguiente = document.getElementById("siguiente");

// Muestra hasta `maximo` nombres; el resto se resume para no saturar la tarjeta.
function texto_lista(valores, maximo = 3) {
  if (valores.length <= maximo) return valores.join(" · ");
  return valores.slice(0, maximo).join(" · ") + ` y ${valores.length - maximo} más`;
}

function dibujar() {
  dibujar_riel(document.getElementById("riel"), 0, estado.n_guardadas,
    (paso) => puente.enviar("ir_a_paso", { paso }));

  tarjetas.innerHTML = "";
  estado.tipos.forEach((tipo, i) => {
    const problemas = como_lista(tipo.problemas);
    const algoritmos = como_lista(tipo.algoritmos);
    const elegido = tipo.id === estado.seleccionado;

    const bloqueada = algoritmos.length === 0;
    const tarjeta = document.createElement("div");
    tarjeta.className = "tarjeta vidrio";
    tarjeta.setAttribute("role", "radio");
    tarjeta.setAttribute("aria-checked", String(elegido));
    tarjeta.tabIndex = elegido || (!estado.seleccionado && i === 0) ? 0 : -1;
    tarjeta.setAttribute("aria-disabled", String(bloqueada));
    tarjeta.dataset.id = tipo.id;
    tarjeta.innerHTML = `
      <figure class="tarjeta-figura">${ILUSTRACIONES[tipo.id] || ""}</figure>
      <div class="tarjeta-texto">
        <div class="tarjeta-titulo">
          <span class="tarjeta-nombre">${tipo.nombre}</span>
          <span class="tarjeta-notacion">${tipo.notacion}</span>
        </div>
        <p class="tarjeta-descripcion">${tipo.descripcion}</p>
        <dl class="tarjeta-datos">
          <div><dt>Problemas</dt><dd class="${problemas.length ? "" : "vacio"}">${texto_lista(problemas) || "En desarrollo"}</dd></div>
          <div><dt>Algoritmos</dt><dd class="${algoritmos.length ? "" : "vacio"}">${texto_lista(algoritmos) || "Ninguno todavía"}</dd></div>
        </dl>
      </div>`;
    agregar_tarjeta(tarjeta, tipo.id, !bloqueada);
  });

  if (estado.real) dibujar_real(estado.real);
  actualizar_acciones();
}

// Tarjeta del problema de aplicacion real: mas angosta, con insignia y sin la lista
// de problemas, porque es uno solo.
function dibujar_real(real) {
  const algoritmos = como_lista(real.algoritmos);
  const elegido = real.id === estado.seleccionado;
  const tarjeta = document.createElement("div");
  tarjeta.className = "tarjeta tarjeta-real vidrio";
  tarjeta.setAttribute("role", "radio");
  tarjeta.setAttribute("aria-checked", String(elegido));
  tarjeta.tabIndex = elegido ? 0 : -1;
  tarjeta.setAttribute("aria-disabled", String(algoritmos.length === 0));
  tarjeta.dataset.id = real.id;
  tarjeta.innerHTML = `
    <figure class="tarjeta-figura">${ILUSTRACIONES.real}</figure>
    <div class="tarjeta-texto">
      <div class="tarjeta-titulo">
        <span class="tarjeta-nombre">${real.nombre}</span>
        <span class="insignia">${real.insignia}</span>
      </div>
      <p class="tarjeta-descripcion">${real.descripcion}</p>
      <p class="tarjeta-pie">${[algoritmos.join(", "), real.detalle].filter(Boolean).join(" · ")}</p>
    </div>`;
  agregar_tarjeta(tarjeta, real.id, algoritmos.length > 0);
}

function agregar_tarjeta(tarjeta, id, activa) {
  if (activa) {
    tarjeta.addEventListener("click", () => elegir(id));
    tarjeta.addEventListener("dblclick", () => { elegir(id); continuar(); });
  }
  tarjetas.appendChild(tarjeta);
}

function actualizar_acciones() {
  const real = estado.real && estado.real.id === estado.seleccionado ? estado.real : null;
  const tipo = real || estado.tipos.find((t) => t.id === estado.seleccionado);
  boton_siguiente.disabled = !tipo || (real && !real.disponible);
  if (!tipo) {
    resumen.textContent = "Elige un tipo para continuar.";
    return;
  }
  if (real && !real.disponible) {
    resumen.textContent = `${real.nombre}: el problema todavía no está en src/problemas/real/.`;
    return;
  }
  const n_alg = como_lista(tipo.algoritmos).length;
  resumen.textContent = `${tipo.nombre}: ${n_alg} ${n_alg === 1 ? "algoritmo disponible" : "algoritmos disponibles"}.`;
}

function elegir(id) {
  if (id === estado.seleccionado) return;
  estado.seleccionado = id;
  tarjetas.querySelectorAll(".tarjeta").forEach((t) => {
    const elegido = t.dataset.id === id;
    t.setAttribute("aria-checked", String(elegido));
    t.tabIndex = elegido ? 0 : -1;
  });
  actualizar_acciones();
  puente.enviar("elegir", { tipo: id });
}

function continuar() {
  if (estado.seleccionado && !boton_siguiente.disabled) puente.enviar("siguiente", { tipo: estado.seleccionado });
}

// Flechas para moverse entre tarjetas, como en un grupo de radio.
tarjetas.addEventListener("keydown", (e) => {
  const lista = [...tarjetas.querySelectorAll('.tarjeta:not([aria-disabled="true"])')];
  const i = lista.indexOf(document.activeElement);
  if (i < 0) return;
  const paso = { ArrowRight: 1, ArrowDown: 1, ArrowLeft: -1, ArrowUp: -1 }[e.key];
  if (paso) {
    e.preventDefault();
    const siguiente = lista[(i + paso + lista.length) % lista.length];
    siguiente.focus();
    elegir(siguiente.dataset.id);
  } else if (e.key === " ") {
    e.preventDefault();
    elegir(document.activeElement.dataset.id);
  } else if (e.key === "Enter") {
    e.preventDefault();
    elegir(document.activeElement.dataset.id);
    continuar();
  }
});

boton_siguiente.addEventListener("click", continuar);

puente.escuchar("datos", (datos) => {
  estado.tipos = como_lista(datos.tipos);
  estado.real = datos.real || null;
  estado.seleccionado = datos.seleccionado || "";
  estado.n_guardadas = Number(datos.n_guardadas) || 0;
  dibujar();
});

puente.al_iniciar((con_matlab) => {
  if (con_matlab) {
    puente.enviar("lista");
    return;
  }
  // Modo diseno en navegador: los mismos datos que manda tipos_de_problema.m.
  puente.recibir("datos", {
    tipos: [
      { id: "continuo", nombre: "Continuo", notacion: "x ∈ ℝⁿ",
        descripcion: "Vector de números reales dentro de un rango. Buscar el punto más bajo de una superficie.",
        problemas: ["Esfera", "Rastrigin", "Ackley", "Rosenbrock", "Griewank", "Schwefel", "Zakharov"],
        algoritmos: ["GA", "PSO"] },
      { id: "binario", nombre: "Binario", notacion: "x ∈ {0,1}ⁿ",
        descripcion: "Vector de ceros y unos. Cada bit decide si algo se toma o no, como en la mochila.",
        problemas: [], algoritmos: ["GA", "PSO"] },
      { id: "permutacion", nombre: "Permutación", notacion: "π ∈ Sₙ",
        descripcion: "Un orden de los elementos 1 a n. Por ejemplo, el orden en que se visitan ciudades.",
        problemas: [], algoritmos: ["GA", "PSO"] }
    ],
    real: { id: "real", nombre: "Aplicación real", insignia: "Bonus",
      descripcion: "Armar tu horario del semestre con la oferta real: sin choques y con pocas horas muertas.",
      algoritmos: ["GA", "PSO", "DE"], detalle: "una sección por materia", disponible: false },
    seleccionado: "", n_guardadas: 0
  });
});
