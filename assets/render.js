const PX_PER_MM = 96 / 25.4;
const A4 = { width: 210, height: 297 };

function sizeTallPages() {
  const main = document.querySelector("main");
  const width = main.style.width;
  main.style.width = `calc(${A4.width}mm - 40px)`;
  const rules = [];
  document.querySelectorAll("section").forEach((el, i) => {
    const mm = Math.ceil(el.getBoundingClientRect().height / PX_PER_MM) + 2;
    if (mm <= A4.height) return;
    el.style.page = `tall${i}`;
    rules.push(`@page tall${i} { size: ${A4.width}mm ${mm}mm; margin: 0; }`);
  });
  main.style.width = width;
  const style = document.createElement("style");
  style.textContent = rules.join("\n");
  document.head.append(style);
}

document.addEventListener("DOMContentLoaded", () => {
  const esc = s => s.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;");
  marked.use({ renderer: { html: t => esc(t.text) } });
  document.querySelectorAll("section > pre").forEach(el => {
    const md = document.createElement("div");
    md.className = "md";
    md.innerHTML = marked.parse(el.textContent);
    el.replaceWith(md);
  });
  document.querySelectorAll("pre code[class*=\"language-\"]").forEach(el => hljs.highlightElement(el));

  const button = document.createElement("button");
  button.className = "export";
  button.innerHTML = '<svg viewBox="0 0 16 16" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"><path d="M8 2v8M4.5 6.5 8 10l3.5-3.5M3 13h10"/></svg>Export PDF';
  button.onclick = () => print();
  document.querySelector("header").append(button);

  sizeTallPages();
});
