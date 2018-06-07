# Dependency: $kak_opt_crystal_tool_files (crystal-tool-implementations.kak)
# Dependency: set-register-to-file

define-command crystal-tool-context \
    -file-completion \
    -docstring %{Run crystal tool context on the cursor location.} \
    %{
        %sh{
            (
                output=$(mktemp -d -t kak-crystal-tool-context.XXXXXXXX)/file
                cursor="$kak_buffile:$kak_cursor_line:$kak_cursor_char_column"
                crystal tool context \
                        --cursor "$cursor" \
                        $(eval $kak_opt_crystal_tool_files) \
                        | tr -d '\r' > ${output} 2>&1
                printf %s\\n "
                    evaluate-commands -client ${kak_client} -save-regs v %{
                        set-register-to-file v '$output'
                        info \
                            -anchor $kak_cursor_line.$kak_cursor_char_column \
                            -placement above \
                            -title Context \
                            %reg{v}
                        nop %sh{ rm -r $(dirname ${output}) }
                    }
                " | kak -p ${kak_session}
            ) > /dev/null 2>&1 < /dev/null &
        }
    }
