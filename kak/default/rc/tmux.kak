decl str toolsclient
decl str _tmuxpipe_origin_bufname
decl str _tmuxpipe_origin_selection_desc

# See http://www.commandlinefu.com/commands/view/3584/remove-color-codes-special-characters-with-sed
decl str stripcolorsedscript 's,\x1B\[[0-9;]*[a-zA-Z],,g'

hook global KakBegin .* %{
    %sh{
        if [ -n "$TMUX" ]; then
            echo "
                alias global pipe-send _tmux-pipe-send
            "
        fi
    }
}

def \
    -hidden \
    -docstring "Send the selected text to the repl pane and capture the result" \
    _tmux-pipe-send %{
    %sh{
        if [ -z "$TMUX" ]; then
            echo "echo -color Error This command is only available in a tmux session"
            exit
        fi
        output=$(mktemp -d -t kak-tmux-pipe.XXXXXXXX)/fifo
        mkfifo ${output}
        tmux pipe-pane \
            -t:.$(tmux show-buffer -b kak_repl_pane) \
            "
                while read -r line
                do
                    echo \"\$line\" | \
                        sed 's,\x1B\[[0-9;]*[a-zA-Z],,g' | \
                        tr -d '\r'
                done >>$output"
        printf %s\\n "eval -try-client '$kak_opt_toolsclient' %{
            send-text
            edit! -fifo ${output} -scroll *tmux-pipe*
            set buffer filetype tmux-pipe
            set buffer _tmuxpipe_origin_bufname $kak_bufname
            set buffer _tmuxpipe_origin_selection_desc $kak_selection_desc
            hook -group fifo buffer BufCloseFifo .* %{
                nop %sh{ rm -r $(dirname ${output}) }
                nop %sh{ tmux pipe-pane -t:.$(tmux show-buffer -b kak_repl_pane) }
                rmhooks buffer fifo
            }
        }"
    }
}

hook global WinSetOption filetype=tmux-pipe %{
    hook buffer -group tmux-pipe-hooks NormalKey <ret> tmux-pipe-confirm
}

hook global WinSetOption filetype=(?!tmux-pipe).* %{
    rmhooks buffer tmux-pipe-hooks
}

def -hidden tmux-pipe-confirm %{
    eval -save-regs qz %{
        try %{
            exec -draft \% <a-\;> J \"qy <esc>
            reg z %opt{_tmuxpipe_origin_selection_desc}
            buffer %opt{_tmuxpipe_origin_bufname}
            select %reg{z}
            exec -save-regs ^ \"q<a-p> Z K<a-s> i#<space><esc> z<a-x>
        }
    }
}
