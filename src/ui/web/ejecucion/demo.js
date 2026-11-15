// Datos de ejemplo para disenar en el navegador sin MATLAB. En la app llegan de
// pantalla_ejecucion.m con el historial real del algoritmo; aqui solo se imita su forma:
// el movimiento es inventado (las particulas se acercan al origen con ruido).

const DEMO = (() => {
  const PARULA = ["#3E26A8", "#484CEF", "#347AFD", "#21A3E3", "#12BEB9", "#5CCC76", "#C8C129", "#FECA33", "#F9FB15"];
  const LIM = 5.12;
  const N = 30;
  const ITERACIONES = 200;

  const rastrigin = ([x, y]) => 20 + x * x - 10 * Math.cos(2 * Math.PI * x) + y * y - 10 * Math.cos(2 * Math.PI * y);

  // Pseudoaleatorio con semilla, para que la demo sea igual cada vez.
  let semilla = 42;
  const azar = () => ((semilla = (semilla * 16807) % 2147483647) / 2147483647);

  function color(t) {
    const k = Math.min(PARULA.length - 2, Math.floor(t * (PARULA.length - 1)));
    const f = t * (PARULA.length - 1) - k;
    const [a, b] = [PARULA[k], PARULA[k + 1]].map((c) => [1, 3, 5].map((i) => parseInt(c.slice(i, i + 2), 16)));
    return a.map((v, i) => Math.round(v + (b[i] - v) * f));
  }

  function imagen(z) {
    const n = 160;
    const lienzo = document.createElement("canvas");
    lienzo.width = lienzo.height = n;
    const ctx = lienzo.getContext("2d");
    const datos = ctx.createImageData(n, n);
    for (let a = 0; a < n; a++) {
      for (let b = 0; b < n; b++) {
        const x = -LIM + 2 * LIM * b / (n - 1), y = LIM - 2 * LIM * a / (n - 1);
        const [r, g, bl] = color((rastrigin([x, y]) - z[0]) / (z[1] - z[0]));
        datos.data.set([r, g, bl, 255], (a * n + b) * 4);
      }
    }
    ctx.putImageData(datos, 0, 0);
    return lienzo.toDataURL();
  }

  function historial() {
    let X = Array.from({ length: N }, () => [(2 * azar() - 1) * LIM, (2 * azar() - 1) * LIM]);
    const mejor_valor = [], mejor_solucion = [], distancia = [], poblacion = [];
    let mejor = null, f_mejor = Infinity;
    for (let t = 0; t <= ITERACIONES; t++) {
      if (t > 0) {
        const ruido = 1.6 * Math.exp(-t / 45);
        X = X.map(([x, y]) => [x, y].map((v, j) => {
          const destino = mejor[j];
          const nuevo = v + 0.12 * (destino - v) + ruido * (azar() - 0.5);
          return Math.max(-LIM, Math.min(LIM, nuevo));
        }));
      }
      X.forEach((p) => {
        const f = rastrigin(p);
        if (f < f_mejor) { f_mejor = f; mejor = p.slice(); }
      });
      mejor_valor.push(f_mejor);
      mejor_solucion.push(mejor.slice());
      distancia.push(Math.hypot(...mejor));
      poblacion.push(X.map((p) => p.slice()));
    }
    return { mejor_valor, mejor_solucion, distancia, poblacion, paso_poblacion: 1, n_individuos: N };
  }

  function datos() {
    const z = [0, 80.7];
    return {
      algoritmo: { id: "pso", nombre: "Enjambre de partículas", siglas: "PSO",
                   individuos: "partículas", simbolo: "g", continuidad: true },
      problema: { nombre: "Rastrigin", dim: 2, lb: -LIM, ub: LIM, sentido: "min",
                  representacion: "continuo", f_optimo: 0, x_optimo: [0, 0] },
      parametros: [
        { nombre: "n_particulas", etiqueta: "Número de partículas", corta: "", valor: N, comun: false },
        { nombre: "w", etiqueta: "Inercia", corta: "w", valor: 0.7, comun: false },
        { nombre: "c1", etiqueta: "Coeficiente cognitivo", corta: "c₁", valor: 1.5, comun: false },
        { nombre: "c2", etiqueta: "Coeficiente social", corta: "c₂", valor: 1.5, comun: false },
        { nombre: "fraccion_vmax", etiqueta: "Velocidad máxima", corta: "", valor: 0.2, comun: false },
        { nombre: "n_iteraciones", etiqueta: "Iteraciones", corta: "", valor: ITERACIONES, comun: true },
        { nombre: "semilla", etiqueta: "Semilla", corta: "", valor: 42, comun: true },
        { nombre: "paciencia", etiqueta: "Paciencia", corta: "", valor: 0, comun: true }
      ],
      iteraciones: ITERACIONES,
      motivo: "max_iteraciones",
      historial: historial(),
      mapa: { tipo: "superficie", x: [-LIM, LIM], y: [-LIM, LIM], z, imagen: imagen(z),
              colores: PARULA, corte: false },
      n_guardadas: 0
    };
  }

  return { datos };
})();
