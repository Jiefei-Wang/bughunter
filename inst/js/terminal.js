// Minimal terminal emulator for Shiny (no deps).
(function () {
  const TERM_ID = "terminal";
  const PROMPT = "R> ";

  function el(tag, cls, text) {
    const e = document.createElement(tag);
    if (cls) e.className = cls;
    if (text != null) e.textContent = text;
    return e;
  }

  function scrollToBottom(container) {
    container.scrollTop = container.scrollHeight;
  }

  function makePromptLine() {
    const line = el("div", "term-line");
    const prompt = el("span", "term-prompt", PROMPT);
    const input = el("span", "term-input");
    input.contentEditable = "true";
    input.spellcheck = false;
    line.appendChild(prompt);
    line.appendChild(input);
    return { line, input };
  }

  const term = document.getElementById(TERM_ID);
  const history = [];
  let histPos = -1;
  let currentInput = "";

  function focusInput() {
    const input = term.querySelector(".term-input:last-of-type");
    if (input) {
      input.focus();
      // place caret at end
      const sel = window.getSelection();
      const range = document.createRange();
      range.selectNodeContents(input);
      range.collapse(false);
      sel.removeAllRanges();
      sel.addRange(range);
    }
  }

  function appendOutputBlock(text, type) {
    if (text && text.length) {
      const cls = type === "error" ? "term-error" :
                  type === "echo"  ? "term-muted" : "term-output";
      const out = el("div", `term-line ${cls}`, text);
      term.appendChild(out);
    }
  }

  function submitCommand(cmd) {
    // Echo the command frozen
    const lastLine = term.querySelector(".term-line:last-child");
    const input = lastLine && lastLine.querySelector(".term-input");
    if (input) {
      input.contentEditable = "false";
      input.classList.add("term-muted");
    }

    // Send to Shiny
    if (window.Shiny && Shiny.setInputValue) {
      Shiny.setInputValue("term_cmd", cmd, { priority: "event" });
    }

    // Keep history
    if (cmd.trim().length) {
      history.push(cmd);
      histPos = history.length;
    }

    // New prompt
    const next = makePromptLine();
    term.appendChild(next.line);
    scrollToBottom(term);
    focusInput();
  }

  function handleKey(e) {
    const input = term.querySelector(".term-input:last-of-type");
    if (!input) return;

    if (e.key === "Enter") {
      e.preventDefault();
      const cmd = input.textContent || "";
      submitCommand(cmd);
      return;
    }

    // History: Up / Down
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

    // Ctrl+L -> clear
    if ((e.ctrlKey || e.metaKey) && (e.key === "l" || e.key === "L")) {
      e.preventDefault();
      if (window.Shiny && Shiny.setInputValue) {
        Shiny.setInputValue("term_clear", new Date().getTime(), { priority: "event" });
      }
      return;
    }
  }

  // Initialize
  const first = makePromptLine();
  term.appendChild(first.line);
  term.addEventListener("click", focusInput);
  document.addEventListener("keydown", handleKey);
  focusInput();

  // Expose minimal API for server messages
  window.RShinyTerminal = {
    appendOutput: function (msg) {
      if (!msg || !msg.type) return;
      if (msg.type === "clear") {
        term.innerHTML = "";
        const fresh = makePromptLine();
        term.appendChild(fresh.line);
        focusInput();
        return;
      }
      if (msg.type === "output") {
        appendOutputBlock(msg.text || "", "output");
      } else if (msg.type === "error") {
        appendOutputBlock(msg.text || "", "error");
      } else if (msg.type === "echo") {
        appendOutputBlock(msg.text || "", "echo");
      }
      scrollToBottom(term);
      focusInput();
    }
  };
})();
