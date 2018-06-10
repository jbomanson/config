# See https://github.com/mawww/kakoune/wiki/How-To#use-ag-or-ack-as-the-grep-program
set-option global grepcmd 'ag --column'

# Show some number of context lines above and below the cursor.
set-option global scrolloff 10,0
