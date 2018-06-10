# Detection
# ‾‾‾‾‾‾‾‾‾

hook global BufCreate .*\.fut %{
    set-option buffer filetype futhark
}

# Highlighters
# ‾‾‾‾‾‾‾‾‾‾‾‾

# Initialization
# ‾‾‾‾‾‾‾‾‾‾‾‾‾‾

hook global BufSetOption filetype=futhark %{
    set-option buffer comment_line '--'
}
