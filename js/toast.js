/* Lightweight toast notifications. No animation libraries. */

function ensureToastStack() {
  let stack = document.querySelector(".toast-stack");
  if (!stack) {
    stack = document.createElement("div");
    stack.className = "toast-stack";
    document.body.appendChild(stack);
  }
  return stack;
}

function showToast(message, type = "default") {
  const stack = ensureToastStack();
  const toast = document.createElement("div");
  toast.className = "toast" + (type === "error" ? " toast-error" : type === "success" ? " toast-success" : "");
  toast.textContent = message;
  stack.appendChild(toast);
  setTimeout(() => toast.remove(), 4200);
}

function describeError(error) {
  if (!error) return "Something went wrong. Please try again.";
  return error.message || "Something went wrong. Please try again.";
}
