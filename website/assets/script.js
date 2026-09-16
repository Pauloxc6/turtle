// Gerenciamento da Sidebar Mobile
const menuButton = document.getElementById("menuButton");
const closeSidebar = document.getElementById("closeSidebar");
const sidebar = document.getElementById("sidebar");
const sidebarOverlay = document.getElementById("sidebarOverlay");

function openMenu() {
  sidebar?.classList.add("open");
  sidebarOverlay?.classList.add("visible");
}

function closeMenu() {
  sidebar?.classList.remove("open");
  sidebarOverlay?.classList.remove("visible");
}

menuButton?.addEventListener("click", openMenu);
closeSidebar?.addEventListener("click", closeMenu);
sidebarOverlay?.addEventListener("click", closeMenu);

document.querySelectorAll("#sidebar nav a").forEach((link) => {
  link.addEventListener("click", closeMenu);
});

// Botão Copiar
document.querySelectorAll(".copy-button").forEach((button) => {
  button.addEventListener("click", async () => {
    const code = button.parentElement.querySelector("code");
    if (!code) return;

    try {
      await navigator.clipboard.writeText(code.innerText);
      const originalText = button.innerText;
      button.innerText = "Copiado!";
      setTimeout(() => (button.innerText = originalText), 1200);
    } catch (err) {
      console.error("Erro ao copiar:", err);
    }
  });
});

// Pesquisa
const searchInput = document.getElementById("searchInput");
const searchResults = document.getElementById("searchResults");
const sections = Array.from(document.querySelectorAll("main section[id]")).map((sec) => ({
  id: sec.id,
  title: sec.querySelector("h1, h2")?.innerText || sec.id,
}));

if (searchInput && searchResults) {
  searchInput.addEventListener("input", () => {
    const query = searchInput.value.toLowerCase().trim();
    if (!query) {
      searchResults.style.display = "none";
      searchResults.innerHTML = "";
      return;
    }

    const matches = sections.filter((s) => s.title.toLowerCase().includes(query));
    searchResults.innerHTML = "";

    matches.forEach((sec) => {
      const link = document.createElement("a");
      link.className = "search-result";
      link.href = `#${sec.id}`;
      link.textContent = sec.title;
      link.addEventListener("click", () => {
        searchResults.style.display = "none";
        searchInput.value = "";
        closeMenu();
      });
      searchResults.appendChild(link);
    });

    searchResults.style.display = matches.length > 0 ? "block" : "none";
  });
}

// Highlight da Seção Ativa
const navLinks = document.querySelectorAll("#navigation a");
const sectionsOnPage = document.querySelectorAll("main section[id]");

if (navLinks.length && sectionsOnPage.length) {
  const observer = new IntersectionObserver(
    (entries) => {
      entries.forEach((entry) => {
        if (!entry.isIntersecting) return;
        navLinks.forEach((link) => link.classList.remove("active"));
        const activeLink = document.querySelector(`#navigation a[href="#${entry.target.id}"]`);
        activeLink?.classList.add("active");
      });
    },
    { rootMargin: "-20% 0px -65% 0px" }
  );

  sectionsOnPage.forEach((sec) => observer.observe(sec));
}
