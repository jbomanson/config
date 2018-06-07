# BUG:
#   Using util-pipe on % will afterward not select everything.
#   It needs to be corrected by executing % afterward again.
#   This bug is due to a bug which causes even a simple sequence like %yR to not
#   select everything in the end.
#
# DEPENDENCY:
#   misc.kak (set-register-to-file)

declare-option -hidden str util_pipe_directory

# NOTE: The caller should wrap this in evaluate-commands -itersel ... or similar
# if necessary.
define-command util-pipe \
    -params .. \
    -docstring 'Do what the pipe key "|" should do.' \
    %(
        # TODO: Try this again.
        util-pipe-single %arg(@)
        # NOTE: This has the problem that if there is a newline in the
        # arguments, the separate lines will be seen as separate commands
        # by evaluate-commands.
        # evaluate-commands -itersel "util-pipe-single %arg(@)"
    )

define-command util-pipe-single \
    -hidden \
    -params .. \
    -docstring 'Do what the pipe key "|" should do on a single selection.' \
    %(
        # evaluate-commands -itersel %(
        set-option global util_pipe_directory \
            "%sh(mktemp -d -t kak-util-pipe.XXXXXXXX)"
        %sh(
            directory="$kak_opt_util_pipe_directory"
            out="$directory/out"
            err="$directory/err"
            error=1
            failed="failed"
            if printf %s "$kak_selection" | "$@" >"$out" 2>"$err"; then
                if test -s "$err"; then
                    failed="produced output to standard error"
                elif ! test -f "$out"; then
                    failed="produced no output"
                else
                    error=0
                fi
            else
                failed="failed with status $?"
            fi
            if test "$error" -ne 0; then
                status_message="{Error}Shell command failed"
                status_message="${status_message}: see buffer *debug*"
                printf %s\\n "echo -markup '$status_message'"
                details1="This shell command $failed:"
                details2="$*"
                printf %s\\n "echo -debug %($details1)"
                printf %s\\n "echo -debug %($details2)"
                printf %s\\n "util-pipe-debug-standard-error"
            else
                printf %s\\n "util-pipe-substitute-selection"
            fi
        )
        nop %sh(rm -r "$kak_opt_util_pipe_directory")
        #)
    )

define-command util-pipe-debug-standard-error \
    -hidden \
    -docstring "Shows the error file contents in the *debug* buffer." \
    %(
        nop %sh(cat "$kak_opt_util_pipe_directory/err" >&2)
    )

define-command util-pipe-substitute-selection \
    -hidden \
    -docstring "Replaces the current selection with the output file contents." \
    %(
        evaluate-commands %(
            set-register-to-file '"' "%opt(util_pipe_directory)/out"
            execute-keys R
        )
    )
