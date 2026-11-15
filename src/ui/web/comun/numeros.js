// Lectura y formato de numeros que escribe el usuario. Lo comparten las pantallas.

// Acepta el signo menos tipografico y la coma decimal.
function leer_numero(texto) {
  const t = String(texto ?? "").trim().replace(/−/g, "-").replace(",", ".");
  return t === "" ? NaN : Number(t);
}

function formato_numero(v) {
  if (v === null || v === undefined || Number.isNaN(v)) return "";
  const abs = Math.abs(v);
  const texto = abs !== 0 && (abs >= 1e5 || abs < 1e-3) ? v.toExponential(1) : String(Number(v.toPrecision(5)));
  return texto.replace(/-/g, "−");
}
