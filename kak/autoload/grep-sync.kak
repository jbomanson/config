# This file implements a version of the grep command that waits for grep to
# finish as opposed to the regular grep command which shows the user a buffer
# that is filled with search results as they come.

define-command grep-sync \
    -params .. \
    -file-completion \
    -docstring "grep-sync [<arguments>]: synchronous grep utility wrapper that is synchronous
This command waits for grep to finish.
All the optional arguments are forwarded to the grep utility." \
    %{ %sh{
         output=$(mktemp -d -t kak-grep-sync.XXXXXXXX)/file
         if [ $# -gt 0 ]; then
             ( ${kak_opt_grepcmd} "$@" | tr -d '\r' > ${output} 2>&1 ) > /dev/null 2>&1 < /dev/null
         else
             ( ${kak_opt_grepcmd} "${kak_selection}" | tr -d '\r' > ${output} 2>&1 ) > /dev/null 2>&1 < /dev/null
         fi
         printf %s\\n "evaluate-commands -try-client '$kak_opt_toolsclient' %{
                   edit! ${output}
                   execute-keys -save-regs %() %(%y)
                   delete-buffer
                   nop %sh{ rm -r $(dirname ${output}) }
                   edit! -scratch *grep*
                   execute-keys %(%Rgjo<esc>)
                   set-option buffer filetype grep
                   set-option buffer _grep_current_line 0
               }"
    }}
