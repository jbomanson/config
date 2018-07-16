# Dependency: selection-cycle.kak

define-command snippet-crystal-bracket-block \
    %(
        execute-keys -save-regs '' \
            %(A {|element| expression}<esc>Zh<a-i>Bs\w<plus><ret><a-z>a)
        selection-cycle-from-selections
    )

define-command snippet-crystal-case-when \
    %(
        execute-keys -save-regs '' \
            %(ocase value<esc>owhen condition_one then expression_one<esc>owhen condition_two then expression_two<esc>oelse expression_default<esc>oend<esc>Zkgl<a-?>value<ret><a-;>s\w<plus><ret><a-K>else|then|when<ret><a-z>a)
        selection-cycle-from-selections
    )

define-command snippet-crystal-do-end \
    %(
        execute-keys -save-regs '' \
            %(a do |index|<esc>beZoaction<esc>be<a-z>aZ oend<esc><a-z>a)
        selection-cycle-from-selections
    )

define-command snippet-crystal-if-then-else \
    %(
        execute-keys -save-regs '' \
            %(oif condition<esc>opositive_branch<esc>oelse<esc>onegative_branch<esc>oend<esc>Zkgl<a-?>condition<ret><a-;>s\w<plus><ret><a-K>else<ret><a-z>a)
        selection-cycle-from-selections
    )

define-command snippet-crystal-map-with-index \
    %(
        execute-keys -save-regs '' \
            %(ZA.map_with_index do |element, index|<esc>oexpression<esc>oend<esc><a-a><esc><a-z>uselement|\bindex|expression|d$<ret>)
        selection-cycle-from-selections
    )

define-command snippet-crystal-method \
    %(
        execute-keys -save-regs '' \
            %(o<ret>def method(argument) : ReturnType<esc>oexpression<esc>oend<esc>Zkgl<a-?>method<ret><a-;>s\w<plus><ret><a-z>a)
        selection-cycle-from-selections
    )

define-command snippet-crystal-while \
    %(
        execute-keys -save-regs '' \
            %(owhile condition<esc>oaction<esc>oend<esc>Zkgl<a-?>condition<ret><a-;>s\w<plus><ret><a-z>a)
        selection-cycle-from-selections
    )

define-command snippet-bash-if-test-exit \
    %(
        execute-keys -save-regs '' \
            %(oif test condition; then<esc>oecho "${0##*/}: error"<esc>oexit 1<esc>ofi <gt>&2<esc>Z<a-?>condition<ret><a-;>scondition|error<plus><ret><a-z>a)
        selection-cycle-from-selections
    )

define-command snippet-bash-unless-which \
    %(
        execute-keys -save-regs '' \
            %(oif ! which "$program" <gt>/dev/null; then<esc>) \
            %(o    echo "${0##*/}: missing executable \"$program\"";<esc>) \
            %(o    exit 1;<esc>) \
            %(ofi <gt>&2<esc>) \
            %(Z<a-?>which<ret><a-;>s\$program<plus><ret><a-z>a)
        selection-cycle-from-selections
    )

define-command snippet-bash-for \
    %(
        execute-keys -save-regs '' \
            %(ofor variable in list<esc>) \
            %(odo<esc>) \
            %(o    action<esc>) \
            %(odone<esc>) \
            %(Z<a-?>for<ret><a-;>svariable|list|action<plus><ret><a-z>a)
        selection-cycle-from-selections
    )

define-command snippet-bash-if \
    %(
        execute-keys -save-regs '' \
            %(oif command; then<esc>) \
            %(o    action<esc>) \
            %(ofi<esc>) \
            %(Z<a-?>if<ret><a-;>scommand|action<plus><ret><a-z>a)
        selection-cycle-from-selections
    )

define-command snippet-bash-if-then-else \
    %(
        execute-keys -save-regs '' \
            %(oif command; then<esc>) \
            %(o    positive_branch<esc>) \
            %(oelse<esc>) \
            %(o    negative_branch<esc>) \
            %(ofi<esc>) \
            %(Z<a-?>if<ret><a-;>scommand|\w<plus>_branch<plus><ret><a-z>a)
        selection-cycle-from-selections
    )

define-command snippet-bash-usage \
    %(
        execute-keys -save-regs '' \
            %(oif test $# -ne argument_count; then<esc>) \
            %(o  echo "usage: ${0##*/} expected_arguments"<esc>) \
            %(o  exit 1<esc>) \
            %(ofi >&2<esc>) \
            %(Z<a-?>if<ret><a-;>sargument_count|expected_arguments<ret><a-z>a)
        selection-cycle-from-selections
    )

define-command snippet-cpp-class \
    %(
        execute-keys -save-regs '' \
        %(\o// Description.<esc>) \
        %(\oclass Name {<esc>) \
        %(\o public:<esc>) \
        %(\o  members;<esc>) \
        %(\o<esc>) \
        %(\o private:<esc>) \
        %(\o  members;<esc>) \
        %(\o};<esc>) \
        %(Z<a-?>//<ret><a-;>sDescription|Name|members<ret><a-z>a)
        selection-cycle-from-selections
    )

define-command snippet-cpp-map-find \
    %(
        execute-keys -save-regs '' \
        %(oauto key_value_pair = map.find(key);<esc>) \
        %(oif (key_value_pair == map.end()) {<esc>) \
        %(omissing_branch;<esc>) \
        %(o}<esc>) \
        %(Z<a-?>auto<ret><a-;>smap|\bkey\b|missing_branch<ret><a-z>a)
        selection-cycle-from-selections
    )

define-command snippet-cpp-transform \
    %(
        execute-keys -save-regs '' \
        %[ostd::transform(input.begin(), input.end(),<esc>] \
        %[ostd::back_inserter(output), [](const Element& element) {<esc>] \
        %[oreturn element;<esc>] \
        %[o})<esc>] \
        %(Z<a-?>transform<ret><a-;>sinput|output|Element|element<ret><a-z>a)
        selection-cycle-from-selections
    )
