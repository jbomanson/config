hook global WinSetOption filetype=sh %{
    set-option window extra_word_chars -
    lint-enable
    map buffer user -docstring "Do an sh specific operation" g %(:sh-mode<ret>)
    set-option buffer lintcmd 'shellcheck --format=gcc'
    set-option window indentwidth 4
    set-option window tabstop 4
}

#===============================================================================
#               Modes
#===============================================================================

define-command -hidden sh-mode %{
  info -title %{Do an sh specific operation} "
    \\: Escape selected text for a shell
    f: Format selected functions
    F: Format selected function contents
    l: Lint the file with %opt(lintcmd)
  "
  on-key %{ %sh{
      echo "$kak_key" >> /tmp/vvv.txt
    case $kak_key in
      ('\') echo bash-shell-escape ;;
      ('f') echo bash-format-function ;;
      ('F') echo bash-format-function-body ;;
      ('l') echo lint ;;
    esac
  }
}}

define-command bash-format-function \
    -docstring "Formats and orders selected bash functions." \
    %(
        util-pipe bash -c '
            noise=$(compgen -A function)
            eval "$(cat)"
            relevant=$(echo "$noise" | comm -13 - <(compgen -A function))
            declare -pf $relevant
        '
        # Trim trailing newlines.
        try %( execute-keys -draft %(s +$<ret>d) )
    )

# This function works by wrapping selected text into an ad hock bash function,
# formatting that bash function, and then removing it. 
define-command bash-format-function-body \
    -docstring "Formats selected text." \
    %(
        evaluate-commands -itersel %(
            execute-keys <a-x>
            with-preserved-indentation evaluate-commands %(
                block-insert-multiline "top-level () {" "}"
                bash-format-function
                # Peel off the top level function.
                util-pipe bash -c 'head -n-1 | tail -n+3'
                # Peel off the top level function.
                # earlier-version {
                # execute-keys 'Zs\s*^\}\s*<ret>Hdzs.*\{\r?\n<ret>dz'
                # }
                # earlier-version (
                # NOTE: \Z stopped working in e9e3dc8
                # execute-keys 'Zs\s*\}\s*\Z<ret>Hdzs\A[^{]*\{\r?\n<ret>dz'
                # )
                # Reduce indentation by four.
                execute-keys -draft 's^ {4}<ret>d'
            )
        )
    )

define-command bash-shell-escape \
    -docstring "Escape selected text for a shell." \
    %(
        util-pipe ruby -e 'require "shellwords"; print STDIN.read.shellescape'
    )
