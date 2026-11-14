// Riel lateral con los cinco pasos del flujo. Lo comparten todas las pantallas.

const PASOS = ["Tipo", "Problema", "Algoritmo", "Ejecución", "Resultados"];

const ICONO_LOGO = '<svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="#FFFFFF" stroke-width="1.4" stroke-linejoin="round" aria-hidden="true"><path d="M12 3.2c4.8 0 8.8 3.1 8.8 7.6 0 5-4.5 10-9.5 10C6.6 20.8 3.2 17.2 3.2 12.6 3.2 7.1 7 3.2 12 3.2z" stroke-opacity="0.45"/><path d="M12.7 7c3 0 5.2 2.1 5.2 4.8 0 3-2.7 5.6-5.6 5.6-2.7 0-4.6-2.1-4.6-4.7C7.7 9.6 9.8 7 12.7 7z" stroke-opacity="0.75"/><path d="M13.1 10.2c1.3 0 2.2.9 2.2 2 0 1.3-1.1 2.3-2.3 2.3-1.1 0-1.9-.9-1.9-2 0-1.3.8-2.3 2-2.3z"/><circle cx="13.1" cy="12.3" r="1.1" fill="#FF7A3D" stroke="none"/></svg>';
const ICONO_COMPARAR = '<svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M3 18c4-1 5-9 9-9s5 6 9 4M3 12c3 0 4-6 8-6s6 3 10 2"/></svg>';
const ICONO_AYUDA = '<svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" aria-hidden="true"><path d="M21 12a9 9 0 1 1-18 0 9 9 0 0 1 18 0zM9.5 9.2a2.5 2.5 0 1 1 3.4 2.3c-.6.3-.9.8-.9 1.4v.6M12 16.8v.2"/></svg>';

// paso_actual empieza en 0. Los pasos ya hechos se pueden visitar; los siguientes no.
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

  nav.innerHTML = `
    <span class="riel-logo" role="img" aria-label="Metaheurísticas">${ICONO_LOGO}</span>
    <span class="riel-separador" aria-hidden="true"></span>
    ${pasos}
    <div class="riel-pie">
      <button type="button" class="boton-redondo" data-accion="comparar"
        aria-label="Comparar ejecuciones (${n_guardadas} guardadas)" title="Comparar ejecuciones"
        ${n_guardadas > 0 ? "" : "disabled"}>${ICONO_COMPARAR}${contador}</button>
      <button type="button" class="boton-redondo" data-accion="ayuda"
        aria-label="Ayuda" title="Ayuda de esta pantalla">${ICONO_AYUDA}</button>
    </div>`;

  nav.querySelectorAll("[data-paso]").forEach((b) =>
    b.addEventListener("click", () => al_ir_a_paso(Number(b.dataset.paso))));
  nav.querySelector('[data-accion="comparar"]').addEventListener("click", () => puente.enviar("comparar"));
  nav.querySelector('[data-accion="ayuda"]').addEventListener("click", () => puente.enviar("ayuda", { paso: paso_actual }));
}
