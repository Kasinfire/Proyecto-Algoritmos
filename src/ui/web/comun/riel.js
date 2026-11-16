// Riel lateral con los cinco pasos del flujo. Lo comparten todas las pantallas.

const PASOS = ["Tipo", "Problema", "Algoritmo", "Ejecución", "Resultados"];

const ICONO_LOGO = '<svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="#FFFFFF" stroke-width="1.4" stroke-linejoin="round" aria-hidden="true"><path d="M12 3.2c4.8 0 8.8 3.1 8.8 7.6 0 5-4.5 10-9.5 10C6.6 20.8 3.2 17.2 3.2 12.6 3.2 7.1 7 3.2 12 3.2z" stroke-opacity="0.45"/><path d="M12.7 7c3 0 5.2 2.1 5.2 4.8 0 3-2.7 5.6-5.6 5.6-2.7 0-4.6-2.1-4.6-4.7C7.7 9.6 9.8 7 12.7 7z" stroke-opacity="0.75"/><path d="M13.1 10.2c1.3 0 2.2.9 2.2 2 0 1.3-1.1 2.3-2.3 2.3-1.1 0-1.9-.9-1.9-2 0-1.3.8-2.3 2-2.3z"/><circle cx="13.1" cy="12.3" r="1.1" fill="#FF7A3D" stroke="none"/></svg>';
const ICONO_COMPARAR = '<svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M3 18c4-1 5-9 9-9s5 6 9 4M3 12c3 0 4-6 8-6s6 3 10 2"/></svg>';
const ICONO_AYUDA = '<svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" aria-hidden="true"><path d="M21 12a9 9 0 1 1-18 0 9 9 0 0 1 18 0zM9.5 9.2a2.5 2.5 0 1 1 3.4 2.3c-.6.3-.9.8-.9 1.4v.6M12 16.8v.2"/></svg>';

// Ayuda de cada pagina: un titulo y unos cuantos puntos. Si la pagina no esta, se usa la del paso.
const AYUDA = {
  "tipo": ["Tipo de problema", [
    "Elige qué clase de problema quieres resolver: continuo, binario, de permutación o el horario real.",
    "Cada tipo usa una codificación distinta de la solución, y no todos los algoritmos sirven para todos.",
    "Con Continuar pasas a elegir el problema concreto."]],
  "problema": ["Problema continuo", [
    "Elige una función de prueba y su dimensión con − y +.",
    "La vista previa muestra la superficie y dónde está el óptimo conocido.",
    "Continuar te lleva a elegir el algoritmo."]],
  "problema_binario": ["Problema binario", [
    "Elige el problema y ajusta sus datos: en la mochila, los objetos (peso y valor) y la capacidad.",
    "Puedes agregar objetos a mano o cargarlos de un CSV.",
    "La solución es una fila de bits: 1 si el objeto entra, 0 si no."]],
  "problema_tsp": ["Agente viajero", [
    "Elige cuántas ciudades quieres con − y +, o cárgalas de un CSV.",
    "La solución es el orden en que se visitan; f es la distancia total del recorrido.",
    "El mapa muestra las ciudades que va a recorrer el algoritmo."]],
  "horario": ["Tu horario del semestre", [
    "1 · Oferta: consulta SIIAU (o usa la oferta sin internet) para traer las secciones.",
    "2 · Materias: elige las materias que quieres llevar; el algoritmo escoge la sección de cada una.",
    "3 · Preferencias: hora de entrada y salida, días libres y cuánto te molestan las horas muertas.",
    "f castiga choques, horas muertas, horas fuera de tu rango y clases en tus días libres."]],
  "algoritmo": ["Elige el algoritmo", [
    "Solo aparecen los algoritmos que sirven para el tipo de problema que elegiste.",
    "Ajusta sus parámetros; si no sabes qué poner, los valores por defecto funcionan.",
    "La semilla hace que la ejecución se pueda repetir con el mismo resultado."]],
  "ejecucion": ["Ejecución", [
    "Aquí se ve la búsqueda iteración por iteración: la mejor solución y cómo baja f.",
    "Con la barra de reproducción puedes pausar, adelantar o regresar a un momento de la búsqueda.",
    "Al terminar pasas a Resultados, donde la ejecución se guarda."]],
  "resultados": ["Resultados", [
    "La mejor solución que encontró el algoritmo y su valor de f.",
    "Las pestañas muestran la convergencia, el historial de mejoras y la configuración usada.",
    "Descarga el resultado en CSV o JSON, corre otra vez o compara con ejecuciones guardadas.",
    "En el horario, Copiar NRC te deja la lista lista para pegar en SIIAU."]],
  "comparar": ["Comparar ejecuciones", [
    "Marca las ejecuciones guardadas que quieres ver juntas.",
    "La gráfica sobrepone sus convergencias y la tabla compara mejor f, tiempo e iteraciones.",
    "Solo tiene sentido comparar ejecuciones del mismo problema."]]
};
const AYUDA_POR_PASO = ["tipo", "problema", "algoritmo", "ejecucion", "resultados", "comparar"];
const AYUDA_SIEMPRE = "Los pasos de la izquierda te regresan a lo que ya hiciste; el logo te lleva al inicio.";

// paso_actual empieza en 0. Los pasos ya hechos se pueden visitar; los siguientes no.
// Con paso_actual = 5 (pantalla de comparar) todos quedan hechos y el boton de comparar activo.
function dibujar_riel(nav, paso_actual, n_guardadas, al_ir_a_paso) {
  const pasos = PASOS.map((nombre, i) => {
    const estado = i < paso_actual ? "hecho" : "";
    const actual = i === paso_actual ? ' aria-current="step"' : "";
    const bloqueado = i > paso_actual ? " disabled" : "";
    const conector = i < PASOS.length - 1 ? `<span class="riel-conector ${estado}"></span>` : "";
    return `<button type="button" class="riel-paso ${estado}" data-paso="${i}"${actual}${bloqueado}>
        <span class="riel-circulo">${i + 1}</span><span>${nombre}</span></button>${conector}`;
  }).join("");

  const contador = n_guardadas > 0 ? `<span class="contador">${n_guardadas}</span>` : "";
  const comparando = paso_actual === PASOS.length;

  nav.innerHTML = `
    <button type="button" class="riel-logo" data-accion="inicio" aria-label="Ir al inicio"
      title="Ir al inicio"${paso_actual === 0 ? " disabled" : ""}>${ICONO_LOGO}</button>
    <span class="riel-separador" aria-hidden="true"></span>
    ${pasos}
    <div class="riel-pie">
      <button type="button" class="boton-redondo${comparando ? " activo" : ""}" data-accion="comparar"${comparando ? ' aria-current="page"' : ""}
        aria-label="Comparar ejecuciones (${n_guardadas} guardadas)" title="Comparar ejecuciones"
        ${n_guardadas > 0 ? "" : "disabled"}>${ICONO_COMPARAR}${contador}</button>
      <button type="button" class="boton-redondo" data-accion="ayuda"
        aria-label="Ayuda" title="Ayuda de esta pantalla" aria-expanded="false" aria-controls="ayuda">${ICONO_AYUDA}</button>
    </div>`;

  nav.querySelectorAll("[data-paso]").forEach((b) =>
    b.addEventListener("click", () => al_ir_a_paso(Number(b.dataset.paso))));
  nav.querySelector('[data-accion="comparar"]').addEventListener("click", () => puente.enviar("comparar"));
  nav.querySelector('[data-accion="inicio"]').addEventListener("click", () => al_ir_a_paso(0));
  preparar_ayuda(nav.querySelector('[data-accion="ayuda"]'), paso_actual);
}

function preparar_ayuda(boton, paso_actual) {
  const pagina = location.pathname.split("/").pop().replace(".html", "");
  const [titulo, puntos] = AYUDA[pagina] || AYUDA[AYUDA_POR_PASO[paso_actual]];
  let panel = document.getElementById("ayuda");
  if (!panel) {
    panel = document.createElement("aside");
    panel.id = "ayuda";
    panel.className = "ayuda";
    panel.setAttribute("role", "dialog");
    panel.setAttribute("aria-labelledby", "ayuda-titulo");
    panel.hidden = true;
    document.body.appendChild(panel);
  }
  panel.innerHTML = `
    <div class="ayuda-cabeza"><h2 id="ayuda-titulo">${titulo}</h2>
      <button type="button" class="ayuda-cerrar" aria-label="Cerrar ayuda">×</button></div>
    <ol>${puntos.map((p) => `<li>${p}</li>`).join("")}</ol>
    <p>${AYUDA_SIEMPRE}</p>`;

  const abrir = (si) => {
    panel.hidden = !si;
    boton.setAttribute("aria-expanded", String(si));
    boton.classList.toggle("activo", si);
  };
  boton.addEventListener("click", (e) => { e.stopPropagation(); abrir(panel.hidden); });
  panel.querySelector(".ayuda-cerrar").addEventListener("click", () => { abrir(false); boton.focus(); });
  document.addEventListener("keydown", (e) => { if (e.key === "Escape" && !panel.hidden) { abrir(false); boton.focus(); } });
  document.addEventListener("click", (e) => { if (!panel.hidden && !panel.contains(e.target)) abrir(false); });
}
