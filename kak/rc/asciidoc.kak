
hook global WinSetOption filetype=asciidoc %{
    autowrap-disable
    map buffer user -docstring "Do an asciidoc specific operation" g %(:asciidoc-mode<ret>)
    set-option buffer comment_line '//'
    set-option window extra_word_chars %{-}
    set-option window indentwidth 2
    set-option window tabstop 2
}

#===============================================================================
#               Modes
#===============================================================================

define-command -hidden asciidoc-mode %{
  info -title %{Do an asciidoc specific operation} %{
    0,=: Underline with = to mark a level 0 title
    1,-: Underline with - to mark a level 1 title
    2,~: Underline with ~ to mark a level 2 title
    3,^: Underline with ^ to mark a level 3 title
    4,+: Underline with + to mark a level 4 title
    c:   Underline with a custom character
    <:   Reduce list item indentation
    >:   Reduce list item indentation
  }
  on-key %{ %sh{
    case $kak_key in
        'c') echo asciidoc-title-mode ;;
        '0' | '=') echo asciidoc-title "'='" ;;
        '1' | '<minus>') echo asciidoc-title "'-'" ;;
        '2' | '~') echo asciidoc-title "'~'" ;;
        '3' | '^') echo asciidoc-title "'^'" ;;
        '<gt>') echo standard-editor-list-indent 1 ;;
        '<lt>') echo standard-editor-list-indent -1 ;;
    esac
  } }
}

define-command asciidoc-title-mode %{
    on-key %{
        asciidoc-title "%val{key}"
    }
}

#===============================================================================
#
#===============================================================================

# A command for generating document and section titles like the following:
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

define-command -params 1 asciidoc-title %{
    execute-keys -draft "<a-x>ypjgi<a-l>r%arg{1}"
    # execute-keys -draft "ghxy<a-p>Hr%arg{1}"
    # execute-keys -draft "ghxy<a-p>Hr%arg{1}"
}

#===============================================================================
#
#===============================================================================

# NOTE: The following does not work.
# 
# # Highlighting for code blocks such as the following:
# # 
# # [source, ruby, indent=0]
# # ----------------------------------------
# # define-command myfun(x)
# #   puts x + 1
# # end
# # ----------------------------------------
# #
# # ^\[source,[^\]]*\bruby\b[^\]]*]\h*\n-{4,}
# 
# add-highlighter shared/ regions -default content asciidoc-extra \
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
# add-highlighter shared/asciidoc-extra/code fill meta
# 
# add-highlighter shared/asciidoc-extra/c          ref c
# add-highlighter shared/asciidoc-extra/cabal      ref cabal
# add-highlighter shared/asciidoc-extra/clojure    ref clojure
# add-highlighter shared/asciidoc-extra/coffee     ref coffee
# add-highlighter shared/asciidoc-extra/cpp        ref cpp
# add-highlighter shared/asciidoc-extra/css        ref css
# add-highlighter shared/asciidoc-extra/cucumber   ref cucumber
# add-highlighter shared/asciidoc-extra/d          ref d
# add-highlighter shared/asciidoc-extra/diff       ref diff
# add-highlighter shared/asciidoc-extra/dockerfile ref dockerfile
# add-highlighter shared/asciidoc-extra/fish       ref fish
# add-highlighter shared/asciidoc-extra/gas        ref gas
# add-highlighter shared/asciidoc-extra/go         ref go
# add-highlighter shared/asciidoc-extra/haml       ref haml
# add-highlighter shared/asciidoc-extra/haskell    ref haskell
# add-highlighter shared/asciidoc-extra/html       ref html
# add-highlighter shared/asciidoc-extra/ini        ref ini
# add-highlighter shared/asciidoc-extra/java       ref java
# add-highlighter shared/asciidoc-extra/javascript ref javascript
# add-highlighter shared/asciidoc-extra/json       ref json
# add-highlighter shared/asciidoc-extra/julia      ref julia
# add-highlighter shared/asciidoc-extra/kak        ref kak
# add-highlighter shared/asciidoc-extra/kickstart  ref kickstart
# add-highlighter shared/asciidoc-extra/latex      ref latex
# add-highlighter shared/asciidoc-extra/lisp       ref lisp
# add-highlighter shared/asciidoc-extra/lua        ref lua
# add-highlighter shared/asciidoc-extra/makefile   ref makefile
# add-highlighter shared/asciidoc-extra/moon       ref moon
# add-highlighter shared/asciidoc-extra/objc       ref objc
# add-highlighter shared/asciidoc-extra/perl       ref perl
# add-highlighter shared/asciidoc-extra/pug        ref pug
# add-highlighter shared/asciidoc-extra/python     ref python
# add-highlighter shared/asciidoc-extra/ragel      ref ragel
# add-highlighter shared/asciidoc-extra/ruby       ref ruby
# add-highlighter shared/asciidoc-extra/rust       ref rust
# add-highlighter shared/asciidoc-extra/sass       ref sass
# add-highlighter shared/asciidoc-extra/scala      ref scala
# add-highlighter shared/asciidoc-extra/scss       ref scss
# add-highlighter shared/asciidoc-extra/sh         ref sh
# add-highlighter shared/asciidoc-extra/swift      ref swift
# add-highlighter shared/asciidoc-extra/tupfile    ref tupfile
# add-highlighter shared/asciidoc-extra/yaml       ref yaml
# 
# add-highlighter shared/asciidoc ref asciidoc-extra
