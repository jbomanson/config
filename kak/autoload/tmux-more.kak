#===============================================================================
#		Snippets
#===============================================================================

# # Getting the current command in a pane, such as "bash"
# tmux display-message -p -t '%9' "#{pane_current_command}"
# 
# # Getting the current command in a pane, such as "/tmp".
# # This changes e.g. in bash when you do cd.
# # This could be useful in e.g. synchronizing the current working directory
# # of kak with the repl pane.
# tmux display-message -p -t '%9' "#{pane_current_path}"
# 
# # Unique pane id, such as "%9".
# # This is similar to "#{pane_index} (i.e., "#P"), but "#P" changes sometimes.
# # It is still necessary to play with window ids as well.
# # I think it would be more useful to use this than window_id + pane thingy.
# tmux display-message -p -t '%9' "#{pane_id}"

# Make it so that a pane is in default mode as opposed to copy mode.
# tmux copy-mode -t '@1' ';' send-keys -t '@1' -X cancel
#
# Send keys to a window from kak.
# nop %sh(tmux send-keys -t "@1" "echo Hello world" Enter)
#
# Print hello world twice in a tmux pane from kak.
# nop %sh(tmux send-keys -t "@1" "echo Hello world" Enter Up Enter)
#
# Sleep for a second in a tmux pane and then report back to kak.
# nop %sh(tmux send-keys -t "@1" "sleep 1" Enter " echo 'evaluate-commands -client ${kak_client} %{ echo Done }' | kak -p ${kak_session}" Enter)
#
# Sleep for a second in the next tmux window and then report back to kak.
# nop %sh(tmux send-keys -t "{next}.0" "sleep 1" Enter " echo 'evaluate-commands -client ${kak_client} %{ echo Done }' | kak -p ${kak_session}" Enter)
#
# Repeat the previous command in the next tmux window and then report back to kak.
# nop %sh(tmux send-keys -t "{next}.0" Up Enter " echo 'evaluate-commands -client ${kak_client} %{ echo Done }' | kak -p ${kak_session}" Enter)
#
# Repeat the previous command in the next tmux window and then report back to kak v2.
# nop %sh(tmux copy-mode -t "{next}.0" ';' send-keys -t "{next}.0" -X cancel ';' send-keys -t "{next}.0" Up Enter " echo 'evaluate-commands -client ${kak_client} %{ echo Done }' | kak -p ${kak_session}" Enter)

#===============================================================================
#               Modes
#===============================================================================

# Improvement idea:
# Determine prefix to be removed intelligently based on the original selection,
# the output, and in particular the part of the output before the content of
# the original selection first appears, and the last line of the output.

#===============================================================================
#		Synchronous tmux-pipe
#===============================================================================

# NOTE: This stopped working quickly after this was working perfectly.
# NOTE: Then after a while this started working again perfectly.
#
# BUG: This only works if there is no empty space at the end of the pane.
#
# TODO: There are most certainly problems when the tmux pane history saturates.

# Other example values:
# set-option current tmux_pipe_wait_command "bash -c 'read; read -t 1.0'"
# set-option current tmux_pipe_wait_command "head -n2 >/dev/null"
declare-option str tmux_pipe_wait_command "bash -c 'read && read -t 2.0 && while read -t 0.1; do true; done'"

# declare-option str tmux_pipe_nl_command %(awk '/^$/ {nlstack=nlstack "\n";next;} {printf "%s",nlstack; nlstack=""; print;}')

# This is version 4 of tmux-send-and-capture.
# This uses tmux pipe-pane to monitor detect something happens in the repl pane.
# Then, this uses tmux capture-pane to get the pane contents.
# These contents are trimmed by deleting a number of lines that were previously
# known to be in the pane.
define-command tmux-pipe \
    -docstring %(Send selection to the repl pane and capture the output) \
    %(
        evaluate-commands -save-regs ld %(
            # Save the current number of history lines.
            set-register l \
                "%sh(tmux capture-pane -J -t \"$kak_opt_tmux_repl_pane_id\" -p -S- | wc -l)"
            %sh(
                dir=$(mktemp -d "${TMPDIR:-/tmp}"/kak-tmux-pipe.XXXXXXXX)
                mkfifo ${dir}/fifo
                 tmux pipe-pane -t "$kak_opt_tmux_repl_pane_id" \
                     "$kak_opt_tmux_pipe_wait_command; echo >${dir}/fifo"
                printf "%s\n" "set-register d $dir"
            )
            tmux-send-text
            nop %sh(
                dir=$kak_reg_d
                cat ${dir}/fifo
                rm -rf ${dir}
            )
            execute-keys %(
                |tmux capture-pane -J -t "$kak_opt_tmux_repl_pane_id" -p -S-
                | tee /tmp/oho.txt
                | tail -n+"$kak_reg_l"
                <ret>
                <a-x>
            )
            echo tmux-pipe complete
        )
    )

#===============================================================================
#		Asynchronous tmux-pipe-async
#===============================================================================

# IDEA: This asynchronous version could be updated to return its result the same
# way linters do.

# TODO: hide
declare-option str tmux_pipe_async_history

# This is version 4 of tmux-send-and-capture.
# This uses tmux pipe pane to monitor detect something happens in the repl pane.
# Then, this uses tmux capture-pane to get the pane contents.
# These contents are trimmed by deleting a number of lines that were previously
# known to be in the pane.
define-command tmux-pipe-async \
    -docstring %(Send selection to the repl pane and capture the output) \
    %(
        evaluate-commands %(
            # Save the current number of history lines.
            set-option buffer tmux_pipe_async_history \
                "%sh(tmux capture-pane -J -t \"$kak_opt_tmux_repl_pane_id\" -p -S- | wc -l)"
            nop %sh(
                # The head command determines how many lines must be output
                # before the other commands are executed.
                # The %%s is used to escape %s from tmux.
                tmux pipe pane -t "$kak_opt_tmux_repl_pane_id" \
                    "head -n2 >/dev/null; printf '%%s\n' \"evaluate-commands -client $kak_client tmux-pipe-async-callback\" | kak -p \"$kak_session\""
            )
            tmux-send-text
        )
    )

# A helper command for tmux-pipe-async
define-command tmux-pipe-async-callback \
    -hidden \
    %(
        execute-keys %(
            |tmux capture-pane -J -t "$kak_opt_tmux_repl_pane_id" -p -S-
            | tail -n+"$kak_opt_tmux_pipe_async_history"
            <ret>
            <a-x>
        )
        echo tmux-pipe-async complete
    )

#===============================================================================
#
#===============================================================================

# I tweaked at this for hours, but with no luck.
# The thing with tmux pipe-pane is that it includes color codes, which seem to
# be difficult to get rid of.
# I tried more than half a dozen sed scripts from stack overflow and elsewhere,
# but none got rid of all of the magic.
#
# # See http://www.commandlinefu.com/commands/view/3584/remove-color-codes-special-characters-with-sed
# declare-option str stripcolorsedscript 's,\x1B\[[0-9;]*[a-zA-Z],,g'
# 
# set-option current stripcolorsedscript 's,\x1B\[[0-9;]*[a-zA-Z],,g'
# 
# # This is version 3 of tmux-send-and-capture.
# define-command tmux-pipe \
#     -docstring %(Send selection to the repl pane and capture the output) \
#     %(
#         evaluate-commands %(
#             nop %sh(tmux pipe-pane -t "$kak_opt_tmux_repl_pane_id" "cat >/tmp/kak-tmux-pipe")
#             # nop %sh(tmux pipe-pane -t "$kak_opt_tmux_repl_pane_id" "sed -r \"$kak_opt_stripcolorsedscript\" >/tmp/kak-tmux-pipe")
#             tmux-send-text
#             nop %sh{ sleep 0.5 }
#             nop %sh(tmux pipe-pane -t "$kak_opt_tmux_repl_pane_id")
#             execute-keys %(|cat /tmp/kak-tmux-pipe<ret>)
#             # execute-keys %(|sed "${kak_opt_stripcolorsedscript}" /tmp/kak-tmux-pipe<ret>)
#             # execute-keys %(|cat /tmp/kak-tmux-pipe>/tmp/d.txt<ret>)
#             # execute-keys %(|wc /tmp/kak-tmux-pipe<ret>)
#         )
#     )

# Strategy:
# Before and after sending text, execude something like:
# tmux capture-pane -J -t "$kak_opt_tmux_repl_pane_id" -p >/tmp/www-1.txt
# tmux capture-pane -J -t "$kak_opt_tmux_repl_pane_id" -p >/tmp/www-2.txt
# Then get the new lines with: diff /tmp/www-{1,2}.txt | grep -Po '(?<=> ).*'
# This would have the benefit of not requiring the screen to be cleared.
#
# true && tmux pipe-pane -t "$kak_opt_tmux_repl_pane_id" 'cat >/tmp/output.#I-#P'

# # This is version 2 of tmux-send-and-capture.
# define-command tmux-pipe \
#     -docstring %(Send selection to the repl pane and capture the output) \
#     %(
#         evaluate-commands %(
#             %sh(tmux capture-pane -J -t "$kak_opt_tmux_repl_pane_id" -p >/tmp/kak-tmux-pipe-1.txt)
#             tmux-send-text
#             %sh{ sleep 0.5 }
#             %sh(tmux capture-pane -J -t "$kak_opt_tmux_repl_pane_id" -p >/tmp/kak-tmux-pipe-2.txt)
#             execute-keys %(
#                 |diff /tmp/kak-tmux-pipe-1.txt /tmp/kak-tmux-pipe-2.txt | grep -Po '(?<=> ).*'
#                 <ret>
#             )
#         )
#     )

define-command tmux-capture-pane \
    -hidden \
    -docstring %(Replace the selection with tmux repl pane contents) \
    %(
        evaluate-commands %(
            # -J joins wrapped lines and preserves trailing spaces
            execute-keys %(
                |tmux capture-pane -J -t "$kak_opt_tmux_repl_pane_id" -p<ret>
            )
            # Trim the output by removing lines below the cursor in the repl pane.
            execute-keys %(
                |head -n$(
                    tmux display-message -p -t "$kak_opt_tmux_repl_pane_id" '#{cursor_y}'
                )
                <ret>
            )
        )
    )

define-command tmux-send-and-capture \
    -docstring %(Send selection to the repl pane and capture and convert the
output) \
    %(
        evaluate-commands %(
            tmux-pipe
            convert-shell-output-to-input
        )
    )

# This is an earlier version of tmux-send-and-capture that did not use tmux-pipe.
# This had to use clear and a wait.
# define-command tmux-send-and-capture \
#     -docstring %(Send selection to the repl pane and capture and convert the
# output) \
#     %(
#         evaluate-commands %(
#             tmux-send-param "clear
# "
#             tmux-send-text
#             %sh{ sleep 0.5 }
#             tmux-capture-pane
#             convert-shell-output-to-input
#         )
#     )

# This is like tmux-send-text, but where tmux-send-text sends the current
# selection, this sends a given parameter.
define-command tmux-send-param \
    -hidden \
    -params 1 \
    -docstring "Send a single parameter to the repl pane" %{
    nop %sh{
        tmux set-buffer -b kak_selection "${1}"
        kak_orig_window_id=$(tmux display-message -p '#{window_id}')
        kak_orig_pane_id=$(tmux display-message -p '#{pane_id}')
        tmux select-window -t "$kak_opt_tmux_repl_window_id"
        tmux select-pane -t "$kak_opt_tmux_repl_pane_id"
        tmux paste-buffer -b kak_selection
        tmux select-window -t "${kak_orig_window_id}"
        tmux select-pane -t "${kak_orig_pane_id}"
    }
}

# Perhaps a bit redundant.
# define-command tmux-send-and-capture-and-convert-shell-output-to-input \
#     -docstring %(Send selection to the repl pane, capture the output, and
# convert the output to shell input format) \
#     %(
#         tmux-send-and-capture
#         convert-shell-output-to-input
#     )

define-command tmux-shell-step \
    -docstring %(Send selection to the repl, capture and convert the output,
step over it.) \
    %(
        evaluate-commands %(
            tmux-send-and-capture
            execute-keys x
        )
    )

define-command tmux-repeat-most-recent-command-in-next-window \
    -docstring "" \
    %(
        nop %sh(
            tmux copy-mode -t "{next}.0" ';' \
                send-keys -t "{next}.0" -X cancel ';' \
                send-keys -t "{next}.0" Up Enter " echo 'evaluate-commands -client ${kak_client} %{ echo Done }' | kak -p ${kak_session}" Enter
        )
    )
