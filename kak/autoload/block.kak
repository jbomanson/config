#===============================================================================
#               Unified mode commands
#===============================================================================

define-command block-mode \
%{
    info -title "For blocks use" "
        a,<,>: angle brackets
        B,{,}: braces
        b,(,): parenthesis
        r,[,]: brackets
        \",Q:   double quote string
        ',q:   single quote string
    "
    on-key %{ %sh{
        case $kak_key in
            'a' | '<' | '>') echo block-with-mode '<' '>' ;;
            'B' | '{' | '}') echo block-with-mode '{' '}' ;;
            'b' | '(' | ')') echo block-with-mode '(' ')' ;;
            'r' | '[' | ']') echo block-with-mode '[' ']' ;;
            '"' | 'Q') echo block-with-mode '%{"}' '%{"}' ;;
            "'" | 'q') echo block-with-mode "%{'}" "%{'}" ;;
        esac
    } }
}

declare-option str block_open (
declare-option str block_close )

define-command block-with-mode \
    -params 2 \
%{
    set-option buffer block_open %arg(1)
    set-option buffer block_close %arg(2)
    info "
        Turn
        i:     X to %opt{block_open}X%opt{block_close}
        <a-i>: X to %opt{block_open}X%opt{block_close} and select it
        o:     X to %opt{block_open}\nX\n%opt{block_close}
        r:     f(X) to f%opt{block_open}X%opt{block_close}
        Select
        m:     first %opt{block_open}X%opt{block_close} after selection
        <a-m>: first %opt{block_open}X%opt{block_close} before selection
    "
    on-key %{ %sh{
        args="%opt{block_open} %opt{block_close}"
        case $kak_key in
            'i') echo block-insert-pair $args ;;
            'o') echo block-insert-multiline $args ;;
            'r') echo block-replace-m $args ;;
            'm') echo block-select-next-pair $args ;;
            '<a-m>') echo block-select-previous-pair $args ;;
        esac
    } }
}

#===============================================================================
#               Not necessarily unified mode commands and other commands
#===============================================================================

define-command block-replace-m \
    -params 2 \
    -docstring %(Turn a pair of matching delimiters into the given ones) \
    %{
        execute-keys -draft "mZ;c%arg{2}<esc>z<a-;>;c%arg{1}<esc>"
    }

# NOTE: This only works for single character parameters.
define-command block-select-next-pair \
    -params 2 \
    -docstring %(Find the next pair of given matching characters) \
    %(
        execute-keys "f%arg(1)m"
    )

# NOTE: This only works for single character parameters.
define-command block-select-previous-pair \
    -params 2 \
    -docstring %(Find the previous pair of given matching characters) \
    %(
        execute-keys "<a-:><a-;><a-f>%arg(2)m"
    )

define-command block-insert-multiline \
    -params 2 \
    -docstring %(Insert newlines and matching delimiters around selected text) \
    %(
        evaluate-commands -itersel -no-hooks %(
            # Insert a delimiter above the current selection.
            execute-keys -save-regs "" "<a-x><a-:>Z<a-;>;<a-x>yPkgiGLa.<esc>d<a-x>yA%arg{1}<esc>"
            # Insert a delimiter below the current selection.
            execute-keys -save-regs "" "z<a-p>A%arg{2}<esc>z<gt><a-x>"
            # Expand the selection by one line in both directions.
            grow-selection
        )
    )

# TODO: This is broken for a single character selection.
define-command block-insert-pair \
    -params 2 \
    -docstring %(Surround selection with a pair of strings) \
    %{
        execute-keys -draft "Zi%arg{1}<esc>za%arg{2}<esc>"
    }

define-command block-insert-pair-inclusive \
    -params 2 \
    -docstring %(Surround selection with a pair of strings) \
    %(
        evaluate-commands -itersel -save-regs uv %(
            set-register u %arg(1)
            set-register v %arg(2)
            execute-keys %(|printf "%s" "$kak_reg_u$kak_selection$kak_reg_v"<ret>)
        )
    )

define-command peel-matching-delimiters \
    -docstring %(Turn strings such as abc{xyz{uvw}} into xyz{uvw}) \
    %{
        try %{
            # Check if the cursor is on a word that presumably names a function.
            execute-keys -draft 'm'
            execute-keys 'MZMdz;dz<a-:>H'
        }
    }

# define-command peel-function-call \
#     -docstring %(Turn calls such as abc(xyz(uvw)) into xyz(uvw)) \
#     %{
#         try %{
#             # Check if the cursor is on a word that presumably names a function.
#             execute-keys -draft '<a-i>w'
#             execute-keys '<a-i>wF(Zm;dzd'
#         } catch %{
#             try %{
#                 # Look for the next pair of surrounding punctuation.
#                 execute-keys -draft 'ww<a-i>w'
#                 execute-keys 'ww<a-i>wF(Zm;dzd'
#             } catch %{
#                 try %{
#                     # Look for a word before the next pair of parentheses.
#                     execute-keys -draft 'm<a-;>h<a-k>\w<ret><a-i>w'
#                     execute-keys 'm<a-;>h<a-k>\w<ret><a-i>wF(Zm;dzd'
#                 } catch %{
#                     echo -markup '{Error}Failed to peel function call'
#                 }
#             }
#         }
#     }

define-command peel-block \
    -docstring %(Turn code such as
    define-command a
      123
    end
into
    123) \
    %{
        execute-keys '<a-x>Zx<a-i>i<;xdzd'
    }

define-command spread-function-call \
    -docstring %(Turn abc(1, 2, 3) into
    abc(
      1,
      2,
      3,
    )) \
    %(
        execute-keys -draft %(mZ;i, extra<ret><esc>z<a-;>;a <esc>;c<ret><esc><gt>zs, <ret>s <ret>c<ret><esc> xd)
    )

define-command spread-matching-surrounding-delimiters \
    -docstring %(Turn [expression] into
    [
      expression
    ]) \
    %(
        execute-keys -draft %(mZ<a-;>;a<ret><esc>z;i<ret><esc>)
    )
