# NOTE: This thing reuses lint_* options.

declare-option str tmux_lint_program tmux-lint

define-command tmux-lint -docstring 'Mine tmux panes in this session for lint findings' %{
    %sh(
        PATH="$PATH:$kak_config/bin"
        if ! which "$kak_opt_tmux_lint_program" >/dev/null 2>&1; then
          printf %s\\n "echo -markup '{Error}tmux-lint: Failed to find $kak_opt_tmux_lint_program (See option tmux_lint_program)'"
          exit 1
        fi
        exec "$kak_opt_tmux_lint_program" "$kak_buflist" "$kak_client" "$kak_timestamp"
    )
}
