// Pantalla 2 del problema real: tu horario del semestre, en tres subpasos
// (1 Oferta, 2 Materias, 3 Preferencias). Este archivo lleva el riel, los subpasos, la
// barra de abajo y el puente; cada subpaso dibuja lo suyo (oferta.js, materias.js,
// preferencias.js).
//
// Eventos que llegan de MATLAB:
//   "datos"     { ciclos, centros, carreras: [{id, nombre}], defecto: {ciclo, centro, carrera,
//                 solo_cupo}, ejemplo, seleccion, n_guardadas }
//   "progreso"  { pagina, secciones }   (tras cada pagina leida de SIIAU)
//   "oferta"    { secciones: [{nrc, clave, materia, seccion, creditos, cupo, disponibles,
//                 sesiones: [{inicio, fin, dias, edificio, aula}], profesor}], titulo, detalle, paginas }
//   "aviso"     { texto }   (no se pudo consultar, leer el archivo o armar el problema)
//   "cancelado"            (se cerro el dialogo de abrir sin elegir archivo)
// Eventos que se mandan a MATLAB:
//   "lista", "consultar" { ciclo, centro, carrera, solo_cupo }, "abrir_guardada", "usar_ejemplo",
//   "materias" { claves }   (cada vez que cambia la lista de materias elegidas),
//   "preferencias" { entrada, salida, dias_libres, peso_muertas, max_materias_dia,
//                    max_horas_seguidas, solo_cupo }   (cada vez que cambia una),
//   "siguiente" (al terminar Preferencias), "regresar", "ir_a_paso" { paso }, "comparar", "ayuda"

const SUBPASOS = {
  oferta: { subtitulo: "Primero, la oferta académica. La traemos de la consulta pública de SIIAU." },
  materias: { subtitulo: "Busca las materias que te tocan este ciclo." },
  preferencias: { subtitulo: "Dinos cómo lo quieres. Lo rayado es lo que vas a evitar." }
};
const ORDEN = Object.keys(SUBPASOS);

const estado = {
  con_matlab: false, n_guardadas: 0, cargando: false, cuenta: null, paginas: 0,
  subpaso: "oferta", aviso: ""
};

const el = Object.fromEntries(["resumen", "regresar", "siguiente", "subtitulo", "subpasos"]
  .map((id) => [id, document.getElementById(id)]));

const pestana = (nombre) => el.subpasos.querySelector(`[data-subpaso="${nombre}"]`);
const panel = (nombre) => document.getElementById(`panel-${nombre}`);

// ---------- Subpasos ----------

function ir_a(nombre) {
  if (!panel(nombre)) return;
  estado.subpaso = nombre;
  ORDEN.forEach((n) => {
    if (panel(n)) panel(n).hidden = n !== nombre;
    pestana(n).setAttribute("aria-selected", String(n === nombre));
  });
  el.subtitulo.textContent = SUBPASOS[nombre].subtitulo;
  estado.aviso = "";
  actualizar_barra();
  if (nombre === "materias") MATERIAS.enfocar_busqueda();
  if (nombre === "preferencias") PREFERENCIAS.poner(MATERIAS.elegidas(), MATERIAS.rango());
}

// Un subpaso se puede abrir si el anterior ya esta completo.
function puede_abrir(nombre) {
  if (!panel(nombre)) return false;
  if (nombre === "oferta") return true;
  if (nombre === "materias") return oferta_lista();
  return oferta_lista() && MATERIAS.lista();
}

function oferta_lista() { return Boolean(estado.cuenta && estado.cuenta.con_horario > 0); }

function actualizar_barra() {
  ORDEN.forEach((n, i) => {
    const b = pestana(n);
    b.disabled = estado.cargando || !puede_abrir(n);
    const siguiente = ORDEN[i + 1];
    b.classList.toggle("hecho", n !== estado.subpaso && Boolean(siguiente) && puede_abrir(siguiente));
  });
  const siguiente = ORDEN[ORDEN.indexOf(estado.subpaso) + 1];
  const ultimo = !siguiente && puede_abrir(estado.subpaso);
  el.siguiente.disabled = estado.cargando || !(ultimo || (siguiente && puede_abrir(siguiente)));
  el.regresar.disabled = estado.cargando;
  const aviso = estado.aviso || (estado.subpaso === "preferencias" ? PREFERENCIAS.aviso() : "");
  poner_resumen(aviso || resumen_del_subpaso(), Boolean(aviso));
}

function resumen_del_subpaso() {
  if (estado.subpaso === "materias") return MATERIAS.resumen();
  if (estado.subpaso === "preferencias") return PREFERENCIAS.resumen();
  const n = estado.cuenta;
  if (!n) return "Trae la oferta de SIIAU para empezar.";
  return `${n.con_horario} ${n.con_horario === 1 ? "sección con horario lista" : "secciones con horario listas"}.`;
}

function poner_resumen(texto, es_aviso = false) {
  el.resumen.textContent = texto;
  el.resumen.classList.toggle("aviso", es_aviso);
}

el.subpasos.addEventListener("click", (e) => {
  const b = e.target.closest("[data-subpaso]");
  if (b && !b.disabled) ir_a(b.dataset.subpaso);
});

el.siguiente.addEventListener("click", () => {
  const siguiente = ORDEN[ORDEN.indexOf(estado.subpaso) + 1];
  if (siguiente) ir_a(siguiente);
  else puente.enviar("siguiente");
});

el.regresar.addEventListener("click", () => {
  const anterior = ORDEN[ORDEN.indexOf(estado.subpaso) - 1];
  if (anterior) ir_a(anterior);
  else puente.enviar("regresar");
});

// ---------- Subpaso Oferta ----------

function empezar_carga(texto) {
  estado.cargando = true;
  estado.aviso = "";
  OFERTA.ocupado(true);
  actualizar_barra();
  poner_resumen(texto);
}

function terminar_carga() {
  estado.cargando = false;
  OFERTA.ocupado(false);
}

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

// ---------- Subpaso Materias ----------

MATERIAS.al_cambiar(({ claves }) => {
  if (estado.con_matlab) puente.enviar("materias", { claves });
  actualizar_barra();
});

// ---------- Subpaso Preferencias ----------

PREFERENCIAS.al_cambiar((preferencias) => {
  if (estado.con_matlab) puente.enviar("preferencias", preferencias);
  estado.aviso = "";
  actualizar_barra();
});

// ---------- Puente ----------

puente.escuchar("datos", (datos) => {
  estado.n_guardadas = Number(datos.n_guardadas) || 0;
  dibujar_riel(document.getElementById("riel"), 1, estado.n_guardadas,
    (paso) => puente.enviar("ir_a_paso", { paso }));
  OFERTA.poner_opciones(datos);
  actualizar_barra();
});

puente.escuchar("progreso", (datos) => {
  OFERTA.avance_leyendo(Number(datos.pagina));
  poner_resumen(`Consultando SIIAU… ${datos.secciones} secciones hasta ahora.`);
});

puente.escuchar("oferta", (oferta) => {
  terminar_carga();
  estado.cuenta = OFERTA.mostrar(oferta);
  estado.paginas = Number(oferta.paginas) || 0;
  MATERIAS.poner_oferta(como_lista(oferta.secciones));
  actualizar_barra();
});

puente.escuchar("aviso", (datos) => {
  terminar_carga();
  OFERTA.avance_listo(estado.paginas);
  estado.aviso = datos.texto;
  actualizar_barra();
});

puente.escuchar("cancelado", () => {
  terminar_carga();
  actualizar_barra();
});

puente.al_iniciar((con_matlab) => {
  estado.con_matlab = con_matlab;
  if (con_matlab) {
    puente.enviar("lista");
  } else {
    puente.recibir("datos", DEMO.datos);
  }
});
