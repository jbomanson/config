# This file defines completer that suggests words on the previous line at the
# current column.
#
# BUG:
# This does not work at line beginnings.
#
# BUG (cosmetic):
# Curly braces in menu items are currently translated into [] in order to avoid
# unwanted markup interpretation.
#
# SUGGESTION:
# Give matches only when the current line is a prefix of the previous line.

declare-option -hidden completions matching_column_completions

define-command matching-column-complete -docstring "Complete the current selection with matching_column" %{
    try %(
        # Check that the previous line spans at least up to the current column,
        # and that there is a space character right before the column.
        execute-keys -draft "k<a-x><a-k>^[^\n]{%val(cursor_column)}" (?<=\s\S) "<ret>"
        # Check that the cursor is at the potential beginning of a word.
        execute-keys -draft ";H<a-k>\s.<ret>"
        # Update matching_column_completions.
        evaluate-commands %(
            # Yank a word from the previous line.
            execute-keys -draft -save-regs "" "k<a-W>y"
            # Use it as a completion candidate.
            set-option buffer matching_column_completions \
                "%val(cursor_line).%val(cursor_column)@%val(timestamp):%reg(dquote)||%sh(printf %s \"$kak_reg_dquote\" | tr '{}' '[]')"
        )
    )
}

define-command matching-column-enable-autocomplete -docstring "Add matching_column completion candidates to the completer" %{
    set-option window completers "option=matching_column_completions:%opt{completers}"
    hook window -group matching-column-autocomplete InsertIdle .* %{ try %{
        matching-column-complete
    } }
    alias window complete matching-column-complete
}

define-command matching-column-disable-autocomplete -docstring "Disable matching_column completion" %{
    set-option window completers %sh{ printf %s\\n "'${kak_opt_completers}'" | sed 's/option=matching_column_completions://g' }
    remove-hooks window matching-column-autocomplete
    unalias window complete matching-column-complete
}
