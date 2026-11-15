// Pantalla 2 del problema real: tu horario del semestre, en tres subpasos
// (1 Oferta, 2 Materias, 3 Preferencias). Este archivo lleva el riel, los subpasos, la
// barra de abajo y el puente; cada subpaso dibuja lo suyo (oferta.js).
//
// Eventos que llegan de MATLAB:
//   "datos"     { ciclos, centros, carreras: [{id, nombre}], defecto: {ciclo, centro, carrera,
//                 solo_cupo}, ejemplo, seleccion, n_guardadas }
//   "progreso"  { pagina, secciones }   (tras cada pagina leida de SIIAU)
//   "oferta"    { secciones: [{nrc, clave, materia, seccion, creditos, cupo, disponibles,
//                 sesiones: [{inicio, fin, dias, edificio, aula}], profesor}], titulo, detalle, paginas }
//   "aviso"     { texto }   (no se pudo consultar o leer el archivo)
//   "cancelado"            (se cerro el dialogo de abrir sin elegir archivo)
// Eventos que se mandan a MATLAB:
//   "lista", "consultar" { ciclo, centro, carrera, solo_cupo }, "abrir_guardada", "usar_ejemplo",
//   "regresar", "ir_a_paso" { paso }, "comparar", "ayuda"

const estado = { con_matlab: false, n_guardadas: 0, cargando: false, cuenta: null, paginas: 0 };

const el = Object.fromEntries(["resumen", "regresar", "siguiente"]
  .map((id) => [id, document.getElementById(id)]));

function poner_resumen(texto, es_aviso = false) {
  el.resumen.textContent = texto;
  el.resumen.classList.toggle("aviso", es_aviso);
}

function empezar_carga(texto) {
  estado.cargando = true;
  OFERTA.ocupado(true);
  poner_resumen(texto);
}

function terminar_carga() {
  estado.cargando = false;
  OFERTA.ocupado(false);
}

function resumen_de_oferta() {
  const n = estado.cuenta;
  if (!n) return "Trae la oferta de SIIAU para empezar.";
  return `${n.con_horario} ${n.con_horario === 1 ? "sección con horario lista" : "secciones con horario listas"}.`;
}

// ---------- Acciones del subpaso Oferta ----------

OFERTA.al_pedir({
  consultar(consulta) {
    empezar_carga("Consultando SIIAU…");
    OFERTA.avance_leyendo(0);
    if (estado.con_matlab) puente.enviar("consultar", consulta);
    else simular_consulta();
  },
  abrir_guardada() {
    if (estado.con_matlab) {
      empezar_carga("Elige la página guardada…");
      puente.enviar("abrir_guardada");
    }
  },
  usar_ejemplo() {
    empezar_carga("Leyendo la oferta de ejemplo…");
    if (estado.con_matlab) puente.enviar("usar_ejemplo");
    else puente.recibir("oferta", DEMO.oferta);
  }
});

// En el navegador no hay MATLAB: se imita la lectura pagina por pagina.
function simular_consulta() {
  let pagina = 0;
  const siguiente_pagina = () => {
    pagina += 1;
    puente.recibir("progreso", { pagina, secciones: pagina * 100 });
    if (pagina < 3) setTimeout(siguiente_pagina, 450);
    else setTimeout(() => puente.recibir("oferta", { ...DEMO.oferta, paginas: 3,
      detalle: "3 páginas de SIIAU (100 por página) · demo" }), 450);
  };
  setTimeout(siguiente_pagina, 450);
}

el.regresar.addEventListener("click", () => puente.enviar("regresar"));

// ---------- Puente ----------

puente.escuchar("datos", (datos) => {
  estado.n_guardadas = Number(datos.n_guardadas) || 0;
  dibujar_riel(document.getElementById("riel"), 1, estado.n_guardadas,
    (paso) => puente.enviar("ir_a_paso", { paso }));
  OFERTA.poner_opciones(datos);
  poner_resumen(resumen_de_oferta());
});

puente.escuchar("progreso", (datos) => {
  OFERTA.avance_leyendo(Number(datos.pagina));
  poner_resumen(`Consultando SIIAU… ${datos.secciones} secciones hasta ahora.`);
});

puente.escuchar("oferta", (oferta) => {
  terminar_carga();
  estado.cuenta = OFERTA.mostrar(oferta);
  estado.paginas = Number(oferta.paginas) || 0;
  poner_resumen(resumen_de_oferta());
});

puente.escuchar("aviso", (datos) => {
  terminar_carga();
  OFERTA.avance_listo(estado.paginas);
  poner_resumen(datos.texto, true);
});

puente.escuchar("cancelado", () => {
  terminar_carga();
  poner_resumen(resumen_de_oferta());
});

puente.al_iniciar((con_matlab) => {
  estado.con_matlab = con_matlab;
  if (con_matlab) {
    puente.enviar("lista");
  } else {
    puente.recibir("datos", DEMO.datos);
  }
});
