// Minimal terminal emulator for Shiny (no deps).
// www/terminal.js
(function () {
  const TERM_ID = "terminal";
  const PROMPT = "R> ";

  let initialized = false;
  let term = null;
  let history = [];
  let histPos = -1;
  let currentInput = "";
  const earlyMsgQueue = [];

  function el(tag, cls, text) {
    const e = document.createElement(tag);
    if (cls) e.className = cls;
    if (text != null) e.textContent = text;
    return e;
  }
  function scrollToBottom(c) {
    c.scrollTop = c.scrollHeight;
  }
  function focusInput() {
    const input = term && term.querySelector(".term-input:last-of-type");
    if (input) {
      input.focus();
      const sel = window.getSelection();
      const range = document.createRange();
      range.selectNodeContents(input);
      range.collapse(false);
      sel.removeAllRanges();
      sel.addRange(range);
    }
  }
  function makePromptLine() {
    const line = el("div", "term-line");
    const prompt = el("span", "term-prompt", PROMPT);
    const input = el("span", "term-input");
    input.contentEditable = "true";
    input.spellcheck = false;
    
    // Add click handler directly to the input
    input.addEventListener("click", function(e) {
      e.stopPropagation();
      this.focus();
      // Ensure cursor is placed at click position
      const sel = window.getSelection();
      const range = document.createRange();
      range.selectNodeContents(this);
      range.collapse(false);
      sel.removeAllRanges();
      sel.addRange(range);
    });
    
    line.appendChild(prompt);
    line.appendChild(input);
    return { line, input };
  }
  function appendOutputBlock(text, type) {
    if (!text) return;
    const cls =
      type === "error"
        ? "term-error"
        : type === "echo"
        ? "term-muted"
        : "term-output";
    const out = el("div", `term-line ${cls}`, text);
    term.appendChild(out);
  }
  function submitCommand(cmd) {
    const lastLine = term.querySelector(".term-line:last-child");
    const input = lastLine && lastLine.querySelector(".term-input");
    if (input) {
      input.contentEditable = "false";
      input.classList.add("term-muted");
    }
    if (window.Shiny && Shiny.setInputValue) {
      Shiny.setInputValue("term_cmd", cmd, { priority: "event" });
    }
    if (cmd.trim().length) {
      history.push(cmd);
      histPos = history.length;
    }
    scrollToBottom(term);
  }
  function handleKey(e) {
    const input = term.querySelector(".term-input:last-of-type");
    if (!input) return;

    if (e.key === "Enter") {
      e.preventDefault();
      submitCommand(input.textContent || "");
      return;
    }
    if (e.key === "ArrowUp") {
      e.preventDefault();
      if (histPos > 0) {
        if (histPos === history.length) currentInput = input.textContent;
        histPos--;
        input.textContent = history[histPos];
        focusInput();
      }
      return;
    }
    if (e.key === "ArrowDown") {
      e.preventDefault();
      if (histPos < history.length - 1) {
        histPos++;
        input.textContent = history[histPos];
      } else if (histPos === history.length - 1) {
        histPos = history.length;
        input.textContent = currentInput || "";
      }
      focusInput();
      return;
    }
    if ((e.ctrlKey || e.metaKey) && (e.key === "l" || e.key === "L")) {
      e.preventDefault();
      if (window.Shiny && Shiny.setInputValue) {
        Shiny.setInputValue("term_clear", Date.now(), { priority: "event" });
      }
      return;
    }
  }

  function registerMessageHandler() {
    if (!window.Shiny || !Shiny.addCustomMessageHandler) return false;
    Shiny.addCustomMessageHandler("term_out", function (msg) {
      if (!initialized) {
        earlyMsgQueue.push(msg);
        return;
      }
      if (!msg || !msg.type) return;
      if (msg.type === "clear") {
        term.innerHTML = "";
        const fresh = makePromptLine();
        term.appendChild(fresh.line);
        scrollToBottom(term);
        setTimeout(focusInput, 0);
      } else if (msg.type === "output") {
        appendOutputBlock(msg.text || "", "output");
        // Create new prompt AFTER output
        const next = makePromptLine();
        term.appendChild(next.line);
        scrollToBottom(term);
        // Focus the newly created input directly
        next.input.focus();
        const sel = window.getSelection();
        const range = document.createRange();
        range.selectNodeContents(next.input);
        range.collapse(false);
        sel.removeAllRanges();
        sel.addRange(range);
      } else if (msg.type === "error") {
        appendOutputBlock(msg.text || "", "error");
        // Create new prompt AFTER error
        const next = makePromptLine();
        term.appendChild(next.line);
        scrollToBottom(term);
        // Focus the newly created input directly
        next.input.focus();
        const sel = window.getSelection();
        const range = document.createRange();
        range.selectNodeContents(next.input);
        range.collapse(false);
        sel.removeAllRanges();
        sel.addRange(range);
      } else if (msg.type === "echo") {
        appendOutputBlock(msg.text || "", "echo");
        const next = makePromptLine();
        term.appendChild(next.line);
        scrollToBottom(term);
        // Focus the newly created input directly
        next.input.focus();
        const sel = window.getSelection();
        const range = document.createRange();
        range.selectNodeContents(next.input);
        range.collapse(false);
        sel.removeAllRanges();
        sel.addRange(range);
      }
    });
    return true;
  }

  function init() {
    if (initialized) return true;
    term = document.getElementById(TERM_ID);
    if (!term) return false;

    // Build first prompt and listeners
    const first = makePromptLine();
    term.appendChild(first.line);
    term.addEventListener("click", focusInput);

    // Avoid duplicate global key listener
    if (!window.__RShinyTerminalKeybound) {
      document.addEventListener("keydown", handleKey);
      window.__RShinyTerminalKeybound = true;
    }

    // Expose minimal API (optional)
    window.RShinyTerminal = {
      focus: focusInput,
    };

    // Register handler (may already be available)
    registerMessageHandler();

    // Flush any early messages
    initialized = true;
    while (earlyMsgQueue.length) {
      const msg = earlyMsgQueue.shift();
      Shiny && Shiny.addCustomMessageHandler && Shiny.onInputChange; // just to reference if needed
      // Manually dispatch through the same logic:
      if (msg.type === "clear") {
        term.innerHTML = "";
        const fresh = makePromptLine();
        term.appendChild(fresh.line);
      } else if (msg.type === "output") {
        appendOutputBlock(msg.text || "", "output");
      } else if (msg.type === "error") {
        appendOutputBlock(msg.text || "", "error");
      } else if (msg.type === "echo") {
        appendOutputBlock(msg.text || "", "echo");
      }
      scrollToBottom(term);
    }
    focusInput();
    return true;
  }

  // Try to init on DOM ready
  function onReady(fn) {
    if (document.readyState === "loading") {
      document.addEventListener("DOMContentLoaded", fn, { once: true });
    } else {
      fn();
    }
  }

  onReady(function () {
    if (init()) return;

    // If #terminal not yet in DOM (e.g., dynamic UI), observe until it appears
    const obs = new MutationObserver(() => {
      if (init()) {
        obs.disconnect();
      }
    });
    obs.observe(document.documentElement, { childList: true, subtree: true });
  });

  // Also try again when Shiny connects (covers reconnects/hydration timing)
  document.addEventListener(
    "shiny:connected",
    function () {
      registerMessageHandler();
      init();
    },
    { once: false }
  );
})();
