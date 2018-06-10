hook global WinSetOption filetype=kak %{
    map buffer user g -docstring %(Do a kakrc specific operation) %(:kakrc-mode<ret>)
    set-option window extra_word_chars -
}

#===============================================================================
#               Modes
#===============================================================================

define-command -hidden kakrc-mode %{
  info -title %{Do kakrc specific operations} %{
    e: Evaluate selection with -override
    p: Evaluate paragraph with -override and -draft
  }
  on-key %{ %sh{
    case $kak_key in
      ('e') echo kak-evaluate-selection-override ;;
      ('p') echo kak-evaluate-selection-override-paragraph ;;
    esac
  }
}}

#===============================================================================

define-command kak-evaluate-selection-simple \
    -docstring 'Evaluate selected kak commands' %(
    evaluate-commands -itersel "%val(selection)"
)

define-command kak-evaluate-selection-override \
    -override \
    -docstring "Evaluate selections with -override" \
    %(
        evaluate-commands -itersel %(
            evaluate-commands -draft -save-regs "" %(
                execute-keys -save-regs "" y
                evaluate-on-register '"' %(
                    try %(
                        execute-keys -draft \
                            %(s^\h*define-command <ret>a-override <esc>)
                    )
                )
            )
            evaluate-commands %reg(")
        )
    )

define-command kak-evaluate-selection-override-paragraph \
    -hidden \
    -docstring "Evaluate paragraph with -override and -draft" \
    %(
        evaluate-commands -draft -itersel %(
            execute-keys <a-i>p
            kak-evaluate-selection-override
        )
    )
