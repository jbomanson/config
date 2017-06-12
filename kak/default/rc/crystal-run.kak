# This is based on kakoune/rc/core/grep.kak and crystal-spec.kak.

decl str crystalruncmd 'crystal run --no-color --debug'
decl str toolsclient
decl -hidden int _crystalrun_current_line 0
decl str _crystalrun_origin_bufname
decl str _crystalrun_args

# See http://www.commandlinefu.com/commands/view/3584/remove-color-codes-runial-characters-with-sed
decl str stripcolorsedscript 's,\x1B\[[0-9;]*[a-zA-Z],,g'

def -params .. -file-completion \
    -docstring %{crystal-run [<arguments>]: crystal run command wrapper
All the optional arguments are forwarded to the crystal run command} \
    crystal-run %{
    %sh{
        output=$(mktemp -d -t kak-crystal-run.XXXXXXXX)/fifo
        mkfifo ${output}
        if [ $# -gt 0 ]; then
            ( ${kak_opt_crystalruncmd} "$@" | sed "${kak_opt_stripcolorsedscript}" | tr -d '\r' > ${output} 2>&1 ) > /dev/null 2>&1 < /dev/null &
        else
            ( ${kak_opt_crystalruncmd} "${kak_bufname}" | sed "${kak_opt_stripcolorsedscript}" | tr -d '\r' > ${output} 2>&1 ) > /dev/null 2>&1 < /dev/null &
        fi
        printf %s\\n "eval -try-client '$kak_opt_toolsclient' -save-regs q %{
            reg q $kak_bufname
            edit! -fifo ${output} -scroll *crystal-run*
            set global _crystalrun_args %{$@}
            set buffer filetype crystal-run
            set buffer _crystalrun_current_line 0
            set global _crystalrun_origin_bufname %reg{q}
            hook -group fifo buffer BufCloseFifo .* %{
                nop %sh{ rm -r $(dirname ${output}) }
                rmhooks buffer fifo
            }
        }"
    }
}

hook global WinSetOption filetype=crystal-run %{
    hook buffer -group crystal-run-hooks NormalKey <backspace> %{ buffer %opt{_crystalrun_origin_bufname} }
}

hook global WinSetOption filetype=(?!crystal-run).* %{
    rmhooks buffer crystal-run-hooks
}

decl str jumpclient

def crystal-run-repeat -docstring 'Repeat the most recent crystal-run call' %{
    buffer %opt{_crystalrun_origin_bufname}
    %sh{
        echo "crystal-run ${kak_opt__crystalrun_args}"
    }
}
