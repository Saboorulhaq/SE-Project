/* Small helpers shared by every module file. */

function formatDate(value) {
  if (!value) return "-";
  const d = new Date(value);
  if (Number.isNaN(d.getTime())) return "-";
  return d.toLocaleDateString(undefined, { year: "numeric", month: "short", day: "numeric" });
}

function formatDateTime(value) {
  if (!value) return "-";
  const d = new Date(value);
  if (Number.isNaN(d.getTime())) return "-";
  return d.toLocaleString(undefined, { year: "numeric", month: "short", day: "numeric", hour: "2-digit", minute: "2-digit" });
}

function formatCurrency(value) {
  if (value === null || value === undefined || value === "") return "-";
  return "$" + Number(value).toFixed(2);
}

function escapeHtml(str) {
  if (str === null || str === undefined) return "";
  return String(str)
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;");
}

function badge(text, tone) {
  const toneClass = { success: "badge-success", warning: "badge-warning", danger: "badge-danger" }[tone] || "badge-neutral";
  return `<span class="badge ${toneClass}">${escapeHtml(text)}</span>`;
}

/* Minimal modal controller: openModal(html) / closeModal() */

function openModal(innerHtml) {
  closeModal();
  const backdrop = document.createElement("div");
  backdrop.className = "modal-backdrop";
  backdrop.id = "active-modal";
  backdrop.innerHTML = `<div class="modal">${innerHtml}</div>`;
  backdrop.addEventListener("click", (e) => {
    if (e.target === backdrop) closeModal();
  });
  document.body.appendChild(backdrop);
  return backdrop;
}

function closeModal() {
  const existing = document.getElementById("active-modal");
  if (existing) existing.remove();
}

function setButtonLoading(button, loading, loadingLabel = "Saving") {
  if (!button) return;
  if (loading) {
    button.dataset.originalLabel = button.innerHTML;
    button.disabled = true;
    button.innerHTML = `<span class="spinner"></span> ${loadingLabel}`;
  } else {
    button.disabled = false;
    if (button.dataset.originalLabel) button.innerHTML = button.dataset.originalLabel;
  }
}
