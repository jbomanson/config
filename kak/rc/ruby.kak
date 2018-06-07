hook global BufCreate .*([.]gemspec) %{
    set-option buffer filetype ruby
}

define-command -hidden _ruby_insert_on_new_line %{}
