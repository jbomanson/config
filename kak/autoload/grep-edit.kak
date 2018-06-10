# BUG:
#   This fails when used on the first grep call, because in that special case,
#   undo-maximal undoes everything!
#   It might be possible to hack around this by not allowing undo at
#   history_id 1.

# BUG:
#   Absolute paths are usually rejected by the patch program for security
#   reasons. Absolute paths can be made to work by passing --directory=/ as
#   an argument to patch, but in that case relative paths will stop working.
#   A possible solution would be to turn all paths into absolute ones first.

# WISH:
#   The patch program has a --dry-run option.
#   Add an option to use it.
#
#   Move grep specific convenience functions elsewhere.

# WISH:
#   Delete unseen intermediate files in grep-edit-after.

# DEPENDENCY:
#   standard_editor
#   util-history.kak
#   util-pipe.kak
#   with-selection-by-default.kak

declare-option str grep_edit_diff_buffer "*grep-edit*"
declare-option str grep_edit_diff_file /tmp/grep_edit.diff
declare-option str grep_edit_result_buffer "*grep-edit*"
declare-option str greppathcmd 'patch -p0'
declare-option str toolsclient

#===============================================================================
#               Core functions
#===============================================================================

define-command grep-edit-diff \
    -docstring "Turn changes on a grep-output-like buffer into a patch." \
    %(
        util-history-shell \
            undo-while-nonempty \
            standard_editor grep_diff $2 $1 > %opt(grep_edit_diff_file)
        evaluate-commands -try-client %opt(toolsclient) %(
            edit -scratch %opt(grep_edit_diff_buffer)
            set-option buffer filetype diff
            execute-keys %(%)
            util-pipe cat %opt(grep_edit_diff_file)
            execute-keys %(%)
        )
        nop %sh(rm -f "$kak_opt_grep_edit_diff_file")
    )

define-command grep-edit-apply \
    -docstring "Apply the current selection assuming it is a diff." %( %sh(
    output=$(mktemp -d -t kak-grep-edit.XXXXXXXX)/fifo
    mkfifo ${output}
    ( printf "%s" "$kak_selection" | $kak_opt_greppathcmd > $output 2>&1 ) \
        > /dev/null 2>&1 < /dev/null &
    printf %s\\n "
        evaluate-commands -try-client '$kak_opt_toolsclient' %(
            edit! -fifo $output -scroll '$kak_opt_grep_edit_result_buffer'
            hook -group fifo buffer BufCloseFifo .* %(
                nop %sh{ rm -r $(dirname ${output}) }
                rmhooks buffer fifo
            )
        )
    "
) )

#===============================================================================
#               Convenience functions
#===============================================================================

define-command grep-edit-after \
    -docstring "Apply changes on a grep-output-like buffer to files on disk." \
    %( %sh(
        if test "$kak_bufname" != "$kak_opt_grep_edit_diff_buffer"
        then
            echo evaluate-commands -draft '%('
            echo grep-edit-diff
            echo grep-edit-apply
            echo ')'
        else
            echo grep-edit-apply
        fi
    ) )

#===============================================================================
#               Grep specific convenience functions
#===============================================================================

define-command grep-edit-select \
    -params .. \
    -docstring "Run grep, take a snapshot and select the matches." \
    %(
        with-selection-by-default grep-edit-select-explicit %arg(@)
    )

define-command grep-edit-select-explicit \
    -hidden \
    -params .. \
    -docstring "Run grep, take a snapshot and select the matches." \
    %(
        grep-sync %arg(@)
        grep-edit-select-right-hand-side %arg(1)
    )

define-command grep-edit-select-right-hand-side \
    -hidden \
    -params 1 \
    %(
        # Select the right hand sides of grep result lines.
        execute-keys -try-client %opt(toolsclient) %(%<a-s>s.*:\d+:\d+:<ret>lGL)
        # Select matches of the given argument.
        execute-keys -try-client %opt(toolsclient) s %arg(1) <ret>
    )
