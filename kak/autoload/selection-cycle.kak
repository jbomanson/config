# PROBLEM: selections can only be saved to the '^' and alphabetic registers
# TODO: Add mappings that work in normal mode.

map global normal <tab> %(:selection-cycle-next<ret>)
map global normal <s-tab> %(:selection-cycle-previous<ret>)

declare-option str-list selection_cycle_registers \
    a:b:c:d:e:f:g:h:i:j:k:l:m:n:o:p:q:r:s:t:u:v:w:x:y:z

declare-option int selection_cycle_number 1
declare-option int selection_cycle_count 0

# TODO: Add an option to specify group sizes for selections so that e.g. the
# first selection could contain 2 selections, the second one 1 selection, etc.
# TODO: Allow selections to be in arbitrary orders.
define-command selection-cycle-from-selections \
    %(
        evaluate-commands -save-regs ^ %(
            execute-keys -save-regs '' Z
            echo
            %sh(
                ruby -e '
                  caret, registers = ARGV
                  registers = registers.split(":")
                  selections, buffer = caret.split("@")
                  selections = selections.split(":")
                  selections.zip(registers).each do |sel, reg|
                    puts "set-register '"'"'#{reg}'"'"' #{sel}@#{buffer}\n"
                  end
                  puts "set-option global selection_cycle_count #{selections.size}"
                ' "$kak_reg_caret" "$kak_opt_selection_cycle_registers"
            )
            selection-cycle-begin
        )
    )

define-command selection-cycle-begin \
    %(
        selection-cycle-number-begin
        selection-cycle-select
    )

define-command selection-cycle-next \
    %(
        selection-cycle-number-next
        selection-cycle-select
    )

define-command selection-cycle-previous \
    %(
        selection-cycle-number-previous
        selection-cycle-select
    )

define-command selection-cycle-select \
    %(
        evaluate-commands -save-regs '^"' %(
            set-register '"' %sh(
                echo "$kak_opt_selection_cycle_registers" \
                    | awk -F: "{print \$$kak_opt_selection_cycle_number}"
            )
            execute-keys "\"%reg(dquote)z"
        )
    )

define-command selection-cycle-number-begin \
    %(
        set-option window selection_cycle_number 1
    )

define-command selection-cycle-number-next \
    %(
        set-option window selection_cycle_number %sh(
            expr "$kak_opt_selection_cycle_number" '%' "$kak_opt_selection_cycle_count" + 1
        )
    )

define-command selection-cycle-number-previous \
    %(
        set-option window selection_cycle_number %sh(
            expr '(' "$kak_opt_selection_cycle_number" + "$kak_opt_selection_cycle_count" - 2 ')' '%' "$kak_opt_selection_cycle_count" + 1
        )
    )

#===============================================================================
# Examples
#===============================================================================

# See snippet.kak

#===============================================================================
# OLD
#===============================================================================

# HMMMM. After thinking about this, I think that it would be better to not
# use up registers for selections that are used by commands.

# declare-option str-list selection_cycle_registers \
#     a:b:c:d:e:f:g:h:i:j:k:l:m:n:o:p:q:r:s:t:u:v:w:x:y:z
# 
# define-command selection-cycle-set-registers \
#     -params .. \
#     %(
#         set-option global selection_cycle_registers
#     )

# <tab>
#     The Tab key.
# 
# <s-tab>
#     The reverse-tab key. This is Shift-Tab on most keyboards.
#
# TODO: Come up with commands to:
# - Insert text.
# - Resolve relative selection ranges.
# - Set up a <tab> <s-tab> cycle for given ranges.
# . Apply a range option as a selection.
