hook global WinSetOption filetype=latex %{
  set window indentwidth 2
  set window tabstop 2
  decl str completion_extra_word_char %{:-}
}
