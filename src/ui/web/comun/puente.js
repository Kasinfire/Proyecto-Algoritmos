// Puente entre el HTML y MATLAB (uihtml, R2023a o mas reciente).
//
// MATLAB llama a setup(componente) al cargar la pagina. Desde aqui:
//   puente.enviar(nombre, datos)   -> MATLAB recibe HTMLEventReceived
//   puente.escuchar(nombre, fn)    <- MATLAB llama sendEventToHTMLSource(h, nombre, datos)
//
// Si la pagina se abre en un navegador (sin MATLAB), se usa modo_demo para poder
// trabajar el diseno: los eventos enviados se imprimen en la consola.

const puente = (() => {
  let componente = null;
  const oyentes = {};
  let al_conectar = null;

  function escuchar(nombre, fn) {
    oyentes[nombre] = fn;
    if (componente) {
      componente.addEventListener(nombre, (evento) => fn(evento.Data));
    }
  }

  function enviar(nombre, datos) {
    if (componente) {
      componente.sendEventToMATLAB(nombre, datos === undefined ? null : datos);
    } else {
      console.log("[sin MATLAB] " + nombre, datos);
    }
  }

  function conectar(c) {
    componente = c;
    Object.entries(oyentes).forEach(([nombre, fn]) =>
      componente.addEventListener(nombre, (evento) => fn(evento.Data)));
    if (al_conectar) al_conectar(true);
  }

  // fn(true) con MATLAB; fn(false) si en 600 ms nadie llamo a setup.
  function al_iniciar(fn) {
    al_conectar = fn;
    setTimeout(() => { if (!componente) fn(false); }, 600);
  }

  // En el navegador, recibir() simula un evento que mandaria MATLAB.
  function recibir(nombre, datos) {
    if (oyentes[nombre]) oyentes[nombre](datos);
  }

  return { escuchar, enviar, conectar, al_iniciar, recibir };
})();

// jsonencode manda un struct 1x1 como objeto y una celda vacia como []; esto
// normaliza cualquier lista que llegue de MATLAB a un arreglo.
function como_lista(valor) {
  if (valor === null || valor === undefined || valor === "") return [];
  return Array.isArray(valor) ? valor : [valor];
}

function setup(componente) {
  puente.conectar(componente);
}
