declare-option \
    -docstring %(A shell command that prints files to looked at by
crystal-tool-implementations.) \
    str \
    crystal_tool_files \
    %(find spec -type f -iname "*_spec.cr")

declare-option str toolsclient

declare-option -hidden int _grep_current_line 0

# TODO: Save the current file before this.
# Preferrably it would be saved in some temporary location, but that might
# not work correctly...
 
define-command -params .. -file-completion \
    -docstring %{Run crystal tool implementations on the cursor location.
All optional arguments are forwarded to the tool.} \
    crystal-tool-implementations \
    %{ %sh{
        output=$(mktemp -d -t kak-crystal-tool-implementations.XXXXXXXX)/fifo
        mkfifo ${output}
        if [ $# -gt 0 ]; then
            (
                crystal tool implementations "$@" \
                    | tr -d '\r' > ${output} 2>&1
            ) > /dev/null 2>&1 < /dev/null &
        else
            cursor="$kak_buffile:$kak_cursor_line:$kak_cursor_char_column"
            (
                crystal tool implementations \
                    --cursor "$cursor" \
                    $(eval $kak_opt_crystal_tool_files) \
                    | tr -d '\r' > ${output} 2>&1
            ) > /dev/null 2>&1 < /dev/null &
        fi
        printf %s\\n "evaluate-commands -try-client '$kak_opt_toolsclient' %{
            edit! -fifo ${output} -scroll *grep*
            set-option buffer filetype grep
            set-option buffer _grep_current_line 0
            hook -group fifo buffer BufCloseFifo .* %{
                nop %sh{ rm -r $(dirname ${output}) }
                remove-hooks buffer fifo
            }
        }"
    }}
