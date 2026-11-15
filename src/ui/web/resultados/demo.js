// Datos de ejemplo para disenar en el navegador sin MATLAB. Reusa la busqueda inventada de
// la demo de ejecucion (ejecucion/demo.js) y le da la forma que manda pantalla_resultados.m.

const DEMO_RESULTADOS = (() => {
  function datos() {
    const e = DEMO.datos();
    const h = e.historial;
    const n = h.mejor_valor.length;
    const filas = h.mejor_valor.map((v, k) => k).filter((k) => k === 0 || h.mejor_valor[k] !== h.mejor_valor[k - 1]);
    const ruta = h.mejor_solucion.filter((x, k) => k === 0
      || x.some((v, j) => v !== h.mejor_solucion[k - 1][j]));
    return {
      algoritmo: e.algoritmo,
      problema: e.problema,
      parametros: e.parametros,
      mejor_valor: h.mejor_valor[n - 1],
      mejor_solucion: h.mejor_solucion[n - 1],
      iteraciones: e.iteraciones,
      motivo: e.motivo,
      evaluaciones: 30 * (e.iteraciones + 1),
      tiempo: 0.21,
      convergencia: h.mejor_valor,
      mejoras: {
        iteracion: filas,
        valor: filas.map((k) => h.mejor_valor[k]),
        solucion: filas.map((k) => h.mejor_solucion[k]),
        total: filas.length
      },
      inicio: h.poblacion[0],
      ruta,
      mapa: e.mapa,
      numero: 6,
      n_guardadas: 6
    };
  }

  return { datos };
})();
