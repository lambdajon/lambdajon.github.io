"use strict";
// Pure helpers 
const urlLangPrefix = () => {
    const m = window.location.pathname.match(/^\/([a-z]{2})(\/|$)/);
    return m ? m[1] : null;
};
const dictFor = (lang) => i18n[lang] ?? i18n["en"] ?? {};
const langUrls = () => {
    const el = document.getElementById("lang-urls");
    if (!el)
        return {};
    try {
        return JSON.parse(el.textContent ?? "{}");
    }
    catch {
        return {};
    }
};
const targetUrl = (lang, currentPath) => {
    const urls = langUrls();
    if (urls[lang] && urls[lang] !== currentPath)
        return urls[lang];
    const prefix = urlLangPrefix();
    if (lang === siteDefaultLang)
        return prefix ? currentPath.replace(/^\/[a-z]{2}\//, "/") : currentPath;
    if (prefix)
        return currentPath.replace(/^\/[a-z]{2}\//, `/${lang}/`);
    return `/${lang}${currentPath || "/"}`;
};
// DOM effects
const applyTranslations = (lang) => {
    const dict = dictFor(lang);
    document.documentElement.setAttribute("lang", lang);
    document.querySelectorAll("[data-i18n]").forEach(el => {
        const key = el.dataset.i18n;
        if (key && dict[key])
            el.textContent = dict[key];
    });
};
const setActiveLangBtn = (lang) => {
    document.querySelectorAll("[data-lang-btn]").forEach(btn => {
        btn.classList.toggle("active", btn.dataset.langBtn === lang);
    });
};
const activateLang = (lang) => {
    localStorage.setItem("lang", lang);
    applyTranslations(lang);
    setActiveLangBtn(lang);
};
// Lang switcher
const initLangSwitcher = () => {
    document.querySelectorAll("[data-lang-btn]").forEach(btn => {
        btn.addEventListener("click", () => {
            const lang = btn.dataset.langBtn;
            if (!lang)
                return;
            activateLang(lang);
            const path = window.location.pathname;
            const target = targetUrl(lang, path);
            if (target !== path)
                window.location.href = target;
        });
    });
    const prefix = urlLangPrefix();
    const storedLang = localStorage.getItem("lang") ?? siteDefaultLang;
    if (prefix) {
        // URL prefix is authoritative — sync localStorage to it
        localStorage.setItem("lang", prefix);
        activateLang(prefix);
    }
    else if (storedLang !== siteDefaultLang) {
        // No prefix but user prefers non-default lang — redirect silently
        window.location.replace(`/${storedLang}${window.location.pathname || "/"}`);
    }
    else {
        activateLang(storedLang);
    }
};
// Nav highlight
const initNavHighlight = () => {
    const path = window.location.pathname;
    document.querySelectorAll(".nav__link").forEach(link => {
        const href = link.getAttribute("href") ?? "";
        const active = href !== "/" ? path.startsWith(href) : path === "/";
        link.classList.toggle("nav__link--active", active);
    });
};
// Code copy
const copyCode = (btn) => {
    const pre = btn.closest("pre");
    const code = pre?.querySelector("code")?.innerText ?? "";
    navigator.clipboard.writeText(code).then(() => {
        const original = btn.textContent ?? "";
        btn.textContent = "copied!";
        btn.classList.add("copied");
        setTimeout(() => {
            btn.textContent = original;
            btn.classList.remove("copied");
        }, 2000);
    });
};
const initCopyButtons = () => {
    document.querySelectorAll("div.sourceCode").forEach(div => {
        const code = div.querySelector("code");
        const pre = div.querySelector("pre");
        if (!pre)
            return;
        if (code) {
            div.dataset.lang = code.className.replace(/sourceCode\s*/g, "").trim() || "text";
        }
        const btn = document.createElement("button");
        btn.className = "code-copy-btn";
        btn.textContent = "copy";
        btn.addEventListener("click", () => copyCode(btn));
        pre.appendChild(btn);
    });
};
// Theme toggle
const sunSvg = `<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">` +
    `<circle cx="12" cy="12" r="4"/>` +
    `<line x1="12" y1="2" x2="12" y2="6"/><line x1="12" y1="18" x2="12" y2="22"/>` +
    `<line x1="4.93" y1="4.93" x2="7.76" y2="7.76"/><line x1="16.24" y1="16.24" x2="19.07" y2="19.07"/>` +
    `<line x1="2" y1="12" x2="6" y2="12"/><line x1="18" y1="12" x2="22" y2="12"/>` +
    `<line x1="4.93" y1="19.07" x2="7.76" y2="16.24"/><line x1="16.24" y1="7.76" x2="19.07" y2="4.93"/>` +
    `</svg>`;
const moonSvg = `<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">` +
    `<path d="M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z"/>` +
    `</svg>`;
const applyTheme = (theme) => {
    document.documentElement.setAttribute("data-theme", theme);
    document.querySelectorAll("[data-theme-toggle]").forEach(btn => {
        btn.innerHTML = theme === "light" ? moonSvg : sunSvg;
        btn.setAttribute("aria-label", theme === "light" ? "Switch to dark theme" : "Switch to light theme");
    });
};
const initTheme = () => {
    const stored = localStorage.getItem("theme");
    const preferred = matchMedia("(prefers-color-scheme: light)").matches ? "light" : "dark";
    applyTheme(stored ?? preferred);
    document.querySelectorAll("[data-theme-toggle]").forEach(btn => {
        btn.addEventListener("click", () => {
            const current = document.documentElement.getAttribute("data-theme") ?? "dark";
            const next = current === "dark" ? "light" : "dark";
            localStorage.setItem("theme", next);
            applyTheme(next);
        });
    });
};
// Init
const init = () => {
    initTheme();
    initLangSwitcher();
    initNavHighlight();
    initCopyButtons();
};
if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", init);
}
else {
    init();
}
