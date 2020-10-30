hook global ModuleLoaded x11 %{
    require-module x11-repl
}

provide-module x11-repl %{

declare-option -docstring "window id of the REPL window" str x11_repl_id

define-command -docstring %{
    x11-repl [<arguments>]: create a new window for repl interaction
    All optional parameters are forwarded to the new window
} \
    -params .. \
    -shell-completion \
    x11-repl %{ x11-terminal sh -c %{
        winid="${WINDOWID:-$(xdotool search --pid ${PPID} | tail -1)}"
        printf "evaluate-commands -try-client $1 \
            'set-option current x11_repl_id ${winid}'" | kak -p "$2"
        shift 2;
        [ "$1" ] && "$@" || "$SHELL"
    } -- %val{client} %val{session} %arg{@}
}

define-command x11-send-text -docstring "send the selected text to the repl window" %{
    evaluate-commands %sh{
        printf %s\\n "${kak_selection}" | xsel -i ||
        echo 'fail x11-send-text: failed to run xsel, see *debug* buffer for details' &&
        xdotool windowactivate "${kak_opt_x11_repl_id}" key --clearmodifiers Shift+Insert ||
        echo 'fail x11-send-text: failed to run xdotool, see *debug* buffer for details'
    }
}

alias global repl-new x11-repl
alias global repl-send-text x11-send-text

}
