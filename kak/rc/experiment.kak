#===============================================================================
# EXPERIMENT:
# Determine whether the BufReadFifo hook can be used to detect cases where e.g.
# the output of grep is put in a *grep* buffer.
# OUTCOME:
# Not as of 2018-02-13.
# The hook appears to be called only sometimes--namely, whenever the buffer
# needs to be created or recreated.
#===============================================================================

# declare-option int fifo_diff_timestamp 0
# declare-option str hell "false"
# 
# # executed after some data has been read from a fifo and inserted in the buffer
# hook global BufReadFifo .* %(
#     # echo -debug "Ran BufReadFifo"
#     set-option global hell "true"
#     set-option buffer fifo_diff_timestamp "%val(timestamp)"
# )
# 
# # TODO: Use history-undo-diff to make a diff.
# # TODO: Make a version of it that supports timestamps in addition to counts.
# 
# define-command fifo_diff %(
#         echo "%sh(expr \"$kak_timestamp\" - \"$kak_opt_fifo_diff_timestamp\")"
#     )
