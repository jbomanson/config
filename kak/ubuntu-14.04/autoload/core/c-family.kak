hook global WinSetOption filetype=c %{
  set window indentwidth 8
  set window aligntab true
}

def -allow-override -hidden _c-family-insert-include-guards %{
    %sh{
        case "${kak_opt_c_include_guard_style}" in
            ifdef)
                echo 'exec ggi<c-r>%<ret><esc>ggx~Ia<esc>xs^a(SRC/)?<ret>dxs/|\.<ret>c_<esc><space>ggxypI#ifndef<space><esc>jI#define<space><esc>jI#endif<esc>'
                ;;
            pragma)
                echo 'exec ggi#pragma<space>once<esc>'
                ;;
            *);;
        esac
    }
}
