#! /bin/bash

if ! [[ "$PREFIX" ]]; then
    echo "Please set \$PREFIX so that ./\$PREFIX/share/kak exists."
    echo "Only relative paths are supported."
    echo "Modify $0 if absolute paths are necessary."
    exit 1
fi

ln --no-dereference --no-target-directory --symbolic rc kak/default/autoload

t="../../../$PREFIX/share/kak/autoload"
ln --no-dereference --no-target-directory --symbolic "$t" kak/default/rc/stock
ln --no-dereference --no-target-directory --symbolic "$t" kak/ubuntu-14.04/autoload/stock
