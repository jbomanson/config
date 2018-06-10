# This is based on kakoune/rc/core/grep.kak and crystal-spec.kak.

# declare-option str crystalruncmd 'crystal run --no-color --debug'
# declare-option str toolsclient
# declare-option -hidden int _crystalrun_current_line 0
# declare-option str _crystalrun_origin_bufname
# declare-option str _crystalrun_args
# 
# # See http://www.commandlinefu.com/commands/view/3584/remove-color-codes-runial-characters-with-sed
# declare-option str stripcolorsedscript 's,\x1B\[[0-9;]*[a-zA-Z],,g'
# 
# define-command -params .. -file-completion \
#     -docstring %{crystal-run [<arguments>]: crystal run command wrapper
# All the optional arguments are forwarded to the crystal run command} \
#     crystal-run %{
#     %sh{
#         output=$(mktemp -d -t kak-crystal-run.XXXXXXXX)/fifo
#         mkfifo ${output}
#         if [ $# -gt 0 ]; then
#             ( ${kak_opt_crystalruncmd} "$@" | sed "${kak_opt_stripcolorsedscript}" | tr -d '\r' > ${output} 2>&1 ) > /dev/null 2>&1 < /dev/null &
#         else
#             ( ${kak_opt_crystalruncmd} "${kak_bufname}" | sed "${kak_opt_stripcolorsedscript}" | tr -d '\r' > ${output} 2>&1 ) > /dev/null 2>&1 < /dev/null &
#         fi
#         printf %s\\n "evaluate-commands -try-client '$kak_opt_toolsclient' -save-regs q %{
#             reg q $kak_bufname
#             edit! -fifo ${output} -scroll *crystal-run*
#             set-option global _crystalrun_args %{$@}
#             set-option buffer filetype crystal-run
#             set-option buffer _crystalrun_current_line 0
#             set-option global _crystalrun_origin_bufname %reg{q}
#             hook -group fifo buffer BufCloseFifo .* %{
#                 nop %sh{ rm -r $(dirname ${output}) }
#                 rmhooks buffer fifo
#             }
#         }"
#     }
# }
# 
# hook global WinSetOption filetype=crystal-run %{
#     hook buffer -group crystal-run-hooks NormalKey <backspace> %{ buffer %opt{_crystalrun_origin_bufname} }
# }
# 
# hook global WinSetOption filetype=(?!crystal-run).* %{
#     rmhooks buffer crystal-run-hooks
# }
# 
# declare-option str jumpclient
# 
# define-command crystal-run-repeat -docstring 'Repeat the most recent crystal-run call' %{
#     buffer %opt{_crystalrun_origin_bufname}
#     %sh{
#         echo "crystal-run ${kak_opt__crystalrun_args}"
#     }
# }
 
# This is heavily based on crystal-spec.kak which is based on kakoune/rc/core/grep.kak.
# Differences:
# * no alternative file logic
# * higlighting of only the header line
 
declare-option str crystalruncmd 'crystal run --no-color'
declare-option str toolsclient
declare-option -hidden int _crystalrun_current_line 0

# See http://www.commandlinefu.com/commands/view/3584/remove-color-codes-runial-characters-with-sed
declare-option str stripcolorsedscript 's,\x1B\[[0-9;]*[a-zA-Z],,g'

define-command -params .. -file-completion \
    -docstring %{crystal-run [<arguments>]: crystal run command wrapper
All the optional arguments are forwarded to the crystal run command.
If no arguments are given, the current file is used as the argument.} \
    crystal-run %{
    evaluate-commands -collapse-jumps %{
        %sh{
            if [ $# -eq 0 ]; then
                if [ "${kak_bufname}" = '*crystal-run*' ]; then
                    echo crystal-run-header
                else
                    echo write
                    echo crystal-run-implementation
                fi
            else
                echo crystal-run-implementation '%arg{@}'
            fi
        }
    }
}

define-command -hidden \
    crystal-run-header %{
    try %{
        execute-keys -draft "gk<a-x>s^\Q%opt{crystalruncmd}\E ([^:\n]+)(?::(\d+))?" <ret>
        execute-keys "gk<a-x>s^\Q%opt{crystalruncmd}\E ([^:\n]+)(?::(\d+))?" <ret>
        crystal-run %reg{1}
    } catch %{
        echo -markup "{Error}failed to find and execute leading crystal run command"
    }
}

define-command -hidden \
    -params .. -file-completion \
    crystal-run-implementation %{
    %sh{
        if [ $# -gt 0 ]; then
            escaped_args='"$@"'
        else
            escaped_args='"${kak_bufname}"'
        fi
        output=$(mktemp -d -t kak-crystal-run.XXXXXXXX)/fifo
        mkfifo ${output}
        (
          {
              eval echo '${kak_opt_crystalruncmd}' "$escaped_args"
              eval echo
              eval '${kak_opt_crystalruncmd}' "$escaped_args" | sed "${kak_opt_stripcolorsedscript}" | tr -d '\r'
          } > ${output} 2>&1
        ) > /dev/null 2>&1 < /dev/null &
        printf %s\\n "evaluate-commands -try-client '$kak_opt_toolsclient' %{
            edit! -fifo ${output} -scroll *crystal-run*
            set-option buffer filetype crystal-run
            set-option buffer _crystalrun_current_line 0
            hook -group fifo buffer BufCloseFifo .* %{
                nop %sh{ rm -r $(dirname ${output}) }
                rmhooks buffer fifo
            }
        }"
    }
}

hook -group crystal-run-highlight global WinSetOption filetype=crystal-run %{
    add-highlighter shared group crystal-run
    add-highlighter shared/crystal-run regex "^crystal run( \\S+)*" 1:cyan
    add-highlighter shared/crystal-run line 1 default+b
}

hook -group crystal-run-highlight global WinSetOption filetype=(?!crystal-run).* %{ remove-highlighter window/crystal-run }

define-command crystal-run-repeat -docstring 'Repeat the most recent crystal-run call' %{
    evaluate-commands -collapse-jumps -try-client %opt{toolsclient} %{
        buffer '*crystal-run*'
        crystal-run-header
    }
}
