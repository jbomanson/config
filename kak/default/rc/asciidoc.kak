
hook global WinSetOption filetype=asciidoc %{
    set window indentwidth 2
    set window tabstop 2
    decl str completion_extra_word_char %{-}
    autowrap-enable
    # hook window InsertChar \n -group asciidoc-indent markdown-indent-on-new-line
    map buffer user -docstring 'Underline with the next character' -- t %(:asciidoc-title-start<ret>)
    map buffer user -docstring 'Underline to mark level 0' -- = %(:asciidoc-title =<ret>)
    map buffer user -docstring 'Underline to mark level 1' -- - %(:asciidoc-title -<ret>)
    map buffer user -docstring 'Underline to mark level 2' -- ~ %(:asciidoc-title ~<ret>)
    map buffer user -docstring 'Underline to mark level 3' -- ^ %(:asciidoc-title ^<ret>)
    map buffer user -docstring 'Underline to mark level 4' -- + %(:asciidoc-title +<ret>)
    map buffer user -docstring 'Underline with =' -- 0 %(:asciidoc-title =<ret>)
    map buffer user -docstring 'Underline with -' -- 1 %(:asciidoc-title -<ret>)
    map buffer user -docstring 'Underline with ~' -- 2 %(:asciidoc-title ~<ret>)
    map buffer user -docstring 'Underline with ^' -- 3 %(:asciidoc-title ^<ret>)
    map buffer user -docstring 'Underline with +' -- 4 %(:asciidoc-title +<ret>)
}

# hook global WinSetOption filetype=(?!asciidoc).* %{
#     remove-hooks window asciidoc-indent
# }

# Shortcuts for generating document and section titles like the following:
#
# Level 0 
# =======
#
# Level 1
# -------
# Text.
# 
# Level 2
# ~~~~~~~
# Text.
# 
# Level 3
# ^^^^^^^
# Text.
# 
# Level 4
# +++++++
# Text.

def asciidoc-title-start %{
    on-key %{
        asciidoc-title %val{key}
    }
}

def -params 1 asciidoc-title %{
    exec -draft "ghxy<a-p>Hr%arg{1}"
}

# NOTE: The following does not work.
# 
# # Highlighting for code blocks such as the following:
# # 
# # [source, ruby, indent=0]
# # ----------------------------------------
# # def myfun(x)
# #   puts x + 1
# # end
# # ----------------------------------------
# #
# # ^\[source,[^\]]*\bruby\b[^\]]*]\h*\n-{4,}
# 
# add-highlighter -group / regions -default content asciidoc-extra \
#     c          ^\[source,[^\]]*\bc\b[^\]]*]\h*\n-{4,}             ^-{4,}    '' \
#     cabal      ^\[source,[^\]]*\bcabal\b[^\]]*]\h*\n-{4,}         ^-{4,}    '' \
#     clojure    ^\[source,[^\]]*\bclojure\b[^\]]*]\h*\n-{4,}       ^-{4,}    '' \
#     coffee     ^\[source,[^\]]*\bcoffee\b[^\]]*]\h*\n-{4,}        ^-{4,}    '' \
#     cpp        ^\[source,[^\]]*\bcpp\b[^\]]*]\h*\n-{4,}           ^-{4,}    '' \
#     css        ^\[source,[^\]]*\bcss\b[^\]]*]\h*\n-{4,}           ^-{4,}    '' \
#     cucumber   ^\[source,[^\]]*\bcucumber\b[^\]]*]\h*\n-{4,}      ^-{4,}    '' \
#     d          ^\[source,[^\]]*\bd\b[^\]]*]\h*\n-{4,}             ^-{4,}    '' \
#     diff       ^\[source,[^\]]*\bdiff\b[^\]]*]\h*\n-{4,}          ^-{4,}    '' \
#     dockerfile ^\[source,[^\]]*\bdockerfile\b[^\]]*]\h*\n-{4,}    ^-{4,}    '' \
#     fish       ^\[source,[^\]]*\bfish\b[^\]]*]\h*\n-{4,}          ^-{4,}    '' \
#     gas        ^\[source,[^\]]*\bgas\b[^\]]*]\h*\n-{4,}           ^-{4,}    '' \
#     go         ^\[source,[^\]]*\bgo\b[^\]]*]\h*\n-{4,}            ^-{4,}    '' \
#     haml       ^\[source,[^\]]*\bhaml\b[^\]]*]\h*\n-{4,}          ^-{4,}    '' \
#     haskell    ^\[source,[^\]]*\bhaskell\b[^\]]*]\h*\n-{4,}       ^-{4,}    '' \
#     html       ^\[source,[^\]]*\bhtml\b[^\]]*]\h*\n-{4,}          ^-{4,}    '' \
#     ini        ^\[source,[^\]]*\bini\b[^\]]*]\h*\n-{4,}           ^-{4,}    '' \
#     java       ^\[source,[^\]]*\bjava\b[^\]]*]\h*\n-{4,}          ^-{4,}    '' \
#     javascript ^\[source,[^\]]*\bjavascript\b[^\]]*]\h*\n-{4,}    ^-{4,}    '' \
#     json       ^\[source,[^\]]*\bjson\b[^\]]*]\h*\n-{4,}          ^-{4,}    '' \
#     julia      ^\[source,[^\]]*\bjulia\b[^\]]*]\h*\n-{4,}         ^-{4,}    '' \
#     kak        ^\[source,[^\]]*\bkak\b[^\]]*]\h*\n-{4,}           ^-{4,}    '' \
#     kickstart  ^\[source,[^\]]*\bkickstart\b[^\]]*]\h*\n-{4,}     ^-{4,}    '' \
#     latex      ^\[source,[^\]]*\blatex\b[^\]]*]\h*\n-{4,}         ^-{4,}    '' \
#     lisp       ^\[source,[^\]]*\blisp\b[^\]]*]\h*\n-{4,}          ^-{4,}    '' \
#     lua        ^\[source,[^\]]*\blua\b[^\]]*]\h*\n-{4,}           ^-{4,}    '' \
#     makefile   ^\[source,[^\]]*\bmakefile\b[^\]]*]\h*\n-{4,}      ^-{4,}    '' \
#     moon       ^\[source,[^\]]*\bmoon\b[^\]]*]\h*\n-{4,}          ^-{4,}    '' \
#     objc       ^\[source,[^\]]*\bobjc\b[^\]]*]\h*\n-{4,}          ^-{4,}    '' \
#     perl       ^\[source,[^\]]*\bperl\b[^\]]*]\h*\n-{4,}          ^-{4,}    '' \
#     pug        ^\[source,[^\]]*\bpug\b[^\]]*]\h*\n-{4,}           ^-{4,}    '' \
#     python     ^\[source,[^\]]*\bpython\b[^\]]*]\h*\n-{4,}        ^-{4,}    '' \
#     ragel      ^\[source,[^\]]*\bragel\b[^\]]*]\h*\n-{4,}         ^-{4,}    '' \
#     ruby       ^\[source,[^\]]*\bruby\b[^\]]*]\h*\n-{4,}          ^-{4,}    '' \
#     rust       ^\[source,[^\]]*\brust\b[^\]]*]\h*\n-{4,}          ^-{4,}    '' \
#     sass       ^\[source,[^\]]*\bsass\b[^\]]*]\h*\n-{4,}          ^-{4,}    '' \
#     scala      ^\[source,[^\]]*\bscala\b[^\]]*]\h*\n-{4,}         ^-{4,}    '' \
#     scss       ^\[source,[^\]]*\bscss\b[^\]]*]\h*\n-{4,}          ^-{4,}    '' \
#     sh         ^\[source,[^\]]*\bsh\b[^\]]*]\h*\n-{4,}            ^-{4,}    '' \
#     swift      ^\[source,[^\]]*\bswift\b[^\]]*]\h*\n-{4,}         ^-{4,}    '' \
#     tupfile    ^\[source,[^\]]*\btupfile\b[^\]]*]\h*\n-{4,}       ^-{4,}    '' \
#     yaml       ^\[source,[^\]]*\byaml\b[^\]]*]\h*\n-{4,}          ^-{4,}    '' \
#     code       ```              ```          '' \
#     code       ``               ``           '' \
#     code       `                `            ''
# 
# add-highlighter -group /asciidoc-extra/code fill meta
# 
# add-highlighter -group /asciidoc-extra/c          ref c
# add-highlighter -group /asciidoc-extra/cabal      ref cabal
# add-highlighter -group /asciidoc-extra/clojure    ref clojure
# add-highlighter -group /asciidoc-extra/coffee     ref coffee
# add-highlighter -group /asciidoc-extra/cpp        ref cpp
# add-highlighter -group /asciidoc-extra/css        ref css
# add-highlighter -group /asciidoc-extra/cucumber   ref cucumber
# add-highlighter -group /asciidoc-extra/d          ref d
# add-highlighter -group /asciidoc-extra/diff       ref diff
# add-highlighter -group /asciidoc-extra/dockerfile ref dockerfile
# add-highlighter -group /asciidoc-extra/fish       ref fish
# add-highlighter -group /asciidoc-extra/gas        ref gas
# add-highlighter -group /asciidoc-extra/go         ref go
# add-highlighter -group /asciidoc-extra/haml       ref haml
# add-highlighter -group /asciidoc-extra/haskell    ref haskell
# add-highlighter -group /asciidoc-extra/html       ref html
# add-highlighter -group /asciidoc-extra/ini        ref ini
# add-highlighter -group /asciidoc-extra/java       ref java
# add-highlighter -group /asciidoc-extra/javascript ref javascript
# add-highlighter -group /asciidoc-extra/json       ref json
# add-highlighter -group /asciidoc-extra/julia      ref julia
# add-highlighter -group /asciidoc-extra/kak        ref kak
# add-highlighter -group /asciidoc-extra/kickstart  ref kickstart
# add-highlighter -group /asciidoc-extra/latex      ref latex
# add-highlighter -group /asciidoc-extra/lisp       ref lisp
# add-highlighter -group /asciidoc-extra/lua        ref lua
# add-highlighter -group /asciidoc-extra/makefile   ref makefile
# add-highlighter -group /asciidoc-extra/moon       ref moon
# add-highlighter -group /asciidoc-extra/objc       ref objc
# add-highlighter -group /asciidoc-extra/perl       ref perl
# add-highlighter -group /asciidoc-extra/pug        ref pug
# add-highlighter -group /asciidoc-extra/python     ref python
# add-highlighter -group /asciidoc-extra/ragel      ref ragel
# add-highlighter -group /asciidoc-extra/ruby       ref ruby
# add-highlighter -group /asciidoc-extra/rust       ref rust
# add-highlighter -group /asciidoc-extra/sass       ref sass
# add-highlighter -group /asciidoc-extra/scala      ref scala
# add-highlighter -group /asciidoc-extra/scss       ref scss
# add-highlighter -group /asciidoc-extra/sh         ref sh
# add-highlighter -group /asciidoc-extra/swift      ref swift
# add-highlighter -group /asciidoc-extra/tupfile    ref tupfile
# add-highlighter -group /asciidoc-extra/yaml       ref yaml
# 
# add-highlighter -group /asciidoc ref asciidoc-extra
