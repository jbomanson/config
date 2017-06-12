hook global WinSetOption filetype=man %{
    # This is a compromise that alleviates width issues with MANWIDTH in
    # rc/core/man.kak and number_lines in rc-plus/misc-options.kak.
    rmhl number_lines
}
