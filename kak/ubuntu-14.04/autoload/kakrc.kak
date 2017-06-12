def kak-eval -docstring 'Evaluate selections as kak commands' %{
    exec -no-hooks -itersel -save-regs @ y : <c-r>" <ret>
}

def kak-eval-override-def -docstring 'Evaluate selections with -allow-override added to definitions' %{
    # NOTE: This makes changes in the current buffer and then undoes them.
    # This seems to work well otherwise, but messes up the redo key U.
    exec -draft -no-hooks -itersel -save-regs @^ y <a-p> Z s^\h*def<space> <ret> a -allow-override<space> <esc> z : kak-eval <ret> u
}
