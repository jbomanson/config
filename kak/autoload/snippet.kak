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

define-command snippet-cpp-absl-str-join \
    %(
        execute-keys -save-regs '' \
        %<oabsl::StrJoin(<esc>> \
        %<ocontainer, ", ",<esc>> \
        %<o[](string* out, const Element& element) {<esc>> \
        %<oabsl::StrAppend(out, "'");<esc>> \
        %<oabsl::StrAppend(out, element);<esc>> \
        %<oabsl::StrAppend(out, "'");<esc>> \
        %<o})<esc>> \
        %(Z<a-?>Join<ret><a-;>scontainer|", "|Element|element<ret><a-z>a)
        selection-cycle-from-selections
    )

define-command snippet-cpp-algorithm-accumulate \
    %(
        execute-keys -save-regs '' \
        %[gl"qZ] \
        %[ostd::accumulate(input.begin(), input.end(),<esc>] \
        %[oinit, [](const Result result, const Element& element) {<esc>] \
        %[oreturn result;<esc>] \
        %[o});<esc>] \
        %[Z"q<a-z>usinput|init|Result|result|Element|element<ret><a-z>a]
        selection-cycle-from-selections
    )

define-command snippet-cpp-algorithm-all-of \
    %(
        execute-keys -save-regs '' \
        %[gl"qZ] \
        %[ostd::all_of(input.cbegin(), input.cend(),<esc>] \
        %[o[](const Element& element) {<esc>] \
        %[oreturn true;<esc>] \
        %[o})<esc>] \
        %[Z"q<a-z>usinput|Element|element|true<ret><a-z>a]
        selection-cycle-from-selections
    )

define-command snippet-cpp-algorithm-copy \
    %(
        execute-keys -save-regs '' \
        %[ostd::copy(input.begin(), input.end(),<esc>] \
        %[ostd::back_inserter(output));<esc>] \
        %(Z<a-?>copy<ret><a-;>sinput|output<ret><a-z>a)
        selection-cycle-from-selections
    )

define-command snippet-cpp-algorithm-equal \
    %(
        execute-keys -save-regs '' \
        %[gl"qZ] \
        %[o(one.size() == two.size()) &&<esc>] \
        %[ostd::equal(one.begin(), one.end(),<esc>] \
        %[otwo.begin(), two.end(),<esc>] \
        %[o[](const Element& a, const Element& b) {<esc>] \
        %[oreturn a.property() == b.property();<esc>] \
        %[o});<esc>] \
        %[Z"q<a-z>usone|two|Element|property\(\)<ret><a-z>a]
        selection-cycle-from-selections
    )

define-command snippet-cpp-algorithm-map-find \
    %(
        execute-keys -save-regs '' \
        %(oauto key_value_pair = map.find(key);<esc>) \
        %(oif (key_value_pair == map.end()) {<esc>) \
        %(omissing_branch;<esc>) \
        %(o}<esc>) \
        %(Z<a-?>auto<ret><a-;>smap|\bkey\b|missing_branch<ret><a-z>a)
        selection-cycle-from-selections
    )

define-command snippet-cpp-algorithm-sort \
    %(
        execute-keys -save-regs '' \
        %[ostd::sort(input.begin(), input.end(),<esc>] \
        %[o[](const Element& a, const Element& b) {<esc>] \
        %[oreturn a.property() <lt> b.property();<esc>] \
        %[o});<esc>] \
        %(Z<a-?>sort<ret><a-;>sinput|Element|property\(\)|<lt><ret><a-z>a)
        selection-cycle-from-selections
    )

define-command snippet-cpp-algorithm-simple \
    %(
        execute-keys -save-regs '' \
        %[gl"qZ] \
        %[ostd::algorithm(input.begin(), input.end());<esc>] \
        %[Z"q<a-z>usalgorithm|input<ret><a-z>a]
        selection-cycle-from-selections
    )

define-command snippet-cpp-algorithm-unique \
    %(
        execute-keys -save-regs '' \
        %[oinput.erase(<esc>] \
        %[ostd::unique(input.begin(), input.end(),<esc>] \
        %[o[](const Element& a, const Element& b) {<esc>] \
        %[oreturn a.property() == b.property();<esc>] \
        %[o}), std::end(input));<esc>] \
        %(Z<a-?>input\.erase<ret><a-;>sinput|Element|property\(\)|==<ret><a-z>a)
        selection-cycle-from-selections
    )

define-command snippet-cpp-algorithm-merge \
    %(
        execute-keys -save-regs '' \
        %[ostd::merge(input_one.begin(), input_one.end(),<esc>] \
        %[oinput_two.begin(), input_two.end(),<esc>] \
        %[ostd::back_inserter(output));<esc>] \
        %(Z<a-?>merge<ret><a-;>sinput_one|input_two|output<ret><a-z>a)
        selection-cycle-from-selections
    )

define-command snippet-cpp-algorithm-remove-if \
    %(
        execute-keys -save-regs '' \
        %[oinput.erase(<esc>] \
        %[ostd::remove_if(input.begin(), input.end(),<esc>] \
        %[o[](const Element& element) {<esc>] \
        %[oreturn element;<esc>] \
        %[o}), std::end(input));<esc>] \
        %(Z<a-?>input\.erase<ret><a-;>sinput|Element|element<ret><a-z>a)
        selection-cycle-from-selections
    )

define-command snippet-cpp-algorithm-remove-if-without-remove-if \
    %(
        execute-keys -save-regs '' \
        %[ofor (auto it = collection.begin(); it != collection.end();) {<esc>] \
        %[oif (condition(*it)) {<esc>] \
        %[ocollection.erase(it++);<esc>] \
        %[o} else {<esc>] \
        %[o++it;<esc>] \
        %[o}<esc>] \
        %[o}<esc>] \
        %(Z<a-?>for<ret><a-;>scollection|condition<ret><a-z>a)
        selection-cycle-from-selections
    )

# In C++11, erase should return an iterator to the next element, so this should
# work.
# define-command snippet-cpp-algorithm-remove-if-without-remove-if \
#     %(
#         execute-keys -save-regs '' \
#         %[ofor (auto it = collection.begin(); it != collection.end();) {<esc>] \
#         %[oif (condition(*it)) {<esc>] \
#         %[oit = collection.erase(it);<esc>] \
#         %[o} else {<esc>] \
#         %[o++it;<esc>] \
#         %[o}<esc>] \
#         %[o}<esc>] \
#         %(Z<a-?>for<ret><a-;>scollection|condition<ret><a-z>a)
#         selection-cycle-from-selections
#     )

define-command snippet-cpp-algorithm-set-difference \
    %(
        execute-keys -save-regs '' \
        %[gl"qZ] \
        %[ostd::set_difference(input_one.begin(), input_one.end(),<esc>] \
        %[oinput_two.begin(), input_two.end(),<esc>] \
        %[ostd::back_inserter(output));<esc>] \
        %[Z"q<a-z>usinput_one|input_two|output<ret><a-z>a]
        selection-cycle-from-selections
    )

define-command snippet-cpp-algorithm-transform \
    %(
        execute-keys -save-regs '' \
        %[ostd::transform(input.cbegin(), input.cend(),<esc>] \
        %[ostd::back_inserter(output), [](const Element& element) {<esc>] \
        %[oreturn element;<esc>] \
        %[o});<esc>] \
        %(Z<a-?>transform<ret><a-;>sinput|output|Element|element<ret><a-z>a)
        selection-cycle-from-selections
    )

define-command snippet-cpp-declare-operator-equality \
    %(
        execute-keys -save-regs '' \
        %["qZo// Checks whether two Object objects are equal.<esc>] \
        %[\obool operator==(const Object& one, const Object& two);<esc>] \
        %[obool operator!=(const Object& one, const Object& two) {<esc>] \
        %[oreturn !(one == two);<esc>] \
        %[o}<esc>] \
        %(Z"q<a-z>usObject|TODO<ret><a-z>a)
        selection-cycle-from-selections
    )

define-command snippet-cpp-declare-operator-ostream \
    %(
        execute-keys -save-regs '' \
        %[gl"qZ] \
        %[\o// Prints Object in human readable form to a stream.<esc>] \
        %[\ostd::ostream& operator<lt><lt>(std::ostream& os, const Object& object);<esc>] \
        %(Z"q<a-z>usObject|object<ret><a-z>a)
        selection-cycle-from-selections
    )

