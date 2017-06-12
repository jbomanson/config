hook global BufCreate .*\.txt %{
    map buffer user e %(:plain-bash-line<ret>)
}

# hook global BufSetOption mimetype=text/plain %{
#     map buffer user e %(:plain-bash-line<ret>)
# }

def plain-bash-line -docstring 'Evaluate the line where the cursor ends with bash and insert the result with comments' %{
    exec -itersel -save-regs qz %(<space>;X"zy"z<a-p>H|<c-r>z<backspace><ret>"qZ<a-s>ghi#<space><esc>"qz<a-x>)
}
