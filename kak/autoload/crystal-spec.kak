# This is based on kakoune/rc/core/grep.kak.

declare-option str crystalspeccmd 'crystal spec --no-color'
# declare-option str crystalspeccmd 'crystal spec --no-color --debug'
declare-option str toolsclient
declare-option -hidden int _crystalspec_current_line 0

# See http://www.commandlinefu.com/commands/view/3584/remove-color-codes-special-characters-with-sed
declare-option str stripcolorsedscript 's,\x1B\[[0-9;]*[a-zA-Z],,g'

# TODO: "Undo" the jump to the alternative file.
# The current behaviour is annoying when a jump client other than the current
# pane is used.
define-command -params .. -file-completion \
    -docstring %{crystal-spec [<arguments>]: crystal spec command wrapper
All the optional arguments are forwarded to the crystal spec command.
If no arguments are given, an attempt is made to heuristically pick a crystal
spec file to be the target of the command.} \
    crystal-spec %{
    evaluate-commands -collapse-jumps %{
        %sh{
            if [ $# -eq 0 ]; then
                if [ "${kak_bufname}" = '*crystal-spec*' ]; then
                    echo crystal-spec-header
                else
                    echo write
                    echo crystal-spec-alternative-file
                    echo write
                    echo crystal-spec-implementation
                fi
            else
                echo crystal-spec-implementation '%arg{@}'
            fi
        }
    }
}

define-command -hidden \
    crystal-spec-header %{
    try %{
        execute-keys -draft "gk<a-x>s^\Q%opt{crystalspeccmd}\E ([^:\n]+)(?::(\d+))?" <ret>
        execute-keys "gk<a-x>s^\Q%opt{crystalspeccmd}\E ([^:\n]+)(?::(\d+))?" <ret>
        crystal-spec %reg{1}
    } catch %{
        echo -markup "{Error}failed to find and execute leading crystal spec command"
    }
}

define-command -hidden \
    -params .. -file-completion \
    crystal-spec-implementation %{
    %sh{
        if [ $# -gt 0 ]; then
            escaped_args='"$@"'
        else
            escaped_args='"${kak_bufname}"'
        fi
        output=$(mktemp -d -t kak-crystal-spec.XXXXXXXX)/fifo
        mkfifo ${output}
        (
          {
              eval echo '${kak_opt_crystalspeccmd}' "$escaped_args"
              eval echo
              eval '${kak_opt_crystalspeccmd}' "$escaped_args" | sed "${kak_opt_stripcolorsedscript}" | tr -d '\r'
          } > ${output} 2>&1
        ) > /dev/null 2>&1 < /dev/null &
        printf %s\\n "evaluate-commands -try-client '$kak_opt_toolsclient' %{
            edit! -fifo ${output} -scroll *crystal-spec*
            set-option buffer filetype crystal-spec
            set-option buffer _crystalspec_current_line 0
            hook -group fifo buffer BufCloseFifo .* %{
                nop %sh{ rm -r $(dirname ${output}) }
                rmhooks buffer fifo
            }
        }"
    }
}

hook -group crystal-spec-highlight global WinSetOption filetype=crystal-spec %{
    add-highlighter window group crystal-spec-highlight
    add-highlighter window/crystal-spec-highlight regex "^(?:(?:[^\n]* )?in (?:macro '[^']*' )?)?((?:\w:)?[^:\n]+):(\d+)[:,]" 1:cyan 2:green
    add-highlighter window/crystal-spec-highlight regex "^crystal spec ([^:\n]+):(\d+)" 1:cyan 2:green
    add-highlighter window/crystal-spec-highlight regex "^\Q%opt{crystalspeccmd}\E ([^:\n]+)(?::(\d+))?" 1:cyan 2:green
    # add-highlighter window/crystal-spec-highlight regex "^crystal spec ([^:\n]+)(?::(\d+))?" 1:cyan 2:green
    # add-highlighter window/crystal-spec-highlight regex "^crystal spec ([^:\n]+)" 1:cyan 2:green
    add-highlighter window/crystal-spec-highlight regex "^\s+(?:#\s+)?0x.{6}: [^\n]* at ([^:\n]+) (\d+):(\d+)" 1:cyan 2:green 3:green
    add-highlighter window/crystal-spec-highlight regex "^     # ([^:\n]+):(\d+)" 1:cyan 2:green
    add-highlighter window/crystal-spec-highlight regex "^  ([^:\n]+):(\d+)" 1:cyan 2:green
    add-highlighter window/crystal-spec-highlight line %{%opt{_crystalspec_current_line}} default+b
    add-highlighter window/crystal-spec-highlight regex "^\h*\^~*$" 0:red
    # The following is too much.
    # add-highlighter window/crystal-spec-highlight regex "^       [^\n]*" 0:red
    add-highlighter window/crystal-spec-highlight regex "(?:(?<=[EF])|^)\.+(?:(?=[EF])|$)" 0:green
    add-highlighter window/crystal-spec-highlight regex "(?:(?<=\.)|^)(?:E|F)+(?:(?=\.)|$)" 0:red
}

hook -group crystal-spec-highlight global WinSetOption filetype=(?!crystal-spec-highlight).* %{ remove-highlighter window/crystal-spec-highlight }

hook global WinSetOption filetype=crystal-spec %{
    hook buffer -group crystal-spec-hooks NormalKey <ret> crystal-spec-jump
    map buffer user -docstring "Do a crystal specific operation" g %(:crystal-mode<ret>)
}

hook global WinSetOption filetype=(?!crystal-spec).* %{
    rmhooks buffer crystal-spec-hooks
}

define-command crystal-spec-alternative-file -docstring 'Jump to the test file' %{ %sh{
    case $kak_buffile in
        *spec/*_spec.cr)
            exit
        ;;
        *src/*.cr)
            altfile=$(eval echo $(echo $kak_buffile | sed s+src/+spec/+';'s/.cr'$'/_spec'\0'/))
            [ ! -f $altfile ] && echo "echo -markup '{Error}found no spec file $altfile'" && exit
        ;;
        *)
            echo "echo -markup '{Error}failed to determine alternative file'" && exit
        ;;
    esac
    echo "edit %($altfile)"
}}

declare-option str jumpclient

define-command -hidden crystal-spec-jump %{
    evaluate-commands -collapse-jumps %{
        try %{
            reg 3 ""
            try %{
                execute-keys -draft "xs^(?:(?:[^\n]* )?in (?:macro '[^']*' )?)?((?:\w:)?[^:\n]+):(\d+)[:,]<ret>"
                execute-keys "xs^(?:(?:[^\n]* )?in (?:macro '[^']*' )?)?((?:\w:)?[^:\n]+):(\d+)[:,]<ret>"
            } catch %{ try %{
                execute-keys -draft 'xs^crystal spec ([^:\n]+):(\d+)<ret>'
                execute-keys "xs^crystal spec ([^:\n]+):(\d+)<ret>"
            } catch %{ try %{
                execute-keys -draft "xs^\Q%opt{crystalspeccmd}\E ([^:\n]+)(?::(\d+))?<ret>"
                execute-keys "xs^\Q%opt{crystalspeccmd}\E ([^:\n]+)(?::(\d+))?<ret>"
            } catch %{ try %{
                execute-keys -draft 'xs^\s+(?:#\s+)?0x.{6}: [^\n]* at ([^:\n]+) (\d+):(\d+)<ret>'
                execute-keys "xs^\s+(?:#\s+)?0x.{6}: [^\n]* at ([^:\n]+) (\d+):(\d+)<ret>"
            } catch %{ try %{
                execute-keys -draft 'xs^     # ([^:\n]+):(\d+)<ret>'
                execute-keys "xs^     # ([^:\n]+):(\d+)<ret>"
            } catch %{
                execute-keys -draft "xs^  ([^:\n]+):(\d+)<ret>"
                execute-keys "xs^  ([^:\n]+):(\d+)<ret>"
            } } } } }
            set-option buffer _crystalspec_current_line %val{cursor_line}
            evaluate-commands -try-client %opt{jumpclient} edit -existing %reg{1} %reg{2} %reg{3}
            try %{ focus %opt{jumpclient} }
        }
    }
}

define-command crystal-spec-next -docstring 'Jump to the next crystal-spec match' %{
    evaluate-commands -collapse-jumps -try-client %opt{jumpclient} %{
        buffer '*crystal-spec*'
        execute-keys "%opt{_crystalspec_current_line}g<a-l>/^[^:]+:\d+:<ret>"
        crystal-spec-jump
    }
    try %{ evaluate-commands -client %opt{toolsclient} %{ execute-keys %opt{_crystalspec_current_line}g } }
}

define-command crystal-spec-prev -docstring 'Jump to the previous crystal-spec match' %{
    evaluate-commands -collapse-jumps -try-client %opt{jumpclient} %{
        buffer '*crystal-spec*'
        execute-keys "%opt{_crystalspec_current_line}g<a-/>^[^:]+:\d+:<ret>"
        crystal-spec-jump
    }
    try %{ evaluate-commands -client %opt{toolsclient} %{ execute-keys %opt{_crystalspec_current_line}g } }
}

define-command crystal-spec-repeat -docstring 'Repeat the most recent crystal-spec call' %{
    evaluate-commands -collapse-jumps -try-client %opt{toolsclient} %{
        buffer '*crystal-spec*'
        crystal-spec-header
    }
}
