# This is based on kakoune/src/rc/base/java.kak.
# See https://wiki.gnome.org/Projects/Vala/ValaForJavaProgrammers.

hook global BufCreate .*\.vala %{
    set buffer filetype vala
}

# hook global BufSetOption mimetype=text/vala %{
#     set buffer filetype vala
# }

addhl -group / regions -default code vala \
    verbatim_string '"""' '"""'            '' \
    string %{@?(?<!')"} %{(?<!\\)(\\\\)*"} '' \
    comment /\* \*/ '' \
    comment // $ ''

addhl -group /vala/verbatim_string fill string
addhl -group /vala/string fill string
addhl -group /vala/comment fill comment

addhl -group /vala/code regex %{\b(this|true|false|null)\b} 0:value
addhl -group /vala/code regex "(?<!@)\b(void|int|char|unsigned|float|double)\b" 0:type
addhl -group /vala/code regex "(?<!@)\b(while|for|if|else|do|static|switch|case|default|class|interface|goto|break|continue|return|import|try|catch|throw|new|package)\b" 0:keyword
addhl -group /vala/code regex "(?<!@)\b(public|protected|private|abstract)\b" 0:attribute

addhl -group /vala/code regex "(?<!@)\b(bool|string|int8|int16|int32|int64|uchar|uint|uint8|uint16|uint32|uint6|ulong|unichar)\b" 0:type
addhl -group /vala/code regex "(?<!@)\b(construct|delegate|ensures|foreach|in|is|namespace|out|override|owned|signal|sizeof|struct|requires|super|typeof|using|var|virtual)\b" 0:keyword
addhl -group /vala/code regex "(?<!@)\b(const|internal|unowned)\b" 0:attribute
addhl -group /vala/string regex \$(\w+|\(.+?\)) 0:identifier

hook -group vala-highlight global WinSetOption filetype=vala %{ addhl ref vala }
hook -group vala-highlight global WinSetOption filetype=(?!vala).* %{ rmhl vala }
