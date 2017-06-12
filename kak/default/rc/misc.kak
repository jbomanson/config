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

alias global ee extension-edit

def goto-file-relative \
    -docstring %{Go to the selected file interpreted relative to the current file} \
    %{
        goto-file-relative-almost
        exec a<backspace><tab> <ret>
    }

def goto-file-relative-almost \
    %{
        exec -save-regs ab '"ay' ':reg b <c-r>%' <ret> ':edit -scratch goto-file-relative' <ret> '"bp' <a-t> / '"aR' xH '"ay' :db! <ret> ':edit <c-r>a'
    }

def -hidden select-nearby-mode %{
  info -title %{Select nearby} %{
    #: Select nearby lines prefixed by #
    %: Select nearby lines prefixed by %
  }
  on-key %{ %sh{
    case $kak_key in
      '#') echo select-nearby-lines '^\s*#' ;;
      '%') echo select-nearby-lines '^\s*%' ;;
    esac
  }
}}

def select-nearby-lines \
    -docstring %{select-nearby-lines <string>: Select nearby lines containing <string>} \
    -params 1 \
    %(
        eval -save-regs jbwkl %(
            try %(
                exec -draft %("jZ<a-i>p<a-s>"lZ<a-k>) %arg{1} %(<ret>)
                exec %("lz<a-K>) %arg{1} %(<ret><a-m>H"kd"bZ"jz<a-i>p"wZ"bzaa<esc>h"kR"wz)
                echo
            ) catch %(
                echo -color Error Failed to select lines matching %arg{1}
            )
        )
    )

def -hidden select-custom-text-object-whole-mode %{
  info -title %{Select whole custom text object} %{
    $: dollar quote string
    i: indent and some
  }
  on-key %{ %sh{
    case $kak_key in
      '$') echo exec '<a-a>:$,$<ret>' ;;
      'i') echo select-indent-and-some-whole ;;
    esac
  }
}}

def -hidden select-custom-text-object-inner-mode %{
  info -title %{Select inner custom text object} %{
    $: dollar quote string
    i: indent and some
  }
  on-key %{ %sh{
    case $kak_key in
      '$') echo exec '<a-i>:$,$<ret>' ;;
      'i') echo exec "'<a-i>i<a-;>K<a-;><a-x>X'" ;;
    esac
  }
}}

def -hidden select-indent-and-some-whole %{
    exec '<a-a>i<a-;>K<a-;><a-x>X'
    eval -save-regs ^ %{
        try %{
            exec -save-regs %{} 'Z;/\A\n+<ret><a-z><a-m>'
        } catch %{
            exec z
            echo
        }
    }
}

def wrap-sentence \
    %(
        try %(
            exec 'gif.,w;L<a-k><space><ret>;r<ret>'
        )
        exec 'jgi'
    )

def wrap-complex \
    %(
        eval -itersel -no-hooks -save-regs %("bkmw) %(
            reg b %val(bufname)
            reg k %opt(autowrap_column)
            reg m %()
            exec -save-regs %() y
            edit -scratch *wrap-complex*
            exec R
            try %(
                # Extract a prefix from the first line.
                exec -draft %(<a-s>'<space>s^\s*(%+|#+|//+|\*+|-+|)\s*<ret><a-k><space><ret>"my)
                # Remove the prefix from all of the lines.
                exec -draft %(s^\Q<c-r>m\E<ret>d)
            )
            # Compute the desired width.
            edit -scratch *wrap-complex-size*
            exec %("m<a-P>rxAy<esc>y) %reg(k) (pgh) %reg(k) (lGLd)
            try %( exec %(xsx<ret>d) )
            exec %(gl)
            reg w %val{cursor_char_column}
            db!
            buffer *wrap-complex*
            # Join the lines.
            exec %(<a-j>)
            # Squeeze spaces.
            try %( exec %(Zs +<ret>c<space><esc>z) )
            # Wrap the selection.
            exec %(|fold --spaces --width=<c-r>w<ret>)
            # Add prefixes back.
            exec %(<a-s>gh"m<a-P>)
            # Remove any non-comment prefixes.
            try %( exec %('<a-space>s\*|-<ret>r<space>) )
            # Remove trailing spaces.
            try %(
                exec %(%s<space>+$<ret>)
                exec d
            )
            exec -save-regs %() %(%y)
            db!
            buffer %reg(b)
            exec R
        )
    )

def write-make \
    -docstring %(Write and make) \
    -params .. \
    %(
        write
        make %arg(@)
    )

alias global wmake write-make

# # NOTE: Look into e.g. kak_timestamp to detect if the buffer has been saved or
# # not.
# 
# def write-maybe \
#     -docstring %(Write or do not write) \
#     %(
#         %sh(
#             exit
#             sleep 1
# #             test "$kak_opt_readonly" = false         || exit
# #             test "$kak_opt_write_maybe_allow" = true || exit
# #             test -f "$kak_buffile"                   || exit
#             echo echo -debug "$kak_buffile ($?)"
#         )
#     )
# 
# decl bool write_maybe_allow false
# hook global NormalIdle .* %( write-maybe )
# 
# # def write-maybe-enable -params 1 -docstring "Activate automatic writing to disk"
# # def write-maybe-disable
# 
# # def lint-enable -docstring "Activate automatic diagnostics of the code" %{
# #     add-highlighter flag_lines default lint_flags
# #     hook window -group lint-diagnostics NormalIdle .* %{ lint-show }
# # }
# #
# # def lint-disable -docstring "Disable automatic diagnostics of the code" %{
# #     remove-highlighter hlflags_lint_flags
# #     remove-hooks window lint-diagnostics
# # }
# 
# # :hook [-group <group>] <scope> <hook_name> <filtering_regex> <commands>
# # NormalIdle: A certain duration has passed since last key was pressed in normal mode.
# # BufWritePost: Executed just after a buffer is written, filename is used for filtering.
# # BufOpenFile: A buffer for an existing file has been created, filename is used for filtering
# # %opt(readonly) => false/true
