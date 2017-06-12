decl str crystaltoolimplementationsprogramfile 'src/*/main.cr'
decl str toolsclient
decl -hidden int _grep_current_line 0

def -params .. -file-completion \
    -docstring %{crystal-tool-implementations [<arguments>]: crystal tool implementations wrapper
All the optional arguments are forwarded to the crystal tool implementations utility} \
    crystal-tool-implementations %{ %sh{
        output=$(mktemp -d -t kak-crystal-tool-implementations.XXXXXXXX)/fifo
        mkfifo ${output}
        if [ $# -gt 0 ]; then
            ( crystal tool implementations "$@" | tr -d '\r' > ${output} 2>&1 ) > /dev/null 2>&1 < /dev/null &
        else
            cursor="$kak_buffile:$kak_cursor_line:$kak_cursor_char_column"
            ( crystal tool implementations $kak_opt_crystaltoolimplementationsprogramfile --cursor "$cursor" | tr -d '\r' > ${output} 2>&1 ) > /dev/null 2>&1 < /dev/null &
        fi
        printf %s\\n "eval -try-client '$kak_opt_toolsclient' %{
            edit! -fifo ${output} -scroll *grep*
            set buffer filetype grep
            set buffer _grep_current_line 0
            hook -group fifo buffer BufCloseFifo .* %{
                nop %sh{ rm -r $(dirname ${output}) }
                remove-hooks buffer fifo
            }
        }"
}}
