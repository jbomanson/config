# This is based on kakoune/src/rc/base/java.kak.
# TODO: Incorporate updates done to the above.
# See https://wiki.gnome.org/Projects/Vala/ValaForJavaProgrammers.

hook global BufCreate .*\.vala %{
    set buffer filetype vala
}

add-highlighter -group / regions -default code vala \
    verbatim_string '"""' '"""'            '' \
    string %{@?(?<!')"} %{(?<!\\)(\\\\)*"} '' \
    comment /\* \*/ '' \
    comment // $ ''

add-highlighter -group /vala/verbatim_string fill string
add-highlighter -group /vala/string fill string
add-highlighter -group /vala/comment fill comment

add-highlighter -group /vala/code regex %{\b(this|true|false|null)\b} 0:value
add-highlighter -group /vala/code regex "(?<!@)\b(void|int|char|unsigned|float|double)\b" 0:type
add-highlighter -group /vala/code regex "(?<!@)\b(while|for|if|else|do|static|switch|case|default|class|interface|goto|break|continue|return|import|try|catch|throw|new|package)\b" 0:keyword
add-highlighter -group /vala/code regex "(?<!@)\b(public|protected|private|abstract)\b" 0:attribute

add-highlighter -group /vala/code regex "(?<!@)\b(bool|string|int8|int16|int32|int64|uchar|uint|uint8|uint16|uint32|uint6|ulong|unichar)\b" 0:type
add-highlighter -group /vala/code regex "(?<!@)\b(construct|delegate|ensures|foreach|in|is|namespace|out|override|owned|signal|sizeof|struct|requires|super|typeof|using|var|virtual)\b" 0:keyword
add-highlighter -group /vala/code regex "(?<!@)\b(const|internal|unowned)\b" 0:attribute
add-highlighter -group /vala/string regex \$(\w+|\(.+?\)) 0:variable

hook -group vala-highlight global WinSetOption filetype=vala %{ add-highlighter ref vala }
hook -group vala-highlight global WinSetOption filetype=(?!vala).* %{ remove-highlighter vala }
