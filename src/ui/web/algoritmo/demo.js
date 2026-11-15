// Datos de ejemplo para disenar en el navegador sin MATLAB. En la app llegan de
// algoritmos_de_tipo.m (con parametros_para_ui.m); aqui solo se imita su forma.

const DEMO = (() => {
  const numero = (nombre, etiqueta, ayuda, tipo, valor, min, max, solo_si = null) =>
    ({ nombre, etiqueta, ayuda, tipo, valor, min, max, opciones: [], solo_si });
  const opcion = (nombre, etiqueta, ayuda, valor, opciones, solo_si = null) =>
    ({ nombre, etiqueta, ayuda, tipo: "opcion", valor, min: null, max: null,
       opciones: opciones.map(([v, texto]) => ({ valor: v, texto })), solo_si });

  const comunes = [
    numero("n_iteraciones", "Iteraciones", "Cuántas veces se actualiza la población.", "entero", 200, 1, 10000),
    numero("semilla", "Semilla", "Fija los números aleatorios.", "entero", 42, 0, 2 ** 31),
    numero("paciencia", "Paciencia", "Se detiene si no mejora en tantas iteraciones. 0 = nunca.", "entero", 0, 0, 10000)
  ];

  const ga = [
    numero("tam_poblacion", "Tamaño de población", "Individuos en cada generación.", "entero", 60, 4, 1000),
    numero("tasa_cruza", "Tasa de cruza", "Probabilidad de cruzar cada pareja.", "real", 0.9, 0, 1),
    opcion("seleccion", "Selección", "Cómo se eligen los padres.", "torneo", [["torneo", "Torneo"], ["ruleta", "Ruleta"]]),
    numero("k_torneo", "Tamaño del torneo (k)", "Individuos que compiten en cada torneo.", "entero", 3, 2, 20,
      { nombre: "seleccion", valor: "torneo" }),
    numero("n_elite", "Élite", "Mejores que pasan intactos. 0 = sin élite.", "entero", 2, 0, 100),
    opcion("tipo_cruza", "Cruza", "Cómo se combinan dos padres.", "blx", [["blx", "BLX-α"], ["aritmetica", "Aritmética"]]),
    numero("alpha_blx", "Alfa de BLX (α)", "Cuánto se amplía el intervalo de los padres.", "real", 0.3, 0, 1,
      { nombre: "tipo_cruza", valor: "blx" }),
    numero("tasa_mutacion", "Tasa de mutación", "Probabilidad de mutar en cada hijo.", "real", 0.2, 0, 1),
    numero("sigma_ini", "Sigma inicial (σ₀)", "Paso de la mutación al inicio, fracción del rango.", "real", 0.1, 0, 1),
    numero("sigma_fin", "Sigma final (σ₁)", "Paso de la mutación en la última generación.", "real", 0.005, 0, 1),
    ...comunes
  ];

  const pso = [
    numero("n_particulas", "Número de partículas", "Tamaño del enjambre.", "entero", 30, 2, 1000),
    numero("w", "Inercia (w)", "Cuánto conserva cada partícula su velocidad.", "real", 0.7, 0, 1.5),
    numero("c1", "Coeficiente cognitivo (c₁)", "Atracción a su propio mejor.", "real", 1.5, 0, 4),
    numero("c2", "Coeficiente social (c₂)", "Atracción al mejor del grupo.", "real", 1.5, 0, 4),
    numero("fraccion_vmax", "Velocidad máxima", "Fracción del rango de búsqueda.", "real", 0.2, 0.01, 1),
    ...comunes
  ];

  const de = [
    numero("tam_poblacion", "Tamaño de población", "Individuos en cada generación.", "entero", 50, 4, 1000),
    numero("factor_f", "Factor de mutación (F)", "Escala la diferencia entre vectores.", "real", 0.5, 0, 2),
    numero("tasa_cr", "Tasa de cruza (CR)", "Probabilidad de tomar cada gen del mutante.", "real", 0.9, 0, 1),
    opcion("estrategia", "Estrategia", "De dónde parte el vector mutante.", "rand/1/bin",
      [["rand/1/bin", "rand/1/bin"], ["best/1/bin", "best/1/bin"]]),
    ...comunes
  ];

  const algoritmo = (id, nombre, siglas, descripcion, parametros, nota = "") =>
    ({ id, nombre, siglas, descripcion, disponible: !nota, nota, parametros: nota ? [] : parametros });

  const datos = {
    problema: { nombre: "Rastrigin", representacion: "continuo", dim: 2 },
    algoritmos: [
      algoritmo("ga", "Algoritmo genético", "GA",
        "Una población evoluciona por selección, cruza y mutación: los mejores individuos pasan sus genes a la siguiente generación.", ga),
      algoritmo("aco", "Colonia de hormigas", "ACO",
        "Cada hormiga arma una ruta paso a paso y deja feromona en los caminos buenos. La feromona se evapora con el tiempo.", [], "solo para rutas"),
      algoritmo("pso", "Enjambre de partículas", "PSO",
        "Cada partícula se mueve combinando su inercia, la atracción hacia su mejor punto y la atracción hacia el mejor punto de todo el enjambre.", pso),
      algoritmo("ais", "Sistema inmune", "AIS",
        "Los mejores anticuerpos se clonan y sus clones mutan; los peores se reemplazan por anticuerpos nuevos.", [], "en desarrollo"),
      algoritmo("de", "Evolución diferencial", "DE",
        "Cada vector prueba moverse con la diferencia escalada entre otros dos vectores y se queda con el cambio solo si mejora.", de)
    ],
    seleccion: { id: "pso" },
    n_guardadas: 0
  };

  // Horario (algoritmo.html?horario): binario, con los textos de algoritmos_para_horario.m.
  const semilla_horario = numero("semilla", "Semilla", "La misma semilla da el mismo horario.", "entero", 42, 0, 2 ** 31);
  const paciencia = comunes[2];
  const ga_horario = [
    numero("tam_poblacion", "Población", "Horarios candidatos en cada generación.", "entero", 60, 4, 1000),
    numero("tasa_cruza", "Tasa de cruza", "Qué tan seguido se mezclan dos horarios.", "real", 0.9, 0, 1),
    opcion("seleccion", "Selección", "Cómo se eligen los padres.", "torneo", [["torneo", "Torneo"], ["ruleta", "Ruleta"]]),
    numero("k_torneo", "Tamaño del torneo (k)", "Horarios que compiten para ser padres.", "entero", 3, 2, 20,
      { nombre: "seleccion", valor: "torneo" }),
    numero("n_elite", "Élite", "Mejores horarios que pasan intactos. 0 = sin élite.", "entero", 2, 0, 100),
    opcion("tipo_cruza", "Cruza", "Cómo se combinan dos horarios.", "un_punto", [["un_punto", "Un punto"], ["uniforme", "Uniforme"]]),
    numero("tasa_mutacion", "Tasa de mutación", "Por bit: tomar o soltar una sección al azar.", "real", 0.02, 0, 1),
    numero("n_iteraciones", "Generaciones", "Cuántas veces se mejora la población.", "entero", 200, 1, 10000),
    semilla_horario, paciencia
  ];
  const pso_horario = [
    numero("n_particulas", "Número de partículas", "Horarios candidatos que se mueven juntos.", "entero", 30, 2, 1000),
    ...pso.slice(1, 4),
    numero("vmax", "Velocidad máxima", "Con 4, ninguna sección queda fija del todo.", "real", 4, 0.5, 10),
    numero("n_iteraciones", "Iteraciones", "Cuántas veces se mueve el enjambre.", "entero", 200, 1, 10000),
    semilla_horario, paciencia
  ];
  const de_horario = [
    numero("tam_poblacion", "Tamaño de población", "Horarios candidatos en cada generación.", "entero", 50, 4, 1000),
    de[1],
    numero("tasa_cr", "Tasa de cruza (CR)", "Probabilidad de tomar cada sección del mutante.", "real", 0.9, 0, 1),
    de[3],
    numero("n_iteraciones", "Iteraciones", "Cuántas veces se mejora la población.", "entero", 200, 1, 10000),
    semilla_horario, paciencia
  ];
  const [ga_d, aco_d, pso_d, ais_d, de_d] = datos.algoritmos;
  const horario = {
    problema: { nombre: "Horario de materias", representacion: "binario", dim: 26, sentido: "min" },
    algoritmos: [
      { ...ga_d, nota: "cruza y mutación de bits", parametros: ga_horario },
      { ...pso_d, nota: "binario con sigmoide", parametros: pso_horario },
      { ...de_d, nota: "binario por umbral", parametros: de_horario },
      aco_d, ais_d
    ],
    horario: { materias: 6 },
    seleccion: { id: "ga" },
    n_guardadas: 0
  };

  return { datos, horario };
})();
