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

// Checkbox per entry; when any are checked, only those are printed.
function addExportTools() {
  const header = document.querySelector("header");
  const sections = [...document.querySelectorAll("section")];
  const tools = document.createElement("div");
  tools.className = "tools";
  tools.innerHTML = '<span class="count"></span><button class="toggle"></button><button class="export"><svg viewBox="0 0 16 16" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"><path d="M8 2v8M4.5 6.5 8 10l3.5-3.5M3 13h10"/></svg><b></b></button>';
  const [count, toggle, exportButton] = tools.children;

  const update = () => {
    const n = sections.filter(el => el.classList.contains("selected")).length;
    document.body.classList.toggle("picking", n > 0);
    count.textContent = n ? `${n} of ${sections.length} selected` : "";
    toggle.textContent = n === sections.length ? "Deselect all" : "Select all";
    exportButton.lastChild.textContent = n ? `Export ${n} to PDF` : "Export PDF";
  };
  const select = (el, on) => {
    el.classList.toggle("selected", on);
    el.querySelector(".pick").checked = on;
  };

  sections.forEach(el => {
    const box = document.createElement("input");
    box.type = "checkbox";
    box.className = "pick";
    box.title = "Select for PDF export";
    box.onchange = () => { select(el, box.checked); update(); };
    el.querySelector("time").prepend(box);
  });
  toggle.onclick = () => {
    const all = sections.every(el => el.classList.contains("selected"));
    sections.forEach(el => select(el, !all));
    update();
  };

  // The print title is the browser's default PDF file name.
  const title = document.title;
  const day = new Date().toISOString().slice(0, 10);
  const fileName = [...header.querySelectorAll(":scope > b, :scope > .name, :scope > span:last-of-type")]
    .map(el => el.textContent.trim()).concat(day).join(" ").replace(/[\\/:*?"<>|]+/g, "-");
  addEventListener("beforeprint", () => { document.title = fileName; });
  addEventListener("afterprint", () => { document.title = title; });
  exportButton.onclick = () => print();

  header.append(tools);
  update();
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

  addExportTools();

  sizeTallPages();
});
