// Subpaso 1 del horario: consultar la oferta de SIIAU y mostrar lo que llego.
// No guarda la oferta para el problema: MATLAB se queda con ella (pantalla_horario.m);
// aqui solo se dibuja y se cuentan secciones para el resumen.

const OFERTA = (() => {
  const el = Object.fromEntries([
    "ciclo", "ciclo-texto", "ciclo-clave", "centro", "centro-texto", "centro-clave",
    "carrera", "carrera-texto", "carrera-clave", "solo-cupo", "consultar",
    "abrir-guardada", "usar-ejemplo", "ruta-ejemplo",
    "detalle", "titulo", "n-secciones", "n-materias", "n-sin-lugares", "n-sin-horario",
    "aviso-oferta", "avance", "avance-relleno", "avance-texto", "filas", "tabla-vacia", "tabla-caja"
  ].map((id) => [id.replace(/-/g, "_"), document.getElementById(id)]));

  const SELECTORES = ["ciclo", "centro", "carrera"];
  const DIAS = "LMIJVS";

  // ---------- Formulario ----------

  function poner_opciones(datos) {
    const listas = { ciclo: datos.ciclos, centro: datos.centros, carrera: datos.carreras };
    SELECTORES.forEach((nombre) => {
      el[nombre].innerHTML = como_lista(listas[nombre])
        .map((o) => `<option value="${esc(o.id)}">${esc(o.nombre)}</option>`).join("");
      el[nombre].value = datos.defecto[nombre];
      mostrar_eleccion(nombre);
    });
    el.solo_cupo.checked = Boolean(datos.defecto.solo_cupo);
    el.ruta_ejemplo.textContent = datos.ejemplo;
  }

  function mostrar_eleccion(nombre) {
    const opcion = el[nombre].selectedOptions[0];
    el[`${nombre}_texto`].textContent = opcion ? opcion.textContent : "";
    el[`${nombre}_clave`].textContent = el[nombre].value;
  }

  function consulta() {
    return {
      ciclo: el.ciclo.value, centro: el.centro.value, carrera: el.carrera.value,
      solo_cupo: el.solo_cupo.checked
    };
  }

  function ocupado(si) {
    [el.consultar, el.abrir_guardada, el.usar_ejemplo, ...SELECTORES.map((n) => el[n])]
      .forEach((b) => { b.disabled = si; });
    el.consultar.textContent = si ? "Consultando…" : "Consultar oferta";
  }

  // ---------- Avance de la lectura ----------

  // SIIAU no dice cuantas paginas son hasta llegar a la ultima, asi que la barra
  // avanza sin llegar al final mientras se lee.
  function avance_leyendo(pagina) {
    el.avance.classList.add("leyendo");
    el.avance.classList.remove("sin-datos");
    el.avance_relleno.style.width = `${(100 * pagina) / (pagina + 1)}%`;
    el.avance_texto.textContent = pagina === 0
      ? "Conectando con SIIAU…"
      : `Leyendo “100 Próximos” hasta que ya no hay más: página ${pagina}`;
  }

  function avance_listo(paginas) {
    el.avance.classList.remove("leyendo");
    el.avance.classList.toggle("sin-datos", paginas === 0);
    el.avance_relleno.style.width = paginas > 0 ? "100%" : "0";
    el.avance_texto.textContent = paginas > 0 ? `Páginas de SIIAU leídas: ${paginas} de ${paginas}` : "";
  }

  // ---------- Resultado ----------

  function contar(secciones) {
    const sin_horario = secciones.filter((s) => como_lista(s.sesiones).length === 0).length;
    return {
      secciones: secciones.length,
      materias: new Set(secciones.map((s) => s.clave)).size,
      sin_lugares: secciones.filter((s) => s.disponibles <= 0).length,
      sin_horario,
      con_horario: secciones.length - sin_horario
    };
  }

  function mostrar(oferta) {
    const secciones = como_lista(oferta.secciones);
    const n = contar(secciones);
    el.titulo.textContent = oferta.titulo;
    el.detalle.textContent = oferta.detalle;
    el.n_secciones.textContent = n.secciones;
    el.n_materias.textContent = n.materias;
    el.n_sin_lugares.textContent = n.sin_lugares;
    el.n_sin_horario.textContent = n.sin_horario;
    el.aviso_oferta.textContent = n.sin_horario === 0 ? ""
      : n.sin_horario === 1
        ? "1 sección no trae horario en SIIAU (virtual o por asignar) y no entra al horario."
        : `${n.sin_horario} secciones no traen horario en SIIAU (virtuales o por asignar) y no entran al horario.`;
    avance_listo(Number(oferta.paginas) || 0);
    dibujar_tabla(secciones);
    return n;
  }

  // Un centro completo pasa de 5000 secciones: las filas se agregan por tandas al bajar,
  // para no armar miles de filas que nadie ve.
  const TANDA = 120;
  const tabla = { secciones: [], dibujadas: 0 };

  function dibujar_tabla(secciones) {
    tabla.secciones = secciones;
    tabla.dibujadas = 0;
    el.filas.innerHTML = "";
    el.tabla_vacia.hidden = secciones.length > 0;
    el.tabla_caja.scrollTop = 0;
    agregar_tanda();
  }

  function agregar_tanda() {
    const siguientes = tabla.secciones.slice(tabla.dibujadas, tabla.dibujadas + TANDA);
    el.filas.insertAdjacentHTML("beforeend", siguientes.map(fila).join(""));
    tabla.dibujadas += siguientes.length;
  }

  el.tabla_caja.addEventListener("scroll", () => {
    const caja = el.tabla_caja;
    const cerca_del_final = caja.scrollTop + caja.clientHeight > caja.scrollHeight - 400;
    if (cerca_del_final && tabla.dibujadas < tabla.secciones.length) agregar_tanda();
  });

  function fila(s) {
    const sesiones = como_lista(s.sesiones);
    const columna = (texto) => sesiones.length
      ? sesiones.map((x) => `<span class="sesion">${texto(x)}</span>`).join("")
      : "–";
    const vacio = sesiones.length ? "" : " vacio";
    return `<tr>
      <td class="mono">${esc(s.nrc)}</td>
      <td class="mono">${esc(s.clave)}</td>
      <td class="materia">${esc(s.materia)}</td>
      <td class="mono">${esc(s.seccion)}</td>
      <td>${s.creditos}</td>
      <td>${s.cupo}</td>
      <td class="${s.disponibles <= 0 ? "cero" : ""}">${s.disponibles}</td>
      <td class="${vacio}">${columna((x) => `${hhmm(x.inicio)}-${hhmm(x.fin)}`)}</td>
      <td class="${vacio}">${columna((x) => dias(x.dias))}</td>
      <td class="${vacio}">${columna((x) => esc(`${x.edificio} · ${x.aula}`))}</td>
      <td class="profesor${s.profesor ? "" : " vacio"}">${esc(s.profesor || "Por asignar")}</td>
    </tr>`;
  }

  function hhmm(n) { return String(n).padStart(4, "0"); }

  // "L.I..." -> "L . I . . ." como lo escribe SIIAU
  function dias(texto) {
    return Array.from(DIAS, (d, i) => (texto[i] === d ? d : ".")).join(" ");
  }

  function esc(texto) {
    return String(texto ?? "").replace(/[&<>"]/g, (c) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;" })[c]);
  }

  // ---------- Eventos del formulario ----------

  SELECTORES.forEach((nombre) => DESPLEGABLE.mejorar(el[nombre].closest(".selector")));

  function al_pedir({ consultar, abrir_guardada, usar_ejemplo }) {
    SELECTORES.forEach((nombre) => el[nombre].addEventListener("change", () => mostrar_eleccion(nombre)));
    el.consultar.addEventListener("click", () => consultar(consulta()));
    el.abrir_guardada.addEventListener("click", abrir_guardada);
    el.usar_ejemplo.addEventListener("click", usar_ejemplo);
  }

  return { poner_opciones, ocupado, avance_leyendo, avance_listo, mostrar, al_pedir };
})();
