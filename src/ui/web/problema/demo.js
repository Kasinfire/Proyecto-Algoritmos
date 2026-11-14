// Datos de ejemplo para disenar en el navegador sin MATLAB. En la app llegan de
// problemas_de_tipo.m; aqui solo se imita su forma.

const DEMO = (() => {
  const DIM_MAX = 100;

  // dims: [dim_min, dim_max, dim_defecto]. optimo: f en funcion de n (null si no se conoce).
  const problema = (id, nombre, formula, forma, descripcion, lb, ub, sentido, dims, optimo, x_optimo) => {
    const [dim_min, dim_max, dim_defecto] = dims;
    const f_optimo = Array.from({ length: dim_max }, (_, i) => (i + 1 >= dim_min ? optimo(i + 1) : null));
    return { id, nombre, formula, forma, descripcion, lb, ub, sentido,
             dim_min, dim_max, dim_defecto, f_optimo, x_optimo, disponible: true };
  };
  const SIMPLE = [1, DIM_MAX, 1];
  const ND = [2, DIM_MAX, 2];
  const SOLO_2D = [2, 2, 2];
  const cero = () => 0;

  const continuos = [
    problema("parabolica", "Parabólica", "f(x) = 4 − Σ xᵢ²", "unimodal",
      "Una colina con un solo pico en x = 0. La más fácil: sirve para empezar.", -3, 3, "max", SIMPLE, () => 4, 0),
    problema("seno", "Seno oscilante", "f(x) = Σ (sin 10πxᵢ + 1)", "multimodal",
      "Muchas crestas seguidas. Todas llegan a la misma altura, así que hay varios máximos.", 0, 1, "max", SIMPLE, (n) => 2 * n, 0.05),
    problema("lineal", "Lineal", "f(x) = Σ (5 − 2xᵢ)", "monótona",
      "Un plano inclinado. El máximo está en una orilla del rango, no adentro.", 0, 3, "max", SIMPLE, (n) => 5 * n, 0),
    problema("exponencial", "Exponencial", "f(x) = e^(−Σ xᵢ²)", "unimodal",
      "Una campana con un solo pico en el origen. Lejos del centro casi no tiene pendiente.", -3, 3, "max", SIMPLE, () => 1, 0),
    problema("coseno", "Coseno desplazado", "f(x) = Σ (cos 5xᵢ + 2)", "multimodal",
      "Varias ondas iguales dentro del rango. El algoritmo puede detenerse en cualquiera.", -3, 3, "max", SIMPLE, (n) => 3 * n, 0),
    problema("esfera", "Esfera", "f(x) = Σ xᵢ²", "unimodal",
      "Un solo valle liso y simétrico. Sirve para comprobar que el algoritmo converge.", -100, 100, "min", ND, cero, [0, 0]),
    problema("rastrigin", "Rastrigin", "f(x) = 10n + Σ (xᵢ² − 10 cos 2πxᵢ)", "multimodal",
      "Una cuadrícula de muchos mínimos locales. El algoritmo puede quedarse atrapado en un hoyo que no es el mejor.", -5.12, 5.12, "min", ND, cero, [0, 0]),
    problema("himmelblau", "Himmelblau", "f(x, y) = (x² + y − 11)² + (x + y² − 7)²", "multimodal",
      "Cuatro mínimos globales igual de buenos. Sirve para ver cuál encuentra cada algoritmo.", -6, 6, "min", SOLO_2D, cero, [3, 2]),
    problema("ackley", "Ackley", "f(x) = −20 e^(−0.2 √(Σ xᵢ² / n)) − e^(Σ cos 2πxᵢ / n) + 20 + e", "multimodal",
      "Casi plana por fuera, con un hoyo profundo al centro rodeado de pequeñas ondas.", -5, 5, "min", ND, cero, [0, 0]),
    problema("schwefel", "Schwefel", "f(x) = 418.9829n − Σ xᵢ sin √|xᵢ|", "multimodal",
      "Engañosa: el mejor punto está lejos del segundo mejor, cerca de la orilla del rango.", -500, 500, "min", ND, cero, [420.9687, 420.9687]),
    problema("eggholder", "Eggholder", "f(x, y) = −(y + 47) sin √|x/2 + y + 47| − x sin √|x − (y + 47)|", "multimodal",
      "Muy caótica, con valles y picos profundos. El mínimo está pegado a la orilla.", -512, 512, "min", SOLO_2D, () => -959.6407, [512, 404.2319]),
    problema("griewank", "Griewank", "f(x) = Σ xᵢ² / 4000 − Π cos(xᵢ / √i) + 1", "multimodal",
      "Muchos mínimos locales muy parecidos entre sí, montados sobre una curva suave.", -600, 600, "min", ND, cero, [0, 0]),
    problema("rosenbrock", "Rosenbrock", "f(x) = Σ 100(xᵢ₊₁ − xᵢ²)² + (xᵢ − 1)²", "unimodal",
      "Un valle largo y curvo. Llegar al valle es fácil; recorrerlo hasta el mínimo, no.", -2, 2, "min", ND, cero, [1, 1]),
    problema("michalewicz", "Michalewicz", "f(x) = −Σ sin(xᵢ) sin(i xᵢ² / π)^20", "multimodal",
      "Mesetas planas con zanjas angostas. Casi no hay pendiente que lleve al mínimo.", 0, Math.PI, "min", ND,
      (n) => (n === 2 ? -1.8013 : null), [2.2029, 1.5708]),
    problema("levy", "Lévy", "f(x) = sin²(πw₁) + Σ (wᵢ − 1)²(1 + 10 sin²(πwᵢ + 1)) + (wₙ − 1)²(1 + sin²(2πwₙ))", "multimodal",
      "Una superficie irregular con varios valles. Usa wᵢ = 1 + (xᵢ − 1)/4.", -10, 10, "min", ND, cero, [1, 1]),
    problema("zakharov", "Zakharov", "f(x) = Σ xᵢ² + (Σ 0.5xᵢ)² + (Σ 0.5xᵢ)⁴", "unimodal",
      "Un solo valle, sin mínimos locales, que se alarga al subir la dimensión.", -5, 10, "min", ND, cero, [0, 0])
  ];

  const datos = {
    tipo: { id: "continuo", nombre: "Continuo", notacion: "x ∈ ℝⁿ" },
    problemas: continuos,
    seleccion: { id: "rastrigin" },
    n_guardadas: 0
  };

  return { datos };
})();
