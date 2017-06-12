# http://crystal-lang.org
# ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾

# require commenting.kak

# Detection
# ‾‾‾‾‾‾‾‾‾

# hook global BufSetOption mimetype=text/x-crystal %{
#     set buffer filetype crystal
# }

hook global BufCreate .*\.cr %{
    set buffer filetype crystal
    # set buffer mimetype ''
}

# Highlighters
# ‾‾‾‾‾‾‾‾‾‾‾‾

add-highlighter -group / regions -default code crystal       \
    double_string '"' (?<!\\)(\\\\)*"        '' \
    single_string "'" (?<!\\)(\\\\)*'        '' \
    backtick      '`' (?<!\\)(\\\\)*`        '' \
    regex         '/' (?<!\\)(\\\\)*/[imox]* '' \
    comment       '#' '$'                    '' \
    comment       ^begin= ^=end              '' \
    literal       '%[iqrswxIQRSWX]\(' \)     \( \
    literal       '%[iqrswxIQRSWX]\{' \}     \{ \
    literal       '%[iqrswxIQRSWX]\[' \]     \[ \
    literal       '%[iqrswxIQRSWX]<'   >      < \
    division '[\w\)\]](/|(\h+/\h+))' '\w' '' # Help Kakoune to better detect /…/ literals

# Regular expression flags are: i → ignore case, m → multi-lines, o → only interpolate #{} blocks once, x → extended mode (ignore white spaces)
# Literals are: i → array of symbols, q → string, r → regular expression, s → symbol, w → array of words, x → capture shell result

add-highlighter -group /crystal/double_string fill string
add-highlighter -group /crystal/double_string regions regions interpolation \Q#{ \} \{
add-highlighter -group /crystal/double_string/regions/interpolation fill meta

add-highlighter -group /crystal/single_string fill string

add-highlighter -group /crystal/backtick fill meta
add-highlighter -group /crystal/backtick regions regions interpolation \Q#{ \} \{
add-highlighter -group /crystal/backtick/regions/interpolation fill meta

add-highlighter -group /crystal/regex fill meta
add-highlighter -group /crystal/regex regions regions interpolation \Q#{ \} \{
add-highlighter -group /crystal/regex/regions/interpolation fill meta

add-highlighter -group /crystal/comment fill comment

add-highlighter -group /crystal/literal fill meta

add-highlighter -group /crystal/code regex \b([A-Za-z]\w*:(?=[^:]))|([$@][A-Za-z]\w*)|((?<=[^:]):[A-Za-z]\w*[=?!]?)|([A-Z]\w*|^|\h)\K::(?=[A-Z]) 0:variable

%sh{
    # Grammar
    keywords="abstract|alias|begin|break|case|class|def|defined|do|else|elsif|end"
    keywords="${keywords}|ensure|enum|false|for|if|in|macro|module|next|nil|previous_def|private|protected|redo"
    keywords="${keywords}|record|rescue|retry|return|self|struct|super|then|true|undef|unless|until|when|while|with|yield"
    attributes="getter|property"
    values="false|true|nil"
    meta="extend|include|require"

    # Add the language's grammar to the static completion list
    printf %s\\n "hook global WinSetOption filetype=crystal %{
        set window static_words '${keywords}:${attributes}:${values}:${meta}'
    }" | sed 's,|,:,g'

    # Highlight keywords
    printf %s "
        add-highlighter -group /crystal/code regex \b(${keywords})\b 0:keyword
        add-highlighter -group /crystal/code regex \b(${attributes})\b 0:attribute
        add-highlighter -group /crystal/code regex \b(${values})\b 0:value
        add-highlighter -group /crystal/code regex \b(${meta})\b 0:meta
    "
}

# Commands
# ‾‾‾‾‾‾‾‾

def crystal-alternative-file -docstring 'Jump to the alternate file (implementation ↔ test)' %{ %sh{
    case $kak_buffile in
        *spec/*_spec.cr)
            altfile=$(eval echo $(echo $kak_buffile | sed s+spec/+src/+';'s/_spec.cr'$'/.cr/))
            [ ! -f $altfile ] && echo "echo -color Error %(found no implementation file $altfile)" && exit
        ;;
        *src/*.cr)
            altfile=$(eval echo $(echo $kak_buffile | sed s+src/+spec/+';'s/.cr'$'/_spec'\0'/))
            [ ! -f $altfile ] && echo "echo -color Error %(found no spec file $altfile)" && exit
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
            [ ! -d $altdir ] && echo "echo -color Error 'spec/ not found'" && exit
        ;;
        *)
            echo "echo -color Error 'alternative file not found'" && exit
        ;;
    esac
    echo "edit %($altfile)"
}}

def -hidden _crystal_filter_around_selections %{
    eval -no-hooks -draft -itersel %{
        exec <a-x>
        # remove trailing white spaces
        try %{ exec -draft s \h + $ <ret> d }
    }
}

def -hidden _crystal_indent_on_char %{
    eval -no-hooks -draft -itersel %{
        # align middle and end structures to start
        try %{ exec -draft <a-x> <a-k> ^ \h * (else|elsif) $ <ret> <a-\;> <a-?> ^ \h * (if)                                                             <ret> s \A | \Z <ret> \' <a-&> }
        try %{ exec -draft <a-x> <a-k> ^ \h * (when)       $ <ret> <a-\;> <a-?> ^ \h * (case)                                                           <ret> s \A | \Z <ret> \' <a-&> }
        try %{ exec -draft <a-x> <a-k> ^ \h * (rescue)     $ <ret> <a-\;> <a-?> ^ \h * (begin)                                                          <ret> s \A | \Z <ret> \' <a-&> }
        try %{ exec -draft <a-x> <a-k> ^ \h * (end)        $ <ret> y <a-\;> <a-?> <c-r> '"' <ret> '<a-;>' ';' <a-lt> }
        try %{ exec -draft <a-x> <a-k> ^ \h * (end)        $ <ret> <a-\;> <a-?> ^ ( ( [^\n] * do(\h * \| [^\n] * \| \h * $)? ) | ( \h * (begin|case|for|if|unless|until|while|((private|protected) \h +)?(abstract \h +)?(class|def|struct|macro|module)) ) ) <ret> Z ';' <a-x> s ^\s*. <ret> y z <a-:> ';' <a-x> <a-k> <c-r> '"' <backspace> \s <ret> z s \A | \Z <ret> \' <a-&> }
    }
}

def -hidden _crystal_indent_on_new_line %{
    eval -no-hooks -draft -itersel %{
        # preserve previous line indent
        try %{ exec -draft K <a-&> }
        # filter previous line
        try %{ exec -draft k : _crystal_filter_around_selections <ret> }
        # indent after start structure
        try %{ exec -draft k <a-x> <a-k> ^ ( ( [^\n] * do(\h * \| [^\n] * \| \h * $)? ) | \h * ( (begin|case|else|elsif|ensure|enum|for|if|rescue|unless|until|when|while|((private|protected) \h +)?(abstract \h +)?(class|def|struct|macro|module)) ) ) \b <ret> j <a-gt> }
        # try %{ exec -draft k x <a-k> ^ ( ( [^\n] * do(\h * \| [^\n] * \| \h * $)? ) | \h * ( (begin|case|else|elsif|ensure|enum|for|if|rescue|unless|until|when|while|((private|protected) \h +)?(abstract \h +)?(class|def|struct|macro|module)) ) ) \b <ret> j <a-gt> }
        # try %{ exec -draft k x <a-k> ^ \h * (begin|case|(private \h +)?(abstract \h +)?(class|struct)|((private|protected) \h +)?def|do|else|elsif|ensure|enum|for|if|macro|module|rescue|unless|until|when|while) \b <ret> j <a-gt> }
    }
}

#def -hidden _crystal_insert_on_new_line %{
#    eval -draft -itersel %{
#        # copy _#_ comment prefix and following white spaces
#        try %{ exec -draft k x s ^ \h * \K \# \h * <ret> y j p }
#        # wisely add end structure
#        eval -save-regs x %{
#            try %{ exec -draft k x s ^ \h + <ret> \" x y } catch %{ reg x '' }
#            try %{ exec -draft k x <a-k> ^ <c-r> x (begin|case|class|def|do|for|if|macro|module|struct|unless|until|while) <ret> j <a-a> i X <a-\;> K <a-K> ^ <c-r> x (for|function|if|while) . * \n <c-r> x end $ <ret> j x y p j a end <esc> }
#            # try %{ exec -draft k x <a-k> ^ <c-r> x (begin|case|class|def|do|for|if|module|record|struct|unless|until|while) <ret> j <a-a> i X <a-\;> K <a-K> ^ <c-r> x (for|function|if|while) . * \n <c-r> x end $ <ret> j x y p j a end <esc> <a-lt> }
#        }
#    }
#}

# Initialization
# ‾‾‾‾‾‾‾‾‾‾‾‾‾‾

hook global WinSetOption filetype=crystal %{
    add-highlighter ref crystal

    hook window InsertChar .* -group crystal-indent _crystal_indent_on_char
    hook window InsertChar \n -group crystal-indent _crystal_indent_on_new_line

    alias window alt crystal-alternative-file
}

hook -group crystal-highlight global WinSetOption filetype=(?!crystal).* %{ remove-highlighter crystal }

hook global WinSetOption filetype=(?!crystal).* %{
    rmhooks window crystal-indent
    rmhooks window crystal-insert

    unalias window alt crystal-alternative-file
}
