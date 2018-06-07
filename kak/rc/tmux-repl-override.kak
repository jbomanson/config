# DONE 2018-04-28:
#     rm stock/extra/tmux-repl.kak
#     touch stock/extra/tmux-repl.kak

# http://tmux.github.io/
# ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾

hook global KakBegin .* %{
    %sh{
        if [ -n "$TMUX" ]; then
            VERSION_TMUX=$(tmux -V)
            VERSION_TMUX=$(expr "${VERSION_TMUX}" : 'tmux \([0-9]*\).*')

            if [ "${VERSION_TMUX}" -gt 1 ]; then
                echo "
                    alias global repl tmux-repl-horizontal
                    alias global send-text tmux-send-text
                "
            else
                echo "
                    alias global repl tmux-repl-disabled
                    alias global send-text tmux-repl-disabled
                "
            fi
        fi
    }
}

declare-option str tmux_repl_window_id
declare-option str tmux_repl_pane_id

# MODIFIED 2018-04-28: Use kak options instead of tmux buffers.
# MODIFIED 2018-04-28: Use window_id and pane_id.
define-command -hidden -params 1..2 tmux-repl-impl %{
    %sh{
        if [ -z "$TMUX" ]; then
            echo "echo -markup '{Error}This command is only available in a tmux session'"
            exit
        fi
        tmux_args="$1"
        shift
        tmux_cmd="$@"
        tmux $tmux_args $tmux_cmd
        tmux set-buffer -b kak_repl_window $(tmux display-message -p '#I')
        tmux set-buffer -b kak_repl_pane $(tmux display-message -p '#P')
        tmux set-buffer -b kak_repl_window_id $(tmux display-message -p '#{window_id}')
        tmux set-buffer -b kak_repl_pane_id $(tmux display-message -p '#{pane_id}')
        window_id="$(tmux display-message -p '#{window_id}')"
        pane_id="$(tmux display-message -p '#{pane_id}')"
        printf '%s\n' "
            evaluate-commands -client $kak_client %(
                set-option window tmux_repl_window_id '$window_id'
                set-option window tmux_repl_pane_id '$pane_id'
            )
        " | kak -p "$kak_session"
    }
}

define-command tmux-repl-vertical -params 0..1 -command-completion -docstring "Create a new vertical pane for repl interaction" %{
    tmux-repl-impl 'split-window -v' %arg{@}
}

define-command tmux-repl-horizontal -params 0..1 -command-completion -docstring "Create a new horizontal pane for repl interaction" %{
    tmux-repl-impl 'split-window -h' %arg{@}
}

define-command tmux-repl-window -params 0..1 -command-completion -docstring "Create a new window for repl interaction" %{
    tmux-repl-impl 'new-window' %arg{@}
}

# MODIFIED 2018-04-28: Use window_id and pane_id.
define-command -hidden tmux-send-text -docstring "Send the selected text to the repl pane" %{
    nop %sh{
        tmux set-buffer -b kak_selection "${kak_selection}"
        kak_orig_window_id=$(tmux display-message -p '#{window_id}')
        kak_orig_pane_id=$(tmux display-message -p '#{pane_id}')
        tmux select-window -t "$kak_opt_tmux_repl_window_id"
        tmux select-pane -t "$kak_opt_tmux_repl_pane_id"
        tmux paste-buffer -b kak_selection
        tmux select-window -t "${kak_orig_window_id}"
        tmux select-pane -t "${kak_orig_pane_id}"
    }
}

define-command -hidden tmux-repl-disabled %{ %sh{
    VERSION_TMUX=$(tmux -V)
    printf %s "echo -markup %{{Error}The version of tmux is too old: got ${VERSION_TMUX}, expected >= 2.x}"
} }
