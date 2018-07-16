map global insert å <esc>
map global prompt å <esc>
map global view å <esc>

map global insert § <c-r>
map global prompt § <c-r>
map global view § <c-r>

map global user a -docstring "Select whole object"                           %(:select-custom-text-object-whole-mode<ret>)
map global user b -docstring "Do a block action"                             %(:block-mode<ret>)
map global user c -docstring "Do a character based action"                   %(:character-mode<ret>)
map global user %(%) -docstring "Select all copies of the current selection" %(:select-all-copies<ret>)
# map global user f -docstring "Do a character based find action"              %(:find-mode<ret>)
map global user g -docstring "A placeholder for language specific shortcuts" %(:info "Filetype %opt{filetype} lacks g shortcuts"<ret>)
map global user i -docstring "Select inner object"                           %(:select-custom-text-object-inner-mode<ret>)
map global user l -docstring "Do a linewise action"                          %(:linewise-mode<ret>)
map global user n -docstring "Select nearby lines by comment prefix"         %(:select-nearby-lines-by-prefix "%opt(comment_line)"<ret>)
map global user N -docstring "Select nearby lines by prefix"                 %(:select-nearby-mode<ret>)
map global user r -docstring "Do a repl related action"                      %(:repl-related-mode<ret>)
map global user C -docstring "Use the current client ..."                    %(:client-mode<ret>)
map global user s -docstring "Do a system cliboard operation"                %(:system-clipboard-mode<ret>)
map global user x -docstring "Do a tmux buffer(=clipboard) operation"        %(:tmux-clipboard-mode<ret>)
map global user t -docstring "Do a general operation"                        %(:general-mode<ret>)
map global user W -docstring "Wrap a sentence to 80 columns"                 %(:wrap-sentence<ret>)
map global user w -docstring "Wrap text to 80 columns"                       %(:wrap-with-ruby<ret>)
map global user d -docstring "Make a commented duplicate paragraph"          %(Z<a-a>py<a-p><a-;><a-i>p,lic<a-a>p"dZz)

# Source: github user lenormf in a comment to https://github.com/mawww/kakoune/issues/1272
map global user '/'     -docstring "case insensitive search"                 /(?i)
map global user '<a-/>' -docstring "case insensitive backward search"        <a-/>(?i)
map global user '?'     -docstring "case insensitive extend search"          ?(?i)
map global user '<a-?>' -docstring "case insensitive backward extend-search" <a-?>(?i)

# Source: github user mawww in a comment to https://github.com/mawww/kakoune/issues/1749
map global object o -docstring "do end block" cdo,end<ret>

map global object I -docstring "indent and some" 'i<a-;>K<a-;><a-x>X'
map global object l -docstring "line content" <esc>gi<a-l>
# This is automatically there.
# map global object $ -docstring "dollar quote string" c$,$<ret>

map global object d -docstring "paragraph and indent" \
    '<esc>:select-paragraph-and-indent<ret>'

hook global NormalIdle .* colorscheme-by-hour-rate-limited

# See https://github.com/alexherbo2/dotfiles/blob/master/kak/kakrc
hook global BufCreate [*]grep[*] %{ map -- global normal - ':grep-next-match<ret>' }
hook global BufCreate [*]make[*] %{ map -- global normal - ':make-next-error<ret>' }

# See https://github.com/mawww/kakoune/wiki/How-To#expand-tabs-to-spaces-when-tab-is-pressed
hook global WinSetOption tabstop=8 %{ rmhooks window misc-expand-tabs }
hook global WinSetOption tabstop=(?!8) %{ hook -group misc-expand-tabs window InsertChar \t %{ execute-keys -draft -itersel h@ } }

hook global WinCreate .* %(add-highlighter window number_lines -relative -hlcursor)
hook global WinCreate .* %(matching-column-enable-autocomplete)

# This is too distracting. The highlighting for the matching bracket dominates
# the actual selection.
# add-highlighter global show_matching

# This creates a highlighter with the id "window/hlcol_81".
hook global WinSetOption filetype=(?!man).* %(add-highlighter window column 81 default,yellow)
hook global WinSetOption filetype=(man|) %(remove-highlighter window/hlcol_81)

# TODO: Write a docstring.
# alias global ag grep
define-command ag -params .. %(with-selection-by-default grep %arg(@))

# BUG: The following does not include the last newline: xX<a-;>K
# Hmmm... I think it does work now at 2017-12-01.
#
# TODO: Put shell scripts etc in some location relative to the following,
# and call them like: evaluate-commands "|%opt(X)/my-script.sh"
# where X would be defined like this perhaps:
# set-option str X %sh(echo "$kak_source")
# nop %sh(echo "$kak_source" >>/tmp/vv.txt)

# TODO: Add rc/clipboard.kak and put xclip & tmux based copying in there.
# Make them unified in a similar way as is done in rc/block.kak.
#

define-command select-all-copies %(execute-keys %(y%s\Q<c-r>"\E<ret>))
