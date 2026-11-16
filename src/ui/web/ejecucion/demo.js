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

  // Horario: secciones reales de horario/demo.js y una busqueda inventada que cambia una
  // seccion a la vez. En la app el historial y el desglose llegan de MATLAB.
  function datos_horario() {
    const CLAVES = ["V0723", "V0718", "IL364", "CB224", "V0726"];
    const COLORES = ["#0072BD", "#D95319", "#7E2F8E", "#2B9FD0", "#A2142F"];
    const oferta = DEMO_HORARIO.oferta.secciones.filter((s) => CLAVES.includes(s.clave) && como_lista(s.sesiones).length);
    const materias = CLAVES.map((clave, k) => ({ clave, nombre: oferta.find((s) => s.clave === clave).materia, color: COLORES[k] }));
    const secciones = oferta.map((s) => ({ ...s, materia: CLAVES.indexOf(s.clave), sesiones: como_lista(s.sesiones) }));
    const preferencias = { entrada: 9, salida: 19, dias_libres: [false, false, false, false, true, false] };
    const min = (hhmm) => Math.floor(hhmm / 100) * 60 + (hhmm % 100);

    function desglose(elegidas) {
      let choques = 0, muertas = 0, fuera = 0, libres = 0;
      for (let d = 0; d < 6; d++) {
        const ses = elegidas.flatMap((k) => secciones[k].sesiones.filter((x) => x.dias[d] !== ".")
          .map((x) => [min(x.inicio), min(x.fin) + 5, k])).sort((a, b) => a[0] - b[0]);
        ses.forEach((a, i) => ses.slice(i + 1).forEach((b) => { if (b[0] < a[1] && b[2] !== a[2]) choques++; }));
        for (let i = 1; i < ses.length; i++) muertas += Math.max(0, ses[i][0] - Math.max(...ses.slice(0, i).map((x) => x[1]))) / 60;
        ses.forEach(([a, b]) => { fuera += (Math.max(0, Math.min(b, 540) - a) + Math.max(0, b - Math.max(a, 1140))) / 60; });
        if (preferencias.dias_libres[d] && ses.length) libres++;
      }
      const por_materia = CLAVES.map((_, m) => elegidas.filter((k) => secciones[k].materia === m).length);
      const materias_sin_seccion = por_materia.filter((n) => n !== 1).length;
      const f = muertas + 2 * fuera + 5 * libres + 100 * (choques + materias_sin_seccion);
      return { choques, horas_muertas: muertas, materias_sin_seccion, f };
    }

    const azar_de = (lista) => lista[Math.floor(azar() * lista.length)];
    const opciones = CLAVES.map((_, m) => secciones.map((s, k) => (s.materia === m ? k : -1)).filter((k) => k >= 0));
    let actual = opciones.map((o, m) => (m === 3 ? [] : [azar_de(o), ...(m === 1 ? [azar_de(o)] : [])])).flat();
    let mejor = desglose(actual);
    const total = 90, mejor_valor = [], cambios = [], soluciones = [];
    for (let t = 0; t <= total; t++) {
      if (t > 0) {
        for (let intento = 0; intento < 6; intento++) {
          const m = Math.floor(azar() * CLAVES.length);
          const nueva = actual.filter((k) => secciones[k].materia !== m).concat(azar_de(opciones[m]));
          const d = desglose(nueva);
          if (d.f < mejor.f) { actual = nueva; mejor = d; }
        }
      }
      if (t === 0 || mejor.f < mejor_valor[t - 1]) {
        cambios.push(t);
        soluciones.push({ ...mejor, elegidas: [...actual], bits: secciones.map((_, k) => (actual.includes(k) ? 1 : 0)) });
      }
      mejor_valor.push(mejor.f);
    }

    return {
      algoritmo: { id: "ga", nombre: "Algoritmo genético", siglas: "GA", individuos: "individuos",
                   simbolo: "x*", continuidad: false },
      problema: { nombre: "Horario de materias", dim: secciones.length, lb: 0, ub: 1, sentido: "min",
                  representacion: "binario", f_optimo: null, x_optimo: [] },
      parametros: [
        { nombre: "tam_poblacion", etiqueta: "Población", corta: "", valor: 60, comun: false },
        { nombre: "tasa_mutacion", etiqueta: "Tasa de mutación", corta: "", valor: 0.02, comun: false },
        { nombre: "n_iteraciones", etiqueta: "Generaciones", corta: "", valor: total, comun: true },
        { nombre: "semilla", etiqueta: "Semilla", corta: "", valor: 7, comun: true }
      ],
      iteraciones: total,
      motivo: "max_iteraciones",
      historial: { mejor_valor, mejor_solucion: mejor_valor.map(() => [0]), distancia: [],
                   poblacion: [[[0, 0]]], paso_poblacion: total + 1, n_individuos: 60 },
      mapa: { tipo: "ninguno" },
      horario: { materias, secciones, preferencias, cambios, soluciones },
      n_guardadas: 2
    };
  }

  return { datos, datos_horario };
})();
