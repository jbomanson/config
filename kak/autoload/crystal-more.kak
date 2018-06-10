hook global WinSetOption filetype=crystal %{
    set-option window indentwidth 2
    set-option window tabstop 2

    map buffer user -docstring "Do a crystal specific operation" g %(:crystal-mode<ret>)

    set-option window extra_word_chars \:

    hook -group crystal-tool buffer BufWritePost '.*' crystal-doc-if-exists
    hook -group crystal-tool buffer BufWritePre '.*' crystal-tool-format-file
}

#===============================================================================
#               Modes
#===============================================================================

define-command -hidden crystal-mode %{
  info -title %{Do a crystal specific operation} %{
    a: Go to alternative file
    c: Context
    f: Format selection
    g: Go to required file
    h: Look up a type in the Crystal API
    i: Implementations
    r: Run file
    s: Spec file
    S: Repeat spec
  }
  on-key %{ %sh{
    case $kak_key in
      ('a') echo crystal-alternative-file ;;
      ('c') echo crystal-tool-context ;;
      ('f') echo crystal-tool-format ;;
      ('g') echo crystal-go-to-file-relative ;;
      ('h') echo crystal-help-api ;;
      ('i') echo crystal-tool-implementations ;;
      ('r') echo crystal-run ;;
      ('s') echo crystal-spec ;;
      ('S') echo crystal-spec-repeat ;;
    esac
  } }
}

#===============================================================================

# A command designed to be called from a hook.
# This formats the current buffer without touching the filesystem. 
define-command crystal-tool-format-file \
    -docstring %(Run crystal tool format on the file) \
    %{
        evaluate-commands -save-regs v %{
            execute-keys -draft %(%"vy)
            %sh{
                if ! printf "%s" "$kak_reg_v" \
                    | crystal tool format --check - >/dev/null 2>&1
                then
                    output=$(mktemp -d -t kak-crystal-tool-format-file.XXXXXXXX)/file
                    common="
                        edit! -debug $output
                        execute-keys -save-regs '' '%\"vy'
                        delete-buffer! $output
                        nop %sh{ rm -r $(dirname ${output}) }
                    "
                    if printf "%s" "$kak_reg_v" \
                            | crystal tool format --no-color - >$output 2>&1
                    then
                        echo "evaluate-commands -collapse-jumps %{
                            $common
                            buffer '$kak_bufname'
                            execute-keys '%\"vR'
                            select '$kak_selections_desc'
                        }"
                    else
                        echo "evaluate-commands -collapse-jumps -draft %{
                            $common
                            echo \
                                -debug \
                                \"crystal-tool-format-file failure: %reg{v}\"
                        }
                        echo \
                            -markup \
                            \"{Error}crystal-tool-format-file failed:" \
                            \"see *debug* buffer for details"
                        "
                    fi
                fi
            }
        }
    }

# Timestamps used to avoid calling crystal docs twice on the same second.
declare-option -hidden str crystal_doc_if_exists_then
declare-option -hidden str crystal_doc_if_exists_now

# TODO: Write crystal docs output to a temporary file and echo it to the debug
# buffer if the command fails.
define-command crystal-doc-if-exists \
    -docstring %(Executes crystal docs on the file if a doc directory exists) \
    %{
        set-option buffer crystal_doc_if_exists_then %opt{crystal_doc_if_exists_now}
        set-option buffer crystal_doc_if_exists_now %sh{date +%T}
        nop %sh{
            if test "$kak_opt_crystal_doc_if_exists_then" \
                    != "$kak_opt_crystal_doc_if_exists_now"; then
                (
                    {
                        echo -n evaluate-commands -client $kak_client "%(" echo -debug '"'
                        if root=`echo "$kak_buffile" | sed "s_src/.*__"`; then
                            index="${root}doc/index.html"
                            if test -w "$index"; then
                                echo crystal docs '#' "$kak_buffile"
                                # Run and gather some limited amount of output.
                                if ! crystal docs 2>&1 \
                                        | head -n3 \
                                        | sed 's/".*//'; then
                                    echo '[...]'
                                    echo evaluate-commands -client $kak_client \
                                        echo -markup \
                                            "{Error}crystal-doc-if-exists failed:" \
                                            "see *debug* buffer for details" \
                                        | kak -p $kak_session >/dev/null 2>&1
                                fi
                            fi
                        fi
                        echo -n '"'
                        echo -n ")"
                    } | kak -p $kak_session >/dev/null 2>&1
                ) > /dev/null 2>&1 < /dev/null &
            fi
        }
    }

define-command crystal-go-to-file-relative \
    -docstring "Edit a double quoted relative file" \
    %(
        evaluate-commands %(
            execute-keys -draft -save-regs '' '<a-x>s"[^"]*"<ret>H<a-;>L<a-:>y'
            edit %sh(echo $(readlink -m "$kak_buffile/../$kak_reg_dquote")*.cr | tr ' ' '\n' | head -n1)
        )
    )

define-command -hidden _crystal-insert-class %{
    execute-keys %(ggIa<c-r>%<esc>xs^a(src/)?<ret>dxs\..*$<ret>dI/<esc>xs/<ret>c::<esc>~<space>ghLc_<esc>xs_.<ret>~hd<space><esc>Iclass <esc>oend<esc>)
}

define-command -hidden _crystal-replace-class-with-describe %(
    execute-keys %(ggecdescribe<esc>A<space>do<esc>xsSpec(::)?<ret>d)
)

define-command -hidden _crystal-insert-class-or-describe %(
    _crystal-insert-class
    try %(
        execute-keys %(ggxsSpec<ret>)
        _crystal-replace-class-with-describe
    )
)

hook global BufNewFile .*\.cr _crystal-insert-class-or-describe

define-command -docstring %(Comment and format selected text as an example section) \
    crystal-doc-example %(
        evaluate-commands -collapse-jumps %(
            execute-keys -draft -no-hooks 'O# ### Example<ret>#'
            crystal-doc-code
        )
    )

define-command -docstring %(Comment and format selected text as a code block) \
    crystal-doc-code %(
        evaluate-commands -collapse-jumps %(
            prefix-lines-smart '# '
            execute-keys -no-hooks '<a-x>ZO# ```<esc>zo# ```<esc>z<a-:><a-;>K<a-x>'
            crystal-tool-format
        )
    )

define-command crystal-convert-curly-braces-to-do-end %(
    try %(
        # First look for { |...| ... }.
        execute-keys -draft -save-regs q^ <a-x> '"qZ' s\{\h*\|<ret> "'" <space> Z '<a-;>' ';' cdo<esc> z l f| W s\|\h*<ret> c|<ret><esc> '"qz' s\h*\}\h*\Z<ret> c<ret>end<esc>
    ) catch %(
        # Then look for { ... }.
        execute-keys -draft -save-regs q^ <a-x> '"qZ' s\{\h*<ret> "'" <space> '<a-;>' ';' cdo<ret><esc> '"qz' s\h*\}\h*\Z<ret> c<ret>end<esc>
    )
)

define-command crystal-convert-ternary-to-if-then-else \
    -docstring %(Turn a ? b : c into
    if a
      b
    else
      c
    end) \
    %(
        execute-keys -draft %(Iif <esc><a-x>s \? <ret>' c<ret><esc><a-x>s : <ret>' c<ret><esc>Oelse<esc>joend<esc>)
    )

define-command crystal-tool-format \
    -docstring %(Run crystal tool format on the selection) \
    %(
        with-preserved-indentation execute-keys %(|crystal tool format -<ret>)
    )
