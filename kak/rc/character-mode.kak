declare-option -hidden str character_mode_character ""

define-command -hidden character-mode %{
    info "Do an action based on the next typed character."
    on-key %(
        set-option current character_mode_character "%val(key)"
        character-follow-up-mode
    )
}

define-command -hidden character-follow-up-mode %(
    info -title "Do a character based action" "
    f: Select up to the rightmost %opt(character_mode_character) on the line
    t: Select until the rightmost %opt(character_mode_character) on the line
    "
    on-key %( %sh(
        case $kak_key in
            ('f') echo character-find-right-inclusive ;;
            ('t') echo character-find-right-exclusive ;;
        esac
    ) )
)

define-command character-find-right-inclusive \
    -docstring "Find the rightmost %opt(character_mode_character)." \
    %(
        evaluate-commands -itersel %(
            execute-keys ";<a-l>Z<a-f>%opt(character_mode_character);<a-h><a-z>i"
            echo
        )
    )

define-command character-find-right-exclusive \
    -docstring "Find the rightmost %opt(character_mode_character)." \
    %(
        evaluate-commands -itersel %(
            execute-keys ";<a-l>Z<a-f>%opt(character_mode_character);h<a-h><a-z>i"
            echo
        )
    )
