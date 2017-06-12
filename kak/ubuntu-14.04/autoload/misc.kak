hook global WinCreate .* %{addhl number_lines -relative}

# See https://github.com/mawww/kakoune/wiki/How-To#expand-tabs-to-spaces-when-tab-is-pressed
hook global WinSetOption tabstop=8 %{ rmhooks window misc-expand-tabs }
hook global WinSetOption tabstop=(?!8) %{ hook -group misc-expand-tabs window InsertChar \t %{ exec -draft -itersel h@ } }

# See https://github.com/mawww/kakoune/wiki/Fuzzy-finder#git
def git-edit \
    -params 1 \
    -shell-candidates %{ git ls-files } \
    -docstring %{git-edit <filename>: open the given filename in a buffer } \
    %{ edit %arg{1} }

# See https://github.com/mawww/kakoune/issues/655
def find-edit \
    -params 1 \
    -shell-candidates %{ find . -type f } \
    -docstring %{find-edit <filename>: open the given filename in a buffer } \
    %{ edit %arg{1} }

def extension-edit \
    -params 1 \
    -shell-candidates %{ ag -g '.*\Q.'"${kak_bufname##*.}"'\E' } \
    -docstring %{extension-edit <filename>: open the given filename in a buffer } \
    %{ edit %arg{1} }
