// Datos de ejemplo para disenar en el navegador sin MATLAB. Las curvas son inventadas
// (escalones que bajan al azar); en la app llegan los historiales reales de MATLAB.

const DEMO_COMPARAR = (() => {
  function azar(semilla) {
    let s = semilla;
    return () => ((s = (s * 16807) % 2147483647) / 2147483647);
  }

  function curva(semilla, rapidez, iteraciones = 200) {
    const r = azar(semilla);
    const valores = [20 + 10 * r()];
    for (let k = 1; k <= iteraciones; k++) {
      const v = valores[k - 1];
      valores.push(r() < 0.25 ? Math.max(0, v * Math.pow(10, -rapidez * r())) : v);
    }
    return valores.map((v) => (v < 1e-12 ? 0 : Number(v.toPrecision(6))));
  }

  const comunes = (semilla) => [
    { nombre: "n_iteraciones", etiqueta: "Número de iteraciones", corta: "", valor: 200, comun: true },
    { nombre: "semilla", etiqueta: "Semilla aleatoria", corta: "", valor: semilla, comun: true },
    { nombre: "paciencia", etiqueta: "Paciencia", corta: "", valor: 0, comun: true }
  ];
  const pso = (w) => [...comunes(42),
    { nombre: "n_particulas", etiqueta: "Número de partículas", corta: "", valor: 30, comun: false },
    { nombre: "w", etiqueta: "Inercia", corta: "w", valor: w, comun: false },
    { nombre: "c1", etiqueta: "Coeficiente cognitivo", corta: "c₁", valor: 1.5, comun: false },
    { nombre: "c2", etiqueta: "Coeficiente social", corta: "c₂", valor: 1.5, comun: false }];

  const rastrigin = { nombre: "Rastrigin", dim: 2, sentido: "min", representacion: "continuo", f_optimo: 0 };
  const ackley = { nombre: "Ackley", dim: 5, sentido: "min", representacion: "continuo", f_optimo: 0 };
  const alg = (id, nombre, siglas) => ({ id, nombre, siglas });

  function ejecucion(numero, algoritmo, problema, grupo, parametros, semilla, rapidez, evaluaciones) {
    const convergencia = curva(semilla, rapidez);
    return {
      numero, algoritmo, problema, grupo, parametros,
      mejor_valor: convergencia[convergencia.length - 1],
      iteraciones: 200, n_iteraciones: 200, semilla: 42,
      evaluaciones, motivo: "max_iteraciones", convergencia
    };
  }

  function datos() {
    return {
      ejecuciones: [
        ejecucion(1, alg("pso", "Enjambre de partículas", "PSO"), rastrigin, 1, pso(0.7), 7, 1.2, 6030),
        ejecucion(2, alg("pso", "Enjambre de partículas", "PSO"), rastrigin, 1, pso(0.4), 11, 2, 6030),
        ejecucion(3, alg("ga", "Algoritmo genético", "GA"), rastrigin, 1, comunes(42), 23, 2.6, 12060),
        ejecucion(4, alg("de", "Evolución diferencial", "DE"), rastrigin, 1, comunes(42), 5, 1.5, 10050),
        ejecucion(5, alg("pso", "Enjambre de partículas", "PSO"), ackley, 2, pso(0.7), 3, 0.8, 6030)
      ],
      elegida: 1,
      n_guardadas: 5
    };
  }

  return { datos };
})();
