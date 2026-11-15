// Desplegable propio encima de un <select> oculto.
// La lista nativa del navegador de uihtml no acepta estilos; esta si.
// El <select> sigue siendo la fuente de verdad: el resto del codigo lee .value,
// escucha "change" y pone .disabled como siempre.
//
// Uso: DESPLEGABLE.mejorar(document.querySelector(".selector"))
// El contenedor debe tener dentro un <select>. La clave de cada opcion es su value.

const DESPLEGABLE = (() => {
  let abierto = null;

  function mejorar(caja) {
    const select = caja.querySelector("select");
    const boton = document.createElement("button");
    boton.type = "button";
    boton.className = "desplegable-boton";
    boton.setAttribute("aria-haspopup", "listbox");
    boton.setAttribute("aria-expanded", "false");
    const etiqueta = document.querySelector(`label[for="${select.id}"]`);
    if (etiqueta) {
      etiqueta.id = etiqueta.id || `${select.id}-etiqueta`;
      boton.setAttribute("aria-labelledby", etiqueta.id);
      etiqueta.addEventListener("click", (e) => { e.preventDefault(); boton.focus(); });
    }
    caja.appendChild(boton);
    select.tabIndex = -1;
    select.setAttribute("aria-hidden", "true");

    const lista = document.createElement("ul");
    lista.className = "desplegable-lista";
    lista.setAttribute("role", "listbox");
    lista.tabIndex = -1;

    const estado = { caja, select, boton, lista, activo: -1, buscado: "", reloj: 0 };

    const copiar_bloqueo = () => {
      boton.disabled = select.disabled;
      caja.classList.toggle("apagado", select.disabled);
      if (select.disabled && abierto === estado) cerrar();
    };
    new MutationObserver(copiar_bloqueo).observe(select, { attributes: true, attributeFilter: ["disabled"] });
    copiar_bloqueo();

    boton.addEventListener("click", () => (abierto === estado ? cerrar() : abrir(estado)));
    boton.addEventListener("keydown", (e) => {
      if (["ArrowDown", "ArrowUp", "Enter", " "].includes(e.key) && abierto !== estado) {
        e.preventDefault();
        abrir(estado);
      } else if (abierto === estado) {
        teclas(estado, e);
      }
    });
    lista.addEventListener("keydown", (e) => teclas(estado, e));
    lista.addEventListener("pointermove", (e) => {
      const li = e.target.closest("li");
      if (li) marcar(estado, Number(li.dataset.i), false);
    });
    lista.addEventListener("click", (e) => {
      const li = e.target.closest("li");
      if (li) elegir(estado, Number(li.dataset.i));
    });
  }

  function abrir(estado) {
    if (abierto) cerrar();
    const { select, lista, boton, caja } = estado;
    if (select.disabled || !select.options.length) return;

    lista.innerHTML = "";
    Array.from(select.options).forEach((o, i) => {
      const li = document.createElement("li");
      li.setAttribute("role", "option");
      li.dataset.i = i;
      li.setAttribute("aria-selected", String(o.selected));
      li.innerHTML = '<span class="desplegable-marca" aria-hidden="true"></span>'
        + '<span class="desplegable-nombre"></span><span class="desplegable-clave"></span>';
      li.children[1].textContent = o.textContent;
      li.children[2].textContent = o.value;
      lista.appendChild(li);
    });

    document.body.appendChild(lista);
    colocar(estado);
    abierto = estado;
    caja.classList.add("abierto");
    boton.setAttribute("aria-expanded", "true");
    marcar(estado, Math.max(select.selectedIndex, 0), true);
    lista.focus({ preventScroll: true });
    requestAnimationFrame(() => lista.classList.add("visible"));
  }

  function colocar({ caja, lista }) {
    const r = caja.getBoundingClientRect();
    const margen = 12;
    const abajo = window.innerHeight - r.bottom - margen;
    const arriba = r.top - margen;
    const hacia_arriba = abajo < 220 && arriba > abajo;
    lista.style.left = `${r.left}px`;
    lista.style.width = `${r.width}px`;
    lista.style.maxHeight = `${Math.min(320, (hacia_arriba ? arriba : abajo) - 6)}px`;
    lista.style.top = hacia_arriba ? "" : `${r.bottom + 6}px`;
    lista.style.bottom = hacia_arriba ? `${window.innerHeight - r.top + 6}px` : "";
    lista.classList.toggle("arriba", hacia_arriba);
  }

  function cerrar(devolver_foco = false) {
    if (!abierto) return;
    const { lista, boton, caja } = abierto;
    abierto = null;
    lista.classList.remove("visible");
    lista.remove();
    caja.classList.remove("abierto");
    boton.setAttribute("aria-expanded", "false");
    if (devolver_foco) boton.focus();
  }

  function marcar(estado, i, desplazar) {
    const items = estado.lista.children;
    if (!items.length) return;
    i = Math.min(Math.max(i, 0), items.length - 1);
    if (items[estado.activo]) items[estado.activo].classList.remove("activo");
    items[i].classList.add("activo");
    estado.activo = i;
    if (desplazar) items[i].scrollIntoView({ block: "nearest" });
  }

  function elegir(estado, i) {
    const { select } = estado;
    cerrar(true);
    if (select.selectedIndex === i) return;
    select.selectedIndex = i;
    select.dispatchEvent(new Event("change", { bubbles: true }));
  }

  function teclas(estado, e) {
    const n = estado.lista.children.length;
    const paso = { ArrowDown: 1, ArrowUp: -1, PageDown: 8, PageUp: -8 }[e.key];
    if (paso) {
      marcar(estado, estado.activo + paso, true);
    } else if (e.key === "Home" || e.key === "End") {
      marcar(estado, e.key === "Home" ? 0 : n - 1, true);
    } else if (e.key === "Enter" || (e.key === " " && !estado.buscado)) {
      elegir(estado, estado.activo);
    } else if (e.key === "Escape" || e.key === "Tab") {
      cerrar(e.key === "Escape");
      if (e.key === "Tab") return;
    } else if (e.key.length === 1 && !e.ctrlKey && !e.metaKey && !e.altKey) {
      buscar(estado, e.key);
    } else {
      return;
    }
    e.preventDefault();
  }

  // Escribir salta a la primera opcion que empieza con lo tecleado.
  function buscar(estado, letra) {
    clearTimeout(estado.reloj);
    estado.buscado += letra.toLowerCase();
    estado.reloj = setTimeout(() => { estado.buscado = ""; }, 700);
    const opciones = Array.from(estado.select.options);
    const i = opciones.findIndex((o) => o.textContent.toLowerCase().startsWith(estado.buscado));
    if (i >= 0) marcar(estado, i, true);
  }

  document.addEventListener("pointerdown", (e) => {
    if (abierto && !abierto.lista.contains(e.target) && !abierto.caja.contains(e.target)) cerrar();
  });
  window.addEventListener("resize", () => cerrar());
  document.addEventListener("scroll", (e) => {
    if (abierto && !abierto.lista.contains(e.target)) cerrar();
  }, true);

  return { mejorar, cerrar };
})();
