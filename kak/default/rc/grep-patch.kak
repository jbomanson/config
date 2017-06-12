decl str greppatchbuffer "*grep-patch*"
decl str greppathcmd 'patch -p0'
decl str toolsclient

def grep-patch-before \
  -docstring "Save grep result lines in anticipation of a change.
The lines will be used when grep-patch-after is called." %{
    eval -collapse-jumps -draft %{
        exec -save-regs %() %(%y)
        edit -scratch %opt{greppatchbuffer}
        set buffer filetype ""
        exec -save-regs %() %(%R)
    }
}

def grep-patch-after \
    -docstring "Make a diff." %{
    eval -collapse-jumps %{
        # Copy nonempty "after" lines.
        exec -save-regs %() %(%<a-s><a-k>..<ret>y)
        buffer %opt{greppatchbuffer}
        set buffer filetype diff
        # Interleave nonempty "before" and "after" lines.
        exec -save-regs %() %(%<a-s><a-k>..<ret>p)
        # Add diff file headers for each pair of lines.
        exec -save-regs %() %(ghi---<space><esc>/:(\d+):\d+:<ret>c<ret><esc>k<a-x>ypjgh<a-i>Wc+++<esc>)
        # Add hunk headers.
        exec -save-regs %() %(o@@ -<c-r>1,1 +<c-r>1,1 @@<esc>)
        # Add prefixes and clean up garbage.
        exec %(jghi-<esc>jgh3f:c+<esc>)
        # Delete repetitive headers.
        try %{
            exec %(%s-{3} ([^\n]*).*\1<ret>)
            exec %(<a-;>JJ<a-s><a-k>^(-{3}|\+{3})<ret><a-x>d)
        }
        exec %(%)
    }
}

def grep-patch-apply %{ %sh{
    output=$(mktemp -d -t kak-grep-patch.XXXXXXXX)/fifo
    mkfifo ${output}
    ( printf "%s" "$kak_selection" | $kak_opt_greppathcmd > $output 2>&1 ) \
        > /dev/null 2>&1 < /dev/null &
    printf %s\\n "
        eval -try-client '$kak_opt_toolsclient' %{
            edit! -fifo $output -scroll *grep-patch-result*
            hook -group fifo buffer BufCloseFifo .* %{
                nop %sh{ rm -r $(dirname ${output}) }
                rmhooks buffer fifo
            }
        }
    "
}}
