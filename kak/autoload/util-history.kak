define-command util-history-undo \
    -params 1.. \
    -file-completion \
    -docstring \
"util-history-undo <file> [<options>]: Backtrack in history and write a
patch to redo the change to <file> using diff with <options>.
Any given count determines the number of undone changes." \
    %(
        util-history-diff "%sh(echo \"execute-keys $kak_count<a-u>\")" %arg(@)
    )

define-command util-history-undo-maximal \
    -params 1.. \
    -file-completion \
    -docstring \
"util-history-undo-maximal <file> [<options>]: Backtrack in history as far as
possible and write a patch to redo the change to <file> using diff with
<options>." \
    %(
        util-history-diff undo-maximally %arg(@)
    )

# Example:
# util-history-diff "execute-keys Oxyz<ret><esc>" /tmp/here.txt
define-command util-history-diff \
    -hidden \
    -params 2.. \
    -docstring \
"util-history-diff <command> <file> [<options>]: Evaluate <command> and
write a patch to undo the command to <file> using diff with <options>." \
    %(
        util-history-shell \
            "%arg(1)" \
            diff "%sh(shift 2; echo \"$@\")" --label "%val(buffile)" $1 $2 \
            > "%arg(2)"
    )

# Example:
# util-history-shell "execute-keys Oxyz<ret><esc>" cat $1 $2 >/tmp/here.txt
define-command util-history-shell \
    -params 2.. \
    -docstring \
"util-history-shell <command> <action> [option...]: Evaluate <command>.
Then evaluate <action> <option...> in a shell with the contents of
the current buffer before <command> as $1 and after <command> as $2." \
    %( %sh(
        dir=$(mktemp -d "${TMPDIR:-/tmp}"/kak-history-shell.XXXXXXXX)
        command="$1"
        shift
        shell_command="$@"
        shift
        printf '%s\n' "evaluate-commands -no-hooks %(
            write $dir/old
            $command
            write $dir/new
            nop %sh(
                set -- $dir/old $dir/new
                $shell_command
                rm -r $dir
            )
        )"
    ) )

# - On fifo buffers such as *grep* etc, this will either go back to the empty
#   initial state or the state after the most recent grep call.
define-command undo-maximally %(
        try %(
            execute-keys u
            undo-maximally
        )
    )

# # This is like undo-maximally, but this will never undo to a state where
# # history_id is zero.
# define-command undo-maximally-almost %(
#         %sh(
#             if test "$kak_history_id" -ne 1; then
#                 printf %s\\n "
#                     try %(
#                         execute-keys u
#                         undo-maximally-almost
#                     )
#                 "
#             fi
#         )
#     )

# Go as far back in history as possible without emptying the buffer.
define-command undo-while-nonempty %(
    execute-keys u
    evaluate-commands -draft %(
        execute-keys '%'
        %sh(
            if test "$kak_selection_desc" = "1.1,1.1"; then
                printf %s\\n "execute-keys U"
            else
                printf %s\\n "try %( undo-while-nonempty )"
            fi
        )
    )
)

define-command redo-maximally %(
        try %(
            execute-keys U
            undo-maximally
        )
    )

