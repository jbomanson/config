declare-option str-list buflist_with_modified

define-command buflist_with_modified_update \
    -docstring "Assigns option buflist_with_modified to a list of the form
<bufname_1>,<modified_1>:<bufname_2>,<modified_2>:...
containing the name of every buffer and \"true\" or \"false\" indicating
whether the buffer has been modified or not." \
    %(
        set-option global buflist_with_modified ""
        evaluate-commands -buffer "*" -save-regs "" %(
            set-option -add global buflist_with_modified "%val(bufname),%val(modified)"
        )
    )

declare-option str-list buflist_modified

define-command buflist_modified_update \
    -docstring "Assigns option buflist_modified to a : delimited list of
modified buffers" \
    %(
        buflist_with_modified_update
        set-option global buflist_modified "%sh(
            ruby -e '
                puts ARGV
                    .shift
                    .split(\":\")
                    .map { |string| string[/(.*),true/, 1] }
                    .compact
                    .join(\":\")
            ' \"$kak_opt_buflist_with_modified\"
        )"
    )
