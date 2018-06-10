declare-option str preserved_indentation ""

define-command with-preserved-indentation \
    -params .. \
    -command-completion \
    -docstring "Remove indentation from the selection, evaluate given arguments
as a command, and then add the indentation back." \
    %(
        evaluate-commands -itersel %(
            # Yank indentation from the first line into the default register.
            # Then remove that indentation from wherever it appears.
            evaluate-commands %(
                try %(
                    execute-keys -draft -no-hooks -save-regs "" %(<a-x>s\A +<ret>y)
                    execute-keys -draft -no-hooks %(s^\Q<c-r>"\E<ret>d)
                ) catch %(
                    reg %(") ""
                )
                set-option global preserved_indentation %reg(")
            )
            %arg(@)
            set-register '"' %opt(preserved_indentation)
            execute-keys -no-hooks %(<a-s>ghP<a-x><a-m>)
        )
    )

alias global wpi with-preserved-indentation

declare-option str preserved_prefix ""
declare-option str preserved_prefix_regex '(\s*[-+*#%]+\s*|\s*//+\s*|\s+)'

define-command with-preserved-prefix \
    -params .. \
    -command-completion \
    -docstring "Remove a prefix from every selected line, evaluate given
arguments as a command, and then add the prefix back.
The option preserved_prefix gives the prefix during evaluation." \
    %(
        evaluate-commands -itersel %(
            # Yank a prefix from the first line into the default register.
            # Then remove that prefix from wherever it appears.
            evaluate-commands %(
                try %(
                    execute-keys -draft -no-hooks -save-regs "" \
                        <a-x>s\A %opt(preserved_prefix_regex) <ret>y
                    execute-keys -draft -no-hooks %(s^\Q<c-r>"\E<ret>d)
                ) catch %(
                    reg %(") ""
                )
                set-option global preserved_prefix %reg(")
            )
            %arg(@)
            set-register '"' %opt(preserved_prefix)
            execute-keys -no-hooks %(<a-s>ghP<a-x><a-m>)
        )
    )

alias global wpp with-preserved-prefix

define-command without-secondary-prefix \
    -docstring "Replace certain types of prefix strings with spaces" \
    %(
        evaluate-commands -draft -itersel %(
            try %( execute-keys %(<a-s>'<a-space>s\*|-<ret>r<space>) )
        )
    )
