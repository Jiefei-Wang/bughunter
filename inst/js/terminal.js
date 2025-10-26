// Minimal terminal emulator for Shiny (no deps).
// www/terminal.js
(function () {
    const TERM_ID = "terminal";
    const PROMPT = "> ";

    let initialized = false;
    let term = null;
    // Past terminal output container
    let terminal_output = el("div");
    // Input line elements
    let term_line = el("div", "term-line");
    let prompt = el("span", "term-prompt", PROMPT);
    let input = el("span", "term-input");
    input.contentEditable = "true";
    input.spellcheck = false;
    term_line.appendChild(prompt);
    term_line.appendChild(input);

    // history of commands
    let command_history = [];
    let history_index = 0;

    // Mouse movement
    const mouseDelta = 6;
    let mouseStartX;
    let mouseStartY;

    const DOUBLE_CLICK_DELAY = 400; // milliseconds
    let mouseClickTime;



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
        input.focus();
    }

    function appendOutputBlock(text, type = "output") {
        if (!text) return;
        let cls = "term-output";
        if (type === "error") {
            cls = "term-error";
        } else if (type === "echo") {
            cls = "term-muted";
        } else if (type === "warning") {
            cls = "term-warning";
        }

        const out = el("div", `term-line ${cls}`, text);
        terminal_output.appendChild(out);
    }

    function submitCommand(cmd) {
        command_history.push(cmd);
        history_index = command_history.length;
        Shiny.setInputValue("term_cmd", cmd, { priority: "event" });
    }

    function handleKey(e) {
        const textContent = input.textContent;
        // console.log("Key pressed:", e.key, "Content:", textContent);

        if (e.key === "Enter") {
            if (textContent === "") {
                return;
            }
            e.preventDefault();
            submitCommand(textContent);
            appendOutputBlock(PROMPT + textContent, "output");
            input.textContent = "";
            return;
        }
        if (e.key === "ArrowUp") {
            e.preventDefault();
            // console.log("History index before:", history_index);
            // console.log("command_history before:", command_history);
            if (
                textContent != "" &&
                history_index === command_history.length
            ) {
                command_history.push(textContent);
            }
            if (history_index > 0) {
                history_index--;
                input.textContent = command_history[history_index];
            }
            return;
        }
        if (e.key === "ArrowDown") {
            e.preventDefault();
            if (history_index < command_history.length - 1) {
                history_index++;
                input.textContent = command_history[history_index];
            }
            return;
        }
        // ctrl + c to clear input
        if (e.key === "c" && (e.ctrlKey || e.metaKey)) {
            if (input.textContent !== "") {
                e.preventDefault();
                input.textContent = "";
                history_index = command_history.length;
            }
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
        Shiny.addCustomMessageHandler("term_out", function (msg) {
            if (msg.type === "clear") {
                terminal_output.innerHTML = "";
                scrollToBottom(term);
            } else if (msg.type === "output") {
                appendOutputBlock(msg.text, "output");
                scrollToBottom(term);
            } else if (msg.type === "error") {
                appendOutputBlock(msg.text, "error");
                scrollToBottom(term);
            } else if (msg.type === "warning") {
                appendOutputBlock(msg.text, "warning");
                scrollToBottom(term);
            } else if (msg.type === "echo") {
                appendOutputBlock(msg.text, "echo");
                scrollToBottom(term);
            }
        });
        return true;
    }

    function init() {
        if (initialized) return true;
        term = document.getElementById(TERM_ID);
        if (!term) return false;
        term.appendChild(terminal_output);
        term.appendChild(term_line);

        
        term.addEventListener('mousedown', function (event) {
            mouseClickTime = Date.now();
            mouseStartX = event.pageX;
            mouseStartY = event.pageY;
        });

        term.addEventListener('mouseup', function (event) {
            const diffX = Math.abs(event.pageX - mouseStartX);
            const diffY = Math.abs(event.pageY - mouseStartY);

            if (diffX < mouseDelta && diffY < mouseDelta && (Date.now() - mouseClickTime) > DOUBLE_CLICK_DELAY) {
                focusInput();
            }
        });

        // Avoid duplicate global key listener
        if (!window.__RShinyTerminalKeybound) {
            document.addEventListener("keydown", handleKey);
            window.__RShinyTerminalKeybound = true;
        }

        // Expose minimal API for debugging
        window.RShinyTerminal = {
            focus: focusInput,
        };

        // Register terminal message handler
        registerMessageHandler();

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

    // Also try again when Shiny connects
    document.addEventListener(
        "shiny:connected",
        function () {
            registerMessageHandler();
            init();
        },
        { once: false }
    );
})();
