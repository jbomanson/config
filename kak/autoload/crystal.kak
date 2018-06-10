# http://crystal-lang.org
# ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾

# Detection
# ‾‾‾‾‾‾‾‾‾

hook global BufCreate .*\.cr %{
    set-option buffer filetype crystal
}

# Highlighters
# ‾‾‾‾‾‾‾‾‾‾‾‾

add-highlighter shared/ regions -default code crystal \
    double_string '"' (?<!\\)(\\\\)*"        '' \
    single_string "'" (?<!\\)(\\\\)*'        '' \
    backtick      '`' (?<!\\)(\\\\)*`        '' \
    regex         '/' (?<!\\)(\\\\)*/[imox]* '' \
    comment       '#' '$'                    '' \
    comment       ^begin= ^=end              '' \
    literal       '%[iqrswxIQRSWX]?\(' \)    \( \
    literal       '%[iqrswxIQRSWX]?\{' \}    \{ \
    literal       '%[iqrswxIQRSWX]?\[' \]    \[ \
    literal       '%[iqrswxIQRSWX]?<'   >     < \
    assign_division '(?<=define-command)\h+/' \(        '' \
    division '[\w\)\]](/|(\h+/(\h|=)\h*))' '\w' '' # Help Kakoune to better detect /…/ literals

#    def_division  '^\s*define-command /' \(             '' \

# NOTE: What is this doing here?
# add-highlighter shared/crystal/code regex \b(${keywords})\b 0:keyword

# Regular expression flags are: i → ignore case, m → multi-lines, o → only interpolate #{} blocks once, x → extended mode (ignore white spaces)
# Literals are: i → array of symbols, q → string, r → regular expression, s → symbol, w → array of words, x → capture shell result

add-highlighter shared/crystal/double_string fill string
add-highlighter shared/crystal/double_string regions regions interpolation \Q#{ \} \{
add-highlighter shared/crystal/double_string/regions/interpolation fill meta

add-highlighter shared/crystal/single_string fill string

add-highlighter shared/crystal/backtick fill meta
add-highlighter shared/crystal/backtick regions regions interpolation \Q#{ \} \{
add-highlighter shared/crystal/backtick/regions/interpolation fill meta

add-highlighter shared/crystal/regex fill meta
add-highlighter shared/crystal/regex regions regions interpolation \Q#{ \} \{
add-highlighter shared/crystal/regex/regions/interpolation fill meta

add-highlighter shared/crystal/comment fill comment

add-highlighter shared/crystal/literal fill meta

add-highlighter shared/crystal/code regex \b([A-Za-z]\w*:(?=[^:]))|([$@][A-Za-z]\w*)|((?<=[^:]):[A-Za-z]\w*[=?!]?)|([A-Z]\w*|^|\h)\K::(?=[A-Z]) 0:variable

%sh{
    # Grammar
    keywords="abstract|alias|begin|break|case|class|def|defined|delegate|do"
    keywords="${keywords}|else|elsif|end|ensure|enum|false|for|forall|fun"
    keywords="${keywords}|if|in|lib|macro|module|next|nil|pointerof"
    keywords="${keywords}|previous_def|private|protected|redo|record"
    keywords="${keywords}|rescue|retry|return|self|sizeof|struct"
    keywords="${keywords}|super|then|true|typeof|undef|unless"
    keywords="${keywords}|until|when|while|with|yield"
    attributes="getter|property"
    values="false|true|nil"
    meta="extend|include|require"

    # Add the language's grammar to the static completion list
    printf %s\\n "hook global WinSetOption filetype=crystal %{
        set-option window static_words '${keywords}:${attributes}:${values}:${meta}'
    }" | sed 's,|,:,g'

    # Highlight keywords
    printf %s "
        add-highlighter shared/crystal/code regex \b(${keywords})\b 0:keyword
        add-highlighter shared/crystal/code regex \b(${attributes})\b 0:attribute
        add-highlighter shared/crystal/code regex \b(${values})\b 0:value
        add-highlighter shared/crystal/code regex \b(${meta})\b 0:meta
    "
}

# Commands
# ‾‾‾‾‾‾‾‾

define-command crystal-alternative-file -docstring 'Jump to the alternate file (implementation ↔ test)' %{ %sh{
    case $kak_buffile in
        *spec/*_spec.cr)
            altfile=$(eval echo $(echo $kak_buffile | sed s+spec/+src/+';'s/_spec.cr'$'/.cr/))
            [ ! -f $altfile ] && echo "echo -markup '{Error}found no implementation file $altfile'" && exit
        ;;
        *src/*.cr)
            altfile=$(eval echo $(echo $kak_buffile | sed s+src/+spec/+';'s/.cr'$'/_spec'\0'/))
            [ ! -f $altfile ] && echo "echo -markup '{Error}found no spec file $altfile'" && exit
        ;;
        *.cr)
            path=$kak_buffile
            dirs=$(while [ $path ]; do echo $path; path=${path%/*}; done | tail -n +2)
            for dir in $dirs; do
                altdir=$dir/spec
                if [ -d $altdir ]; then
                    altfile=$altdir/$(realpath $kak_buffile --relative-to $dir | sed s+[^/]'*'/++';'s/.cr$/_spec.cr/)
                    break
                fi
            done
            [ ! -d $altdir ] && echo "echo -markup '{Error}spec/ not found'" && exit
        ;;
        *)
            echo "echo -markup '{Error}alternative file not found'" && exit
        ;;
    esac
    echo "edit %($altfile)"
}}

define-command -hidden _crystal_filter_around_selections %{
    evaluate-commands -no-hooks -draft -itersel %{
        execute-keys <a-x>
        # remove trailing white spaces
        try %{ execute-keys -draft s \h + $ <ret> d }
    }
}

define-command -hidden _crystal_indent_on_char %{
    evaluate-commands -no-hooks -draft -itersel %{
        # # align middle and end structures to start
        # try %{ execute-keys -draft <a-x> <a-k> ^ \h * (else|elsif) $ <ret> <a-\;> <a-?> ^ \h * (if)                                                             <ret> s \A | \Z <ret> \' <a-&> }
        # try %{ execute-keys -draft <a-x> <a-k> ^ \h * (when)       $ <ret> <a-\;> <a-?> ^ \h * (case)                                                           <ret> s \A | \Z <ret> \' <a-&> }
        # try %{ execute-keys -draft <a-x> <a-k> ^ \h * (rescue)     $ <ret> <a-\;> <a-?> ^ \h * (begin)                                                          <ret> s \A | \Z <ret> \' <a-&> }
        # # Reduce indent of end structures by one.
        # try %{ execute-keys -draft <a-x> <a-k> ^ \h * (end)        $ <ret> <a-lt> }
        # Reduce indent of all end structures by one.
        try %{ execute-keys -draft <a-x> <a-k> ^ \h * (else|elsif|end|rescue|when) $ <ret> <a-lt> }
        try %{
            execute-keys -draft <a-x> <a-k> ^ \h * (end)        $ <ret> <a-\;> <a-?> ^ (
                ( [^\n] * do(\h * \| [^\n] * \| \h * $)? ) | ( \h * (begin|case|for|if|unless|until|while|((private|protected) \h +)?(abstract \h +)?(class|def|enum|struct|macro|module)) )
            ) <ret> Z ';' <a-x> s ^\s*. <ret> y z <a-:> ';' <a-x> <a-k> <c-r> '"' <backspace> \s <ret> z s \A | \Z <ret> \' <a-&>
        }
#         # This is an earlier version of the above, but I think it does exactly the same.
#         # try %{ execute-keys -draft <a-x> <a-k> ^ \h * (end)        $ <ret> y <a-\;> <a-?> <c-r> '"' <ret> '<a-;>' ';' <a-lt> }
#         try %{ execute-keys -draft <a-x> <a-k> ^ \h * (end)        $ <ret> <a-\;> <a-?> ^ ( ( [^\n] * do(\h * \| [^\n] * \| \h * $)? ) | ( \h * (begin|case|for|if|unless|until|while|((private|protected) \h +)?(abstract \h +)?(class|def|struct|macro|module)) ) ) <ret> Z ';' <a-x> s ^\s*. <ret> y z <a-:> ';' <a-x> <a-k> <c-r> '"' <backspace> \s <ret> z s \A | \Z <ret> \' <a-&> }
    }
}

define-command -hidden _crystal_indent_on_new_line %<
    evaluate-commands -no-hooks -draft -itersel %<
        # preserve previous line indent
        try %{ execute-keys -draft K <a-&> }
        # filter previous line
        try %{ execute-keys -draft k : _crystal_filter_around_selections <ret> }
        # indent after start structure
        try %< execute-keys -draft k <a-x> <a-k> ^ ( ( [^\n] * ( (do | [{[(])(\h * \| [^\n] * \| \h *)? $ ) ) | \h * ( (begin|case|else|elsif|ensure|for|if|rescue|unless|until|when|while|((private|protected) \h +)?(abstract \h +)?(class|def|enum|struct|macro|module)) ) \b ) <ret> j <a-gt> >
    >
>

#define-command -hidden _crystal_insert_on_new_line %{
#    evaluate-commands -draft -itersel %{
#        # copy _#_ comment prefix and following white spaces
#        try %{ execute-keys -draft k x s ^ \h * \K \# \h * <ret> y j p }
#        # wisely add end structure
#        evaluate-commands -save-regs x %{
#            try %{ execute-keys -draft k x s ^ \h + <ret> \" x y } catch %{ reg x '' }
#            try %{ execute-keys -draft k x <a-k> ^ <c-r> x (begin|case|class|def|do|for|if|macro|module|struct|unless|until|while) <ret> j <a-a> i X <a-\;> K <a-K> ^ <c-r> x (for|function|if|while) . * \n <c-r> x end $ <ret> j x y p j a end <esc> }
#            # try %{ execute-keys -draft k x <a-k> ^ <c-r> x (begin|case|class|def|do|for|if|module|record|struct|unless|until|while) <ret> j <a-a> i X <a-\;> K <a-K> ^ <c-r> x (for|function|if|while) . * \n <c-r> x end $ <ret> j x y p j a end <esc> <a-lt> }
#        }
#    }
#}

# Initialization
# ‾‾‾‾‾‾‾‾‾‾‾‾‾‾

hook global WinSetOption filetype=crystal %{
    add-highlighter window ref crystal

    hook window InsertChar .* -group crystal-indent _crystal_indent_on_char
    hook window InsertChar \n -group crystal-indent _crystal_indent_on_new_line

    alias window alt crystal-alternative-file
}

hook -group crystal-highlight global WinSetOption filetype=(?!crystal).* %{ remove-highlighter window/crystal }

hook global WinSetOption filetype=(?!crystal).* %{
    rmhooks window crystal-indent
    rmhooks window crystal-insert

    unalias window alt crystal-alternative-file
}
