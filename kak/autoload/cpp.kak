echo -debug "mine/cpp.kak is being evaluated"

hook global WinSetOption filetype=cpp %{
    set-option window indentwidth 2
}
