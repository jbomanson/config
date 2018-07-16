#===============================================================================
#               Modes
#===============================================================================

define-command -hidden client-mode %{
  info -title "Use the current client %val{client} as the" "
    j: jumpclient which currently is \"%opt{jumpclient}\"
    t: toolsclient which currently is \"%opt{toolsclient}\"
  "
  on-key %{ %sh{
    case $kak_key in
      ('j') echo "set-option global jumpclient %val{client}" ;;
      ('t') echo "set-option global toolsclient %val{client}" ;;
    esac
  } }
}

# define-command -hidden find-mode %{
#   info -title "Do a character based find action" "
#     l: Find the last instance of a character on the line
#   "
#   on-key %{ %sh{
#     case $kak_key in
#       ('l') echo "set-option global jumpclient %val{client}" ;;
#     esac
#   } }
# }

define-command -hidden general-mode %(
  info -title "Do a general operation" "
    a:   Swap pragmatically chosen selection parts
    m:   Use camel case naming style
    d:   Use dash naming style
    o:   Use command line option naming style
    u,_: Use underscore naming style
    U:   Use all capital underscore naming style
    z:   Capitalize selection
  "
  on-key %( %sh(
    case $kak_key in
      ('a')       echo swap pragmatic ;;
      ('d')       echo standard-editor name dash ;;
      ('m')       echo standard-editor name camel_case ;;
      ('o')       echo standard-editor name option ;;
      ('u' | '_') echo standard-editor name underscore ;;
      ('U')       echo standard-editor name underscore
                  echo execute-keys "~" ;;
      ('z')       echo standard-editor name capitalize ;;
    esac
  ) )
)

define-command -hidden linewise-mode %(
  info -title "Do an operation linewise" "
    d: Delete prefixes
    i: Insert prefixes
    s: Select by prefixes
  "
  on-key %( %sh(
    case $kak_key in
      ('d') echo unprefix-nearby-lines-mode ;;
      ('i') echo prefix-lines-mode ;;
      ('s') echo select-nearby-mode ;;
    esac
  ) )
)

define-command -hidden system-clipboard-mode %(
  info -title "Do a system clipboard operation" "
    c,y:   Yank the selection to the clipboard
    p:     Insert clipboard contents after the selection
    P:     Insert clipboard contents before the selection
    v,R,|: Replace the selection with clipboard contents
  "
  on-key %( %sh(
    case $kak_key in
      ('c' | 'y') echo "execute-keys %(<a-|>xclip -in -selection clipboard<ret>)" ;;
      ('p') echo "execute-keys %(<a-!>xclip -out -selection clipboard<ret>)" ;;
      ('P') echo "execute-keys %(!xclip -out -selection clipboard<ret>)" ;;
      ('v' | 'R' | '|') echo "util-pipe xclip -out -selection clipboard" ;;
    esac
  ) )
)

define-command -hidden tmux-clipboard-mode %(
  info -title "Do a tmux buffer(=clipboard) operation" "
    c,y:   Yank the selection to the clipboard
    p:     Insert clipboard contents after the selection
    P:     Insert clipboard contents before the selection
    v,R,|: Replace the selection with clipboard contents
  "
  on-key %( %sh(
    case $kak_key in
      ('c' | 'y') echo "execute-keys %(<a-|>tmux load-buffer -<ret>)" ;;
      ('p') echo "execute-keys %(<a-!>tmux show-buffer<ret>)" ;;
      ('P') echo "execute-keys %(!tmux show-buffer<ret>)" ;;
      ('v' | 'R' | '|') echo "util-pipe tmux show-buffer" ;;
    esac
  ) )
)

define-command repl-related-mode \
    -hidden \
    %{
    info -title %{Do the following with the selection and/or the repl pane} %{
    |: send text to the repl pane and capture and convert the output
    f: convert from shell output format to input format
    e: evaluate text in the repl pane
    p: evaluate paragraph in the repl pane
    R: replace the selection with current tmux repl pane contents
    x: send text to the repl pane, capture the output, convert it, step over it
    }
    on-key %{ %sh{
        case $kak_key in
            ('|') echo tmux-send-and-capture ;;
            ('f') echo convert-shell-output-to-input ;;
            ('e') echo send-text ;;
            ('p') echo send-text-paragraph ;;
            ('R') echo tmux-capture-pane ;;
            ('x') echo tmux-shell-step ;;
        esac
    }
}}

#===============================================================================
#               Edit commands with helpful completion candidates
#===============================================================================

# See https://github.com/mawww/kakoune/wiki/Fuzzy-finder#git
define-command git-edit \
    -params 1 \
    -shell-candidates %{ git ls-files } \
    -docstring %{Open the given filename in a buffer.} \
    %{ edit %arg{1} }

# See https://github.com/mawww/kakoune/issues/655
define-command find-edit \
    -params 1 \
    -shell-candidates %{ find . -type f } \
    -docstring %{Open the given filename in a buffer.} \
    %{ edit %arg{1} }

define-command extension-edit \
    -params 1 \
    -shell-candidates %{ ag -U -g '.*\Q.'"${kak_bufname##*.}"'\E' } \
    -docstring %{Open the given filename in a buffer.
The completion suggests files with the extension of the current file.} \
    %{ edit %arg{1} }

alias global ee extension-edit

# NOTE: This failed after some kak update.
# NOTE2: I may have fixed the error, and if so, it had nothing to do with a
# kak update.
define-command extension-edit-extended \
    -params 1 \
    -shell-candidates %{
        ruby -e '
            x = ARGV.
                shift.
                split(":").
                map { |file| File.extname(file)[1..-1] }.
                select { |suffix| suffix && !suffix.empty? }.
                sort.
                uniq.
                map { |suffix| Regexp.escape(suffix) }.
                join("|")
            exec("ag", "-U", "-g", "\.(#{x})$")
        ' "$kak_buflist"
      } \
    -docstring %{Open the given filename in a buffer.
The completion suggests files with the extension of any opened buffer.} \
    %{ edit %arg{1} }

alias global eee extension-edit-extended

# NOTE 2018-05-21: This returns files in subdirectories, which is against my
# intuition that the number of path components should not change.
# I am uncertain on whether ag is the right tool for this.
# TODO: Restrict the search to min and max depths based on the number of path
# components.
#
# Sketch for an alternative:
#
#     kak_buffile=one/two/three.txt
#     re='[^/]+/two[^/]*/three[^/]*\.txt[^/]*|one[^/]*/[^/]+/three[^/]*\.txt[^/]*|one[^/]*/two[^/]*/[^/]+\.txt[^/]*|one[^/]*/two[^/]*/three[^/]*\.[^/]+'
#     depth=3
#     find <something> -maxdepth "$depth" -regextype egrep -iregex "$re"
#
#     TODO: Prune directories that differ in up to two path components.
#     IDEA: The general re could be modified to allow this by allowing the path
#     to end early after certain path components.
#
#     From man find on -path: To skip directory ./src/emacs, use:
#                        find . -path ./src/emacs -prune -o -print
#
define-command manhattan-edit \
    -params 1 \
    -shell-candidates %{
        IFS=/.
        join_pattern=
        join_delimiter=
        for star_part in $kak_bufname
        do
            branch_pattern=
            branch_delimiter=
            for other_part in $kak_bufname
            do
                if test $star_part = $other_part; then
                    branch_part="[^$IFS]+"
                else
                    branch_part="\Q$other_part\E"
                fi
                branch_pattern=$branch_pattern$branch_delimiter$branch_part
                branch_delimiter=.
            done
            join_pattern="$join_pattern$join_delimiter$branch_pattern"
            join_delimiter="|"
        done
        ag -U -g "$join_pattern"
    } \
    -docstring %{Open the given filename in a buffer.
The filename completion suggests files that differ from the current file in
exactly one pathname component or in the filename extension.} \
    %{ edit %arg{1} }

alias global me manhattan-edit

# TODO: Combine this with manhattan-edit and add a configurable suffix pattern or delimiter option.
define-command manhattan-edit-extended \
    -params 1 \
    -shell-candidates %{
        IFS=/.
        join_pattern=
        join_delimiter=
        for star_part in $kak_bufname
        do
            branch_pattern=
            branch_delimiter=
            for other_part in $kak_bufname
            do
                if test $star_part = $other_part; then
                    branch_part="[^$IFS]+"
                else
                    branch_part="\Q$other_part\E[^$IFS]*"
                fi
                branch_pattern=$branch_pattern$branch_delimiter$branch_part
                branch_delimiter=.
            done
            join_pattern="$join_pattern$join_delimiter$branch_pattern"
            join_delimiter="|"
        done
        ag -U -g "$join_pattern"
    } \
    -docstring %{Open the given filename in a buffer.
The filename completion suggests files that may differ from the currently file
* in exactly one pathname component or in the filename extension and
* by having any suffixes after pathname components or the filename extension.} \
    %{ edit %arg{1} }

alias global mee manhattan-edit-extended

define-command prototype-sentence-candidates \
    -params .. \
    -shell-candidates %(
        echo one two three
        echo here and there
    ) \
    -docstring %(Echo the first argument) \
    %(
        echo %arg(1)
    )

define-command ag-edit \
    -params 2 \
    -shell-candidates %(
        {
            if test $# -eq 2; then
                ${kak_opt_grepcmd} "$1" | tr --squeeze-repeats ' ' '.'
            fi
        }
    ) \
    -docstring %(Skip an argument and edit the given file:line:column.) \
    %(
        edit %sh(echo "$2" | cut --delimiter=: --output-delimiter=' ' -f1-3)
    )

alias global ae ag-edit

define-command prototype-specific-edit-candidates \
    -params 1 \
    -shell-candidates %(
        {
            echo "stock/core/doc.kak:124:20:    -shell-candidates %{"
            echo "stock/core/doc.kak:130:17:                awk '"
        } | tr ' ' '.'
    ) \
    -docstring %(Edit the given file:line:column.) \
    %(
        edit %sh(echo "$1" | cut --delimiter=: --output-delimiter=' ' -f1-3)
    )

# A command that always suggests the previous argument.
define-command prototype-repetitive-candidates \
    -params .. \
    -shell-candidates %(
        if test $# -ge 2; then
            eval "echo \$$(expr $# - 1)"
        fi
    ) \
    -docstring %(Echo all arguments) \
    %(
        echo %arg(@)
    )

#===============================================================================
#               .
#===============================================================================

define-command goto-file-relative \
    -docstring %{Go to the selected file interpreted relative to the current file} \
    %{
        goto-file-relative-almost
        execute-keys a<backspace><tab> <ret>
    }

define-command goto-file-relative-almost \
    %{
        execute-keys -save-regs ab '"ay' ':reg b <c-r>%' <ret> ':edit -scratch goto-file-relative' <ret> '"bp' <a-t> / '"aR' xH '"ay' :db! <ret> ':edit <c-r>a'
    }

#===============================================================================
#               .
#===============================================================================

#
# Colorscheme changes
#

# colorscheme base16	# A good dark colourscheme with excellent visibility.
# colorscheme github	# A very nice bright colourscheme that fails inside xterm.

# Apply a colorscheme based on the hour.
define-command colorscheme-by-hour \
    -docstring "Pick a colorscheme based on the hour" %{
    %sh{
        if [ $(date +%H) -lt 21 ]; then
            echo 'colorscheme github';
        else
            echo 'colorscheme lucius';
        fi
    }
}

# colorscheme-by-hour

# Hour value used to avoid calling colorscheme-by-hour too often.
declare-option str colorscheme_by_hour_hour

# A version of colorscheme-by-hour designed to be used in hooks.
define-command colorscheme-by-hour-rate-limited \
    -hidden \
    %{
        %sh{
            previous_hour="$kak_opt_colorscheme_by_hour_hour";
            current_hour="$(date +%H)";
            if test "$previous_hour" != "$current_hour"; then
                echo set-option global colorscheme_by_hour_hour "$current_hour";
                if test "$current_hour" -gt 6 -a "$current_hour" -lt 21; then
                    echo 'colorscheme github';
                else
                    echo 'colorscheme lucius';
                fi;
            fi
        }
    }

#
#
#

define-command convert-shell-output-to-input \
    -docstring %(Convert shell input and output such as
    host /path/directory> echo Abc
    abc
into
    echo Abc
    # abc) \
    %(
        with-preserved-indentation evaluate-commands %(
            # Convert output lines.
            try %( execute-keys -draft %(<a-x><a-s>Z<a-K><gt> <ret>ghi# <esc>) )
            # Convert input lines.
            try %( execute-keys -draft %(<a-x><a-s>Zz<a-k><gt> <ret>ghf<gt>Ld) )
        )
    )

declare-option str evaluate_on_register_id "evaluate-on-register"

define-command -override evaluate-on-register \
    -params 2 \
    -docstring "evaluate-on-register <register> <commands>: Evaluate <commands>
with the contents of <register> selected in a temporary buffer." \
    %(
        evaluate-commands -draft -save-regs "" %(
            set-option global evaluate_on_register_id %sh(
                echo "$kak_opt_evaluate_on_register_id" | md5sum | head -c32
            )
            edit! -scratch "*%opt(evaluate_on_register_id)*"
            evaluate-commands -draft -save-regs "" %(
                try %(
                    exec -save-regs "" "\"%arg(1)R\%"
                    evaluate-commands -save-regs "" "%arg(2)"
                    exec -save-regs "" "\%\"%arg(1)y"
                )
            )
            delete-buffer
        )
    )

define-command grow-selection \
    -docstring %(Grow selections above and below by one line) \
    %(
        evaluate-commands -save-regs v %(
            reg v %sh(echo $kak_count)
            execute-keys "<a-:>%reg(v)J<a-;>%reg(v)K<a-:><a-x>"
        )
    )

define-command grow-selection-above \
    -docstring %(Grow selections above by one line) \
    %(
        execute-keys "<a-:><a-;>%sh(echo $kak_count)K<a-:><a-x>"
    )

define-command grow-selection-below \
    -docstring %(Grow selections below by one line) \
    %(
        execute-keys "<a-:>%sh(echo $kak_count)J<a-x>"
    )

define-command -hidden prefix-lines-mode %(
  info -title %(Prefix lines) %(
    c: Prefix lines with comment markers
    #: Prefix lines with #
    %: Prefix lines with %
  )
  on-key %( %sh{
    case $kak_key in
      ('c') echo prefix-lines "'$kak_opt_comment_line '" ;;
      ('#') echo prefix-lines "'# '" ;;
      ('%') echo prefix-lines "'% '" ;;
    esac
  }
))

define-command prefix-lines \
  -docstring %(prefix-lines <string>: Prefix each line with <string>) \
  -params 1 \
  %(
      execute-keys "Z<a-s>ghi%arg(1)<esc>z<a-x>"
  )

define-command prefix-lines-smart \
  -docstring %(prefix-lines-if-necessary <prefix>: Prefix selected lines
with <string> unless all of them already are prefixed.) \
  -params 1 \
  %(
      evaluate-commands -itersel %(
          try %(
              execute-keys "<a-x><a-k>^\\s*[^\\s%sh(echo $1)]<ret>"
              prefix-lines %arg(1)
          )
      )
  )

define-command standard-editor \
    -params .. \
    -docstring "Run standard_editor <arguments> on each selection" \
    %(
        evaluate-commands -itersel %(
            util-pipe standard_editor %arg(@)
        )
    )

define-command swap \
    -params 1 \
    -docstring "Run standard_editor swap <argument>" \
    %(
        util-pipe standard_editor swap "%arg(1)"
    )

define-command standard-editor-list-indent \
    -params 1 \
    -docstring "Run standard_editor list_indent --amount <argument>" \
    %(
        standard-editor list_indent --amount %arg(1)
    )

define-command unprefix-lines \
  -docstring %(unprefix-lines <string>: Remove prefix <string> from each line) \
  -params 1 \
  %(
      execute-keys -draft "<a-x>s^\s*\Q%arg(1)\E<ret>s\Q%arg(1)\E<ret>d"
  )

define-command -hidden unprefix-nearby-lines-mode %{
  info -title %{Unprefix lines starting with} %{
    a: a heuristically chosen prefix
    c: the comment prefix
    #: the string #
    %: the string %
    .: the current selection
  }
  on-key %{ %sh{
    case $kak_key in
      ('a') echo unprefix-nearby-lines-heuristic ;;
      ('c') echo unprefix-nearby-lines "'$kak_opt_comment_line '" ;;
      ('#') echo unprefix-nearby-lines "'# '" ;;
      ('%') echo unprefix-nearby-lines "'% '" ;;
      ('.') echo unprefix-nearby-lines "%reg(.)" ;;
    esac
  }
}}

define-command unprefix-nearby-lines \
  -docstring %(Unprefix nearby lines starting with a given string) \
  -params 1 \
  %(
      evaluate-commands -draft %(
          select-nearby-lines-by-prefix %arg(1)
          unprefix-lines %arg(1)
      )
  )

define-command unprefix-nearby-lines-heuristic \
    -docstring %(Unprefix nearby lines sharing a heuristically chosen prefix) \
    %(
        try %(
            evaluate-commands -save-regs t %(
                execute-keys -draft %(<space><a-x>s^\s*\S+\s<ret>"ty)
                unprefix-nearby-lines %reg(t)
            )
        ) catch %(
            echo -markup '{Error}Failed to choose a prefix'
        )
    )

define-command -hidden select-nearby-mode %{
  info -title %{Select nearby lines prefixed by} %{
    a: a heuristically chosen prefix
    c: the comment prefix
    #: the string #
    %: the string %
    .: the current selection
  }
  on-key %{ %sh{
    case $kak_key in
      'a') echo select-nearby-lines-by-prefix-heuristic ;;
      'c') echo select-nearby-lines-by-prefix "'$kak_opt_comment_line'" ;;
      '#') echo select-nearby-lines-by-prefix "'#'" ;;
      '%') echo select-nearby-lines-by-prefix "'%'" ;;
      '.') echo select-nearby-lines-by-prefix "%reg(.)" ;;
    esac
  }
}}

define-command select-nearby-lines-by-prefix \
    -docstring %(Select nearby lines starting with a given string) \
    -params 1 \
    %(
        select-nearby-lines "^\s*\Q%arg(1)\E"
    )

define-command select-nearby-lines-by-prefix-heuristic \
    -docstring %(Select nearby lines sharing a heuristically chosen prefix) \
    %(
        try %(
            evaluate-commands -save-regs t %(
                execute-keys -draft %(<space><a-x>s^\s*\S+\s<ret>"ty)
                select-nearby-lines-by-prefix %reg(t)
            )
        ) catch %(
            echo -markup '{Error}Failed to choose a prefix'
        )
    )

define-command select-nearby-lines \
    -docstring %{select-nearby-lines <string>: Select nearby lines containing <string>} \
    -params 1 \
    %(
        evaluate-commands -save-regs jbwkl %(
            try %(
                execute-keys -draft %("jZ<a-i>p<a-s>"lZ<a-k>) %arg{1} %(<ret>)
                execute-keys %("lz<a-K>) %arg{1} %(<ret><a-m>H"kd"bZ"jz<a-i>p"wZ"bzaa<esc>h"kR"wz)
                echo
            ) catch %(
                echo -markup '{Error}Failed to select lines matching %arg{1}'
            )
        )
    )

# NOTE: See ../kakrc and "map global object ..." commands.
define-command -hidden select-custom-text-object-whole-mode %{
  info -title %{Select whole custom text object} %{
    i: indent and some
  }
  on-key %{ %sh{
    case $kak_key in
      'i') echo select-indent-and-some-whole ;;
    esac
  }
}}

# NOTE: See ../kakrc and "map global object ..." commands.
define-command -hidden select-custom-text-object-inner-mode %{
  info -title %{Select inner custom text object} %{
    i: indent and some
  }

  on-key %{ %sh{
    case $kak_key in
      'i') echo execute-keys "'<a-i>i<a-;>K<a-;><a-x>X'" ;;
    esac
  }
}}

# TODO: Make this work when the selection is at the end of the intended
# selection.
# TODO: Make this work when the selection is separated by a blank line from the
# intended selection beginning. EDIT: This may be infeasible.
define-command select-paragraph-and-indent \
    %(
        evaluate-commands %(
            execute-keys -save-regs '' 'Z<a-i>p<a-;>;"qZ'
            set-register dquote ''
            try %( execute-keys -save-regs '' '<a-i><space>y' )
            try %(
                execute-keys -draft 'z?^<c-r>"\s.*?^<c-r>"\S.*?\n<ret>"q<a-z>u'
                execute-keys 'z?^<c-r>"\s.*?^<c-r>"\S.*?\n<ret>"q<a-z>u'
            )
        )
    )

define-command -hidden select-indent-and-some-whole %{
    execute-keys '<a-a>i<a-;>K<a-;><a-x>X'
    evaluate-commands -save-regs ^ %{
        try %{
            execute-keys -save-regs %{} 'Z;/\A\n+<ret><a-z><a-m>'
        } catch %{
            execute-keys z
            echo
        }
    }
}

define-command send-text-paragraph \
    -hidden \
    -docstring "Send paragraph to the repl pane" \
    %(
        evaluate-commands -draft -itersel %(
            execute-keys <a-i>p
            send-text
        )
    )

# This is slightly complex because there are three special cases that need to
# be taken care of.
# 1. The file ends in a newline.
# 2. The file ends in a non-newline character.
# 3. The file is empty.
define-command set-register-to-file \
    -params 2 \
    -docstring "set-register-to-file <name> <file>: set-option register <name> to the contents of <file> on disk" \
    %(
        %sh(
            file="$2"
            if test -r "$file"; then
                if test -s "$file"; then
                    # The file is not empty.
                    if test $(tail -c1 "$file" | wc -l) -gt 0; then
                      # The file ends in a newline.
                      # It is OK to open it in this case.
                      printf %s\\n 'set-register-to-file-newline "%arg(1)" "%arg(2)"'
                    else
                      # The file does not end in a newline.
                      # It appears to be safe to use %sh(...) in this case.
                      printf %s\\n 'set-register "%arg(1)" "%sh(cat \"$2\")"'
                    fi
                else
                    # The file is empty.
                    printf %s\\n 'set-register "%arg(1)" ""'
                fi
            else
                # The file is not available for reading.
                printf %s\\n 'set-register "%arg(1)" ""'
                printf %s\\n "Failed to read file '$file'" >&2
            fi
        )
    )

declare-option -hidden str set_register_to_file_newline_tmp

# This command handles case 1. of set-register-to-file.
define-command set-register-to-file-newline \
    -hidden \
    -params 2 \
    -docstring "set-register-to-file-newline <name> <file>: set-option register <name> to the contents of <file> on disk" \
    %(
        evaluate-commands -draft -save-regs "" %(
          edit! -scratch *set-register-to-file-newline*
          execute-keys "!cat '%arg(2)'<ret>"
          evaluate-commands %(
              execute-keys -save-regs '' "<a-/>.<ret>GGy"
              set-option global set_register_to_file_newline_tmp %reg(dquote)
          )
          set-register "%arg(1)" "%opt(set_register_to_file_newline_tmp)"
          # execute-keys -save-regs '' "<a-/>.<ret>GG\"%arg(1)y"
          delete-buffer *set-register-to-file-newline*
        )
    )

# BUG: The obtained value will always end in a newline.
define-command set-register-to-file-no-remove \
    -params 2 \
    -docstring %(set-register-to-file-no-remove <name> <file>: set-option register <name> to the contents
of <file> on disk) \
    %{
        %sh{
            name="$1"
            file="$2"
            printf %s\\n "evaluate-commands -draft -save-regs '' %{
                edit! -debug "$file"
                execute-keys -save-regs '' '%\"${name}y'
                delete-buffer! "$file"
            }"
        }
    }

define-command wrap-sentence \
    %(
        try %(
            execute-keys 'gif.,w;L<a-k><space><ret>;r<ret>'
        )
        execute-keys 'jgi'
    )

declare-option \
    -docstring %(A string of characters allowed only in leading prefixes.) \
    str \
    wrap_with_ruby_scarce \
    '-*'

# TODO: Either use <a-x> in the beginning or do some clever tricks with the part
# of the selection that is on the first line when that line is not completely
# selected.
define-command wrap-with-ruby \
    %(
        evaluate-commands %(
            %sh(
                output=$(mktemp -d -t wrap-with-ruby.XXXXXXXX)/file
                ruby -e '
                    lines = ARGV.shift.each_line.to_a
                    width = ARGV.shift.to_i
                    scarce = ARGV.shift
                    output = ARGV.shift
                    prefix = lines.first[/[[:punct:][:space:]]*/]
                    secondary_prefix = prefix.tr(scarce, " ")
                    width -= prefix.size
                    lines.each do |line|
                        if line.start_with? prefix
                            line.slice!(0...prefix.size)
                        end
                        line.chomp!
                    end
                    string = lines.join(" ")
                    # Reference: https://www.ruby-forum.com/topic/57805#46911
                    lines = string.scan(/.{0,#{width - 1}}\S(?=\s|$)|\S+/)
                    lines.each_with_index do |line, index|
                        line.strip!
                        line.insert(0, index == 0 ? prefix : secondary_prefix)
                    end
                    File.open(output, "a") { |io| io.puts lines }
                ' \
                    -- \
                    "$kak_selection" \
                    "$kak_opt_autowrap_column" \
                    "$kak_opt_wrap_with_ruby_scarce" \
                    "$output"
                if test $? -eq 0; then
                    echo set-register-to-file dquote "$output"
                    echo "nop %sh( rm -r \$(dirname ${output}) )"
                    echo execute-keys R
                else
                    echo "nop %sh( rm -r \$(dirname ${output}) )"
                    echo echo -markup "{Error}Error in wrap-with-ruby"
                fi
            )
        )
    )

define-command write-make \
    -docstring %(Write and make) \
    -params .. \
    %(
        write
        make %arg(@)
    )

alias global wmake write-make

# # NOTE: Use %val(modified) to detect if the buffer has been saved or not.
# 
# define-command write-maybe \
#     -docstring %(Write or do not write) \
#     %(
#         %sh(
#             exit
#             sleep 1
# #             test "$kak_opt_readonly" = false         || exit
# #             test "$kak_opt_write_maybe_allow" = true || exit
# #             test -f "$kak_buffile"                   || exit
#             echo echo -debug "$kak_buffile ($?)"
#         )
#     )
# 
# declare-option bool write_maybe_allow false
# hook global NormalIdle .* %( write-maybe )
# 
# # define-command write-maybe-enable -params 1 -docstring "Activate automatic writing to disk"
# # define-command write-maybe-disable
# 
# # define-command lint-enable -docstring "Activate automatic diagnostics of the code" %{
# #     add-highlighter flag_lines default lint_flags
# #     hook window -group lint-diagnostics NormalIdle .* %{ lint-show }
# # }
# #
# # define-command lint-disable -docstring "Disable automatic diagnostics of the code" %{
# #     remove-highlighter hlflags_lint_flags
# #     remove-hooks window lint-diagnostics
# # }
# 
# # :hook [-group <group>] <scope> <hook_name> <filtering_regex> <commands>
# # NormalIdle: A certain duration has passed since last key was pressed in normal mode.
# # BufWritePost: Executed just after a buffer is written, filename is used for filtering.
# # BufOpenFile: A buffer for an existing file has been created, filename is used for filtering
# # %opt(readonly) => false/true

declare-option -hidden str select_def_end_selection

define-command select-def-end \
    %(
        set-option global select_def_end_selection "%val(selections_desc)"
        execute-keys '%'
        %sh(
            args="select 'def' 'end' '$kak_opt_select_def_end_selection'"
            cmd="printf %s\\n \"\$kak_selection\" | standard_editor $args"
            if value=$(eval $cmd); then
                echo "select $value"
            else
                echo "fail Failed to execute shell command $cmd"
            fi
        )
    )
