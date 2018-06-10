hook global WinSetOption filetype=c %{
  set-option window indentwidth 8
  set-option window aligntab true
}

define-command -override -hidden _c-family-insert-include-guards %{
    %sh{
        case "${kak_opt_c_include_guard_style}" in
            ifdef)
                echo 'execute-keys ggi<c-r>%<ret><esc>ggx~Ia<esc>xs^a(SRC/)?<ret>dxs/|\.<ret>c_<esc><space>ggxypI#ifndef<space><esc>jI#define<space><esc>jI#endif<esc>'
                ;;
            pragma)
                echo 'execute-keys ggi#pragma<space>once<esc>'
                ;;
            *);;
        esac
    }
}
