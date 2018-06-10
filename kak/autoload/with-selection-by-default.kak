define-command with-selection-by-default \
    -params .. \
    -command-completion \
    -docstring "Execute a command with the given arguments or with the current
selection contents as the only argument if no arguments are given." \
    %( %sh(
        if [ $# -ge 2 ]; then
            echo '%arg(@)'
        else
            echo '%arg(@) %reg(.)'
        fi
    ) )
