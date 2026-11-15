// Datos de ejemplo para disenar en el navegador sin MATLAB. En la app llegan de
// problemas_de_tipo.m y las ciudades de ciudades_al_azar.m; aqui solo se imita su forma
// (las coordenadas no coinciden con las de MATLAB para la misma semilla).

const DEMO = (() => {
  const datos = {
    tipo: { id: "permutacion", nombre: "Permutación", notacion: "π ∈ Sₙ" },
    problemas: [
      { id: "tsp", nombre: "TSP", formula: "min Σ d(πᵢ, πᵢ₊₁)",
        descripcion: "Encuentra la ruta más corta que pasa una vez por cada ciudad y regresa al inicio.",
        sentido: "min", dim_min: 4, dim_max: 100, dim_defecto: 12, disponible: true,
        datos: { semilla: 7 } }
    ],
    seleccion: {},
    n_guardadas: 0
  };

  // mulberry32: un generador chico con semilla.
  function ciudades(n, semilla) {
    let a = semilla >>> 0;
    const azar = () => {
      a = (a + 0x6D2B79F5) >>> 0;
      let t = Math.imul(a ^ (a >>> 15), 1 | a);
      t ^= t + Math.imul(t ^ (t >>> 7), 61 | t);
      return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
    };
    const x = [], y = [];
    for (let i = 0; i < n; i++) { x.push(100 * azar()); y.push(100 * azar()); }
    return { x, y, dim: n, semilla, archivo: "" };
  }

  return { datos, ciudades };
})();
