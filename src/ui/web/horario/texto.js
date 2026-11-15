// Ayudas de texto que comparten los subpasos del horario.

const TEXTO = (() => {
  function esc(texto) {
    return String(texto ?? "").replace(/[&<>"]/g, (c) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;" })[c]);
  }

  // 700 -> "0700"; con dos_puntos, "07:00"
  function hhmm(n, dos_puntos = false) {
    const t = String(n).padStart(4, "0");
    return dos_puntos ? `${t.slice(0, 2)}:${t.slice(2)}` : t;
  }

  // Para buscar sin que importen mayusculas ni acentos.
  function plano(texto) {
    return String(texto ?? "").normalize("NFD").replace(/[̀-ͯ]/g, "").toLowerCase();
  }

  const MENORES = new Set(["a", "al", "con", "de", "del", "e", "el", "en", "la", "las", "lo", "los",
    "o", "para", "por", "u", "y"]);

  // SIIAU escribe todo en mayusculas: "REDES DE COMPUTADORAS" -> "Redes de Computadoras".
  // Los numeros romanos (II, XXI) se quedan como estan.
  function como_titulo(texto) {
    return String(texto ?? "").toLowerCase().split(/\s+/).filter(Boolean).map((p, i) => {
      if (/^[ivx]+$/.test(p) || /\d/.test(p)) return p.toUpperCase();
      if (i > 0 && MENORES.has(p)) return p;
      return p.charAt(0).toUpperCase() + p.slice(1);
    }).join(" ");
  }

  // "URIBE NAVA, SERGIO JAVIER / OTRO, ..." -> "Sergio Uribe"
  function profesor_corto(texto) {
    const primero = String(texto ?? "").split(" / ")[0].trim();
    if (!primero) return "Sin profesor";
    const [apellidos, nombres = ""] = primero.split(",").map((p) => p.trim());
    const nombre = nombres.split(/\s+/)[0] || "";
    return como_titulo(`${nombre} ${apellidos.split(/\s+/)[0]}`.trim());
  }

  function plural(n, uno, varios) {
    return `${n} ${n === 1 ? uno : varios}`;
  }

  return { esc, hhmm, plano, como_titulo, profesor_corto, plural };
})();
