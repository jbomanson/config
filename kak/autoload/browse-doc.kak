declare-option str-list browse_doc_path
declare-option str browse_doc_viewer elinks
declare-option str browse_doc_url_suffix

define-command browse-doc-ag \
    -params 1 \
    -shell-candidates %{
        ag --follow --html -u -g . . $(echo "${kak_opt_browse_doc_path}" | tr ':' ' ')
    } \
    -docstring "browse-doc-ag <url>: opens <url> in another tmux pane using a browser
Uses ag to suggest html file candidates." \
    %{ browse-doc-file %arg(@) }

define-command browse-doc-file \
    -params 1 \
    -file-completion \
    -docstring "browse-doc <url>: opens <url> in another tmux pane using a browser" \
    %{ %sh{
        tmux new-window "$kak_opt_browse_doc_viewer '$1$kak_opt_browse_doc_url_suffix'"
    }}
