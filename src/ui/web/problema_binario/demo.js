// Datos de ejemplo para disenar en el navegador sin MATLAB. En la app llegan de
// problemas_de_tipo.m; aqui solo se imita su forma.

const DEMO = (() => {
  const DIM_MAX = 100;

  const problemas = [
    { id: "mochila", nombre: "Mochila", formula: "max Σ vⱼ·xⱼ  con  Σ wⱼ·xⱼ ≤ capacidad",
      descripcion: "Elige qué objetos meter para lograr el mayor valor sin pasar la capacidad.",
      sentido: "max", dim_min: 2, dim_max: DIM_MAX, dim_defecto: 6, f_optimo: null, disponible: true,
      datos: { pesos: [12, 7, 11, 8, 9, 6], valores: [4, 2, 6, 5, 6, 3], capacidad: 30 } },
    { id: "onemax", nombre: "OneMax", formula: "max Σ xⱼ",
      descripcion: "Encender todos los bits: f(x) cuenta cuántos unos tiene x.",
      sentido: "max", dim_min: 2, dim_max: DIM_MAX, dim_defecto: 20,
      f_optimo: Array.from({ length: DIM_MAX }, (_, i) => i + 1), disponible: true, datos: [] }
  ];

  const datos = {
    tipo: { id: "binario", nombre: "Binario", notacion: "x ∈ {0,1}ⁿ" },
    problemas,
    seleccion: {},
    n_guardadas: 0
  };

  return { datos };
})();
