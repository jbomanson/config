hook global BufCreate .*([.]gemspec) %{
    set buffer filetype ruby
}

def -hidden _ruby_insert_on_new_line %{}
