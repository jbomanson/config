hook global WinSetOption filetype=latex %{
  set-option window indentwidth 2
  set-option window tabstop 2
  set-option window extra_word_chars %{\::-}
  map buffer user e -docstring %(Insert \errorcontextlines 10000) %(i\errorcontextlines 10000<esc>)
  # autowrap-enable
  autowrap-disable
}

