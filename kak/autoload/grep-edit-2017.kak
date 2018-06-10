# # BUG:
# #   Absolute paths are usually rejected by the patch program for security
# #   reasons. Absolute paths can be made to work by passing --directory=/ as
# #   an argument to patch, but in that case relative paths will stop working.
# #   A possible solution would be to turn all paths into absolute ones first.
# 
# # WISH:
# #   The patch program has a --dry-run option.
# #   Add an option to use it.
# 
# # WISH:
# #   Delete unseen intermediate files in grep-edit-after.
# 
# # DEPENDENCY:
# #   with-selection-by-default.kak
# 
# declare-option str greppatchbuffer "*grep-edit*"
# declare-option str greppatchresultbuffer "*grep-edit*"
# declare-option str greppathcmd 'patch -p0'
# declare-option str toolsclient
# 
# #===============================================================================
# #               Core functions
# #===============================================================================
# 
# define-command grep-edit-before \
#   -docstring "Mark the beginning of changes to grep result lines.
# The lines will be used when grep-edit-after is called." %(
#     evaluate-commands -draft %(
#         execute-keys -save-regs %() %(%y)
#         edit -scratch %opt(greppatchbuffer)
#         set-option buffer filetype ""
#         execute-keys -save-regs %() %(%R)
#     )
# )
# 
# define-command grep-edit-diff \
#     -docstring "Make a diff between the state before and since grep-edit-before
# was called." %(
#     evaluate-commands -try-client %opt(toolsclient) %(
#         # Copy nonempty "after" lines.
#         execute-keys -save-regs %() %(%<a-s><a-k>..<ret>y)
#         buffer %opt{greppatchbuffer}
#         set-option buffer filetype diff
#         # Interleave nonempty "before" and "after" lines.
#         execute-keys -save-regs %() %(%<a-s><a-k>..<ret>p)
#         # Add diff file headers for each pair of lines.
#         execute-keys -save-regs %() %(ghi---<space><esc>/:(\d+):\d+:<ret>c<ret><esc>k<a-x>ypjgh<a-i>Wc+++<esc>)
#         # Add hunk headers.
#         execute-keys -save-regs %() %(o@@ -<c-r>1,1 +<c-r>1,1 @@<esc>)
#         # Add prefixes and clean up garbage.
#         execute-keys %(jghi-<esc>jgh3f:c+<esc>)
#         # Delete repetitive headers.
#         try %{
#             execute-keys %(%s-{3} ([^\n]*).*\1<ret>)
#             execute-keys %(<a-;>JJ<a-s><a-k>^(-{3}|\+{3})<ret><a-x>d)
#         }
#         execute-keys %(%)
#     )
# )
# 
# define-command grep-edit-apply \
#     -docstring "Apply the current selection assuming that it is a diff." %( %sh(
#     output=$(mktemp -d -t kak-grep-edit.XXXXXXXX)/fifo
#     mkfifo ${output}
#     ( printf "%s" "$kak_selection" | $kak_opt_greppathcmd > $output 2>&1 ) \
#         > /dev/null 2>&1 < /dev/null &
#     printf %s\\n "
#         evaluate-commands -try-client '$kak_opt_toolsclient' %(
#             edit! -fifo $output -scroll '$kak_opt_greppatchresultbuffer'
#             hook -group fifo buffer BufCloseFifo .* %(
#                 nop %sh{ rm -r $(dirname ${output}) }
#                 rmhooks buffer fifo
#             )
#         )
#     "
# ) )
# 
# #===============================================================================
# #               Convenience functions
# #===============================================================================
# 
# define-command grep-edit-after \
#     -docstring "Save to disk the changes initiated by a grep-edit-before." \
#     %( %sh(
#         if test "$kak_bufname" != "$kak_opt_greppatchbuffer"
#         then
#             echo evaluate-commands -draft '%('
#             echo grep-edit-diff
#             echo grep-edit-apply
#             echo ')'
#         else
#             echo grep-edit-apply
#         fi
#     ) )
# 
# define-command grep-edit-select \
#     -params .. \
#     -docstring "Run grep, take a snapshot and select the matches." \
#     %(
#         with-selection-by-default grep-edit-select-explicit %arg(@)
#     )
# 
# define-command grep-edit-select-explicit \
#     -hidden \
#     -params .. \
#     -docstring "Run grep, take a snapshot and select the matches." \
#     %(
#         grep-sync %arg(@)
#         grep-edit-before
#         grep-edit-select-right-hand-side %arg(1)
#     )
# 
# define-command grep-edit-select-right-hand-side \
#     -hidden \
#     -params 1 \
#     %(
#         # Select the right hand sides of grep result lines.
#         execute-keys -try-client %opt(toolsclient) %(%<a-s>s.*:\d+:\d+:<ret>lGL)
#         # Select matches of the given argument.
#         execute-keys -try-client %opt(toolsclient) s %arg(1) <ret>
#     )
# 
# # NOTE: I became too lazy to maintain these. The grep-edit-select-fixed is
# # broken because it tries to use with-selection-by-default directly. It would
# # have to define an auxiliary command and call it instead.
# 
# # define-command grep-edit-select-fixed \
# #     -params .. \
# #     -docstring "Run grep without regex matching, take a snapshot and select the
# # matches." \
# #     %(
# #         with-selection-by-default %(
# #             grep-sync --fixed-strings %arg(@)
# #             grep-edit-before
# #             grep-edit-select-fixed-right-hand-side %arg(1)
# #         )
# #     )
# # 
# # define-command grep-edit-select-fixed-right-hand-side \
# #     -hidden \
# #     -params 1 \
# #     %(
# #         # Select the right hand sides of grep result lines.
# #         execute-keys -try-client %opt(toolsclient) %(%<a-s>s.*:\d+:\d+:<ret>lGL)
# #         # Select matches of the given argument.
# #         execute-keys -try-client %opt(toolsclient) %(s\Q) %arg{1} %(\E) <ret>
# #     )
