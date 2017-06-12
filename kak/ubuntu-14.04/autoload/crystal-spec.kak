# This is based on kakoune/rc/core/grep.kak.

decl str crystalspeccmd 'crystal spec --no-color --debug'
decl str toolsclient
decl -hidden int _crystalspec_current_line 0
decl str _crystalspec_origin_bufname
decl str _crystalspec_args

# See http://www.commandlinefu.com/commands/view/3584/remove-color-codes-special-characters-with-sed
decl str stripcolorsedscript 's,\x1B\[[0-9;]*[a-zA-Z],,g'

def -params .. -file-completion \
    -docstring %{crystal-spec [<arguments>]: crystal spec command wrapper
All the optional arguments are forwarded to the crystal spec command} \
    crystal-spec %{
    # set global _crystalspec_args %sh{echo "%{$(printf "'%s' " "$@")}"}
    %sh{
        output=$(mktemp -d -t kak-crystal-spec.XXXXXXXX)/fifo
        mkfifo ${output}
        if [ $# -gt 0 ]; then
            ( ${kak_opt_crystalspeccmd} "$@" | sed "${kak_opt_stripcolorsedscript}" | tr -d '\r' > ${output} 2>&1 ) > /dev/null 2>&1 < /dev/null &
        else
            ( ${kak_opt_crystalspeccmd} "${kak_bufname}" | sed "${kak_opt_stripcolorsedscript}" | tr -d '\r' > ${output} 2>&1 ) > /dev/null 2>&1 < /dev/null &
        fi
        printf %s\\n "eval -try-client '$kak_opt_toolsclient' -save-regs q %{
            reg q $kak_bufname
            edit! -fifo ${output} -scroll *crystal-spec*
            set global _crystalspec_args %{$@}
            # set global _crystalspec_args %{$(printf "'%s' " "$@")}
            set buffer filetype crystal-spec
            set buffer _crystalspec_current_line 0
            set global _crystalspec_origin_bufname %reg{q}
            hook -group fifo buffer BufCloseFifo .* %{
                nop %sh{ rm -r $(dirname ${output}) }
                rmhooks buffer fifo
            }
        }"
    }
}

hook -group crystal-spec-highlight global WinSetOption filetype=crystal-spec %{
    addhl group crystal-spec
    addhl -group crystal-spec regex "^(?:(?:[^\n]* )?in (?:macro '[^']*' )?)?((?:\w:)?[^:\n]+):(\d+)[:,]" 1:cyan 2:green
    addhl -group crystal-spec regex "^crystal spec ([^:\n]+):(\d+)" 1:cyan 2:green
    addhl -group crystal-spec line %{%opt{_crystalspec_current_line}} default+b
    addhl -group crystal-spec regex "^\h*\^~*$" 0:red
    # The following is too much.
    # addhl -group crystal-spec regex "^       [^\n]*" 0:red
    addhl -group crystal-spec regex "(?:(?<=E|F)|^)\.+(?=E|F|$)" 0:green
    addhl -group crystal-spec regex "(?:(?<=\.)|^)(?:E|F)+(?=\.|$)" 0:red
}

hook global WinSetOption filetype=crystal-spec %{
    hook buffer -group crystal-spec-hooks NormalKey <ret> crystal-spec-jump
    hook buffer -group crystal-spec-hooks NormalKey <backspace> %{ buffer %opt{_crystalspec_origin_bufname} }
}

hook -group crystal-spec-highlight global WinSetOption filetype=(?!crystal-spec).* %{ rmhl crystal-spec }

hook global WinSetOption filetype=(?!crystal-spec).* %{
    rmhooks buffer crystal-spec-hooks
}

decl str jumpclient

def -hidden crystal-spec-jump %{
    eval -collapse-jumps %{
        try %{
            try %{
                exec -draft "xs^(?:(?:[^\n]* )?in (?:macro '[^']*' )?)?((?:\w:)?[^:\n]+):(\d+)[:,]<ret>"
                exec "xs^(?:(?:[^\n]* )?in (?:macro '[^']*' )?)?((?:\w:)?[^:\n]+):(\d+)[:,]<ret>"
            } catch %{
                exec -draft 'xs^crystal spec ([^:\n]+):(\d+)<ret>'
                exec "xs^crystal spec ([^:\n]+):(\d+)<ret>"
            }
            set buffer _crystalspec_current_line %val{cursor_line}
            eval -try-client %opt{jumpclient} edit -existing %reg{1} %reg{2}
            try %{ focus %opt{jumpclient} }
        }
    }
}

def crystal-spec-next -docstring 'Jump to the next crystal-spec match' %{
    eval -collapse-jumps -try-client %opt{jumpclient} %{
        buffer '*crystal-spec*'
        exec "%opt{_crystalspec_current_line}g<a-l>/^[^:]+:\d+:<ret>"
        crystal-spec-jump
    }
    try %{ eval -client %opt{toolsclient} %{ exec %opt{_crystalspec_current_line}g } }
}

def crystal-spec-prev -docstring 'Jump to the previous crystal-spec match' %{
    eval -collapse-jumps -try-client %opt{jumpclient} %{
        buffer '*crystal-spec*'
        exec "%opt{_crystalspec_current_line}g<a-/>^[^:]+:\d+:<ret>"
        crystal-spec-jump
    }
    try %{ eval -client %opt{toolsclient} %{ exec %opt{_crystalspec_current_line}g } }
}

def crystal-spec-repeat -docstring 'Repeat the most recent crystal-spec call' %{
    buffer %opt{_crystalspec_origin_bufname}
    %sh{
        echo "crystal-spec ${kak_opt__crystalspec_args}"
    }
}
