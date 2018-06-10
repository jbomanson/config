define-command with-file-list \
    -params .. \
    -command-completion \
    -docstring "Execute a command on the list of all currently opened filenames.
Any arguments are forwarded to the command first." \
    %(
        %arg(@) %sh(echo "$kak_buflist" | tr ':' '\n' | grep -vF '*' | tr '\n' ' ')
    )

alias global wfl with-file-list
