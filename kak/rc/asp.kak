# http://asp-lang.org
# ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾

# Detection
# ‾‾‾‾‾‾‾‾‾

hook global BufCreate .*\.(asp|lp) %{
    set-option buffer filetype asp
}

hook global WinSetOption filetype=asp %{
    set-option window indentwidth 8
}

# Highlighters
# ‾‾‾‾‾‾‾‾‾‾‾‾

add-highlighter shared/ regions -default code asp \
    double_string '"' (?<!\\)(\\\\)*"        '' \
    comment       '%' '$'                    '' \
    comment       '%\*' '\*%'                '' \
    script        '#script' '#end.'          ''

add-highlighter shared/asp/double_string fill string
add-highlighter shared/asp/comment fill comment
add-highlighter shared/asp/script fill meta

# Tip: The auto completion for :set-face gives potential words to use in place
# of variable, value, function, etc.
add-highlighter shared/asp/code regex \b([_]*[A-Z][A-Za-z0-9]*)\b 0:variable
add-highlighter shared/asp/code regex \b(0|[1-9])[0-9]*\b 0:value
add-highlighter shared/asp/code regex (?<!#)\b[_]*[a-z][A-Za-z0-9_]*(?![(])\b 0:value
add-highlighter shared/asp/code regex (?<!#)\b[_]*[a-z][A-Za-z0-9_]*(?=[(])\b 0:function

%sh{
    # Grammar
    aggregates="#count|#even|#max|#min|#odd|#sum"
    directives="#base|#const|#cumulative|#disjoint|#external|#forget|#hide|#include|#maximize|#minimize|#program|#show|#showsig"
    operators="not"
    values="#false|#inf|#sup|#true"

    # Add the language's grammar to the static completion list
    printf %s\\n "hook global WinSetOption filetype=asp %{
        set-option window static_words '${aggregates}:${directives}:${operators}:${values}'
    }" | sed 's,|,:,g'

    # Highlight
    printf %s "
        add-highlighter shared/asp/code regex (${aggregates})\b 0:value
        add-highlighter shared/asp/code regex (${directives})\b 0:meta
        add-highlighter shared/asp/code regex \b(${operators})\b 0:operator
        add-highlighter shared/asp/code regex (${values})\b 0:value
    "
}

# Commands
# ‾‾‾‾‾‾‾‾

define-command -hidden _asp_indent_on_new_line %<
    evaluate-commands -no-hooks -draft -itersel %<
        # preserve previous line indent unless it ends in a period
        try %{ execute-keys -draft K <a-K>\.\s*(%.*)?<ret> <a-&> }
        # indent after rule start unless the rule ends on that line
        try %< execute-keys -draft %<k<a-x><a-k>:<minus>|:~|^#<ret><a-K>\.\s*(%.*)?<ret>j<a-gt>> >
    >
>

# Initialization
# ‾‾‾‾‾‾‾‾‾‾‾‾‾‾

hook global WinSetOption filetype=asp %{
    add-highlighter window ref asp
    hook window InsertChar \n -group asp-indent _asp_indent_on_new_line
}

hook -group asp-highlight global WinSetOption filetype=(?!asp).* %{ remove-highlighter window/asp }

hook global WinSetOption filetype=(?!asp).* %{
    rmhooks window asp-indent
}
