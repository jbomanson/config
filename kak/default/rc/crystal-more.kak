hook global WinSetOption filetype=crystal %{
    set window indentwidth 2
    set window tabstop 2

    map buffer user -docstring "Run crystal format on this file" f %(|crystal tool format -<ret>)
    map buffer user -docstring "Run crystal tool implementations" i %(:crystal-tool-implementations<ret>)
    map buffer user -docstring "Go to required file" r %(xs".*"<ret>H<a-;>L:goto-file-relative-almost<ret>.cr<ret>)
    map buffer user -docstring "Run crystal spec on this file" s %(:crystal-spec<ret>)
    decl str completion_extra_word_char :
}

def -hidden _crystal-insert-class %{
    exec %(ggIa<c-r>%<esc>xs^a(src/)?<ret>dxs\..*$<ret>dI/<esc>xs/<ret>c::<esc>~<space>ghLc_<esc>xs_.<ret>~hd<space><esc>Iclass <esc>oend<esc>)
}

def -hidden _crystal-replace-class-with-describe %(
    exec %(ggecdescribe<esc>A<space>do<esc>xsSpec(::)?<ret>d)
)

def -hidden _crystal-insert-class-or-describe %(
    _crystal-insert-class
    try %(
        exec %(ggxsSpec<ret>)
        _crystal-replace-class-with-describe
    )
)

hook global BufNewFile .*\.cr _crystal-insert-class-or-describe

def -docstring %{crystal-doc-example: crystal documentation formatter for examples
The current selection is commented and formatted as an example section} \
    crystal-doc-example %{
        exec -no-hooks -save-regs qs '"sZ<a-:><a-;>kxs^\s*[^[:word:][:space:]]*<ret>"qyo<c-r>q ### Example<ret><c-r>q<esc>"sz<a-s>i<c-r>q<space><space><space><space><space><esc>"sz<a-x>s\h+$<ret>d"sz<a-x>'
    }

def crystal-convert-curly-braces-to-do-end %(
    try %(
        # First look for { |...| ... }.
        exec -draft -save-regs q^ <a-x> '"qZ' s\{\h*\|<ret> "'" <space> Z '<a-;>' ';' cdo<esc> z l f| W s\|\h*<ret> c|<ret><esc> '"qz' s\h*\}\h*\Z<ret> c<ret>end<esc>
    ) catch %(
        # Then look for { ... }.
        exec -draft -save-regs q^ <a-x> '"qZ' s\{\h*<ret> "'" <space> '<a-;>' ';' cdo<ret><esc> '"qz' s\h*\}\h*\Z<ret> c<ret>end<esc>
    )
)
