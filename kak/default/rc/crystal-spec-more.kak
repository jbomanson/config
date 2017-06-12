decl str toolsclient

hook global WinSetOption filetype=crystal-spec %{
    map buffer user -docstring "Display a quoted string in a buffer" q %(:crystal-spec-puts-colon<ret>)
}

def crystal-spec-puts-colon %{
    exec ' ghf";GLL<a-F>":crystal-spec-puts<ret>'
}

def -hidden crystal-spec-puts %{
    %sh{
        output=$(mktemp -d -t kak-crystal-spec-puts.XXXXXXXX)/fifo
        echo "echo '${output}'"
        mkfifo ${output}
        ( ruby -e "puts ${kak_selection}" >${output}  2>&1 ) > /dev/null 2>&1 < /dev/null &
        printf %s\\n "eval -try-client '$kak_opt_toolsclient' %{
            edit! -fifo ${output} -scroll *crystal-spec-puts*
            hook -group fifo buffer BufCloseFifo .* %{
                nop %sh{ rm -r $(dirname ${output}) }
                rmhooks buffer fifo
            }
        }"
    }
}
