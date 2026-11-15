// Iconos de linea para la lista de algoritmos (24 x 24, toman el color del texto).

const ICONOS_ALGORITMO = (() => {
  const svg = (trazos) => `<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor"
    stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">${trazos}</svg>`;
  return {
    ga: svg('<path d="M8 3c0 5.5 8 5.5 8 9s-8 3.5-8 9M16 3c0 5.5-8 5.5-8 9s8 3.5 8 9M9.2 6.5h5.6M9.2 17.5h5.6"/>'),
    aco: svg('<path d="M5 19c3.5-.5 3-6.5 7-7s4-6 7-7" stroke-dasharray="1.5 3"/><circle cx="5" cy="19" r="1.6"/><circle cx="19" cy="5" r="1.6"/>'),
    pso: svg('<circle cx="6" cy="17" r="1.5"/><circle cx="12" cy="9.5" r="1.5"/><circle cx="17" cy="15.5" r="1.5"/><path d="M7.6 15.2l2.6-3M13.6 7.6l3-3.1M18.6 13.6l2.4-2.4"/>'),
    ais: svg('<path d="M12 3l7 2.8v5.4c0 4.4-2.9 7.9-7 9.8-4.1-1.9-7-5.4-7-9.8V5.8L12 3z"/><circle cx="12" cy="11.5" r="2"/>'),
    de: svg('<path d="M6 18L18 6M10.5 6H18v7.5"/><circle cx="6" cy="18" r="1.5"/>')
  };
})();
