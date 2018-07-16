# PROBLEM: selections can only be saved to the '^' and alphabetic registers
# TODO: Add mappings that work in normal mode.

map global normal <tab> %(:selection-cycle-next<ret>)
map global normal <s-tab> %(:selection-cycle-previous<ret>)

declare-option str-list selection_cycle_registers \
    a:b:c:d:e:f:g:h:i:j:k:l:m:n:o:p:q:r:s:t:u:v:w:x:y:z

declare-option int selection_cycle_number 1
declare-option int selection_cycle_count 0

# NOTE: The selections are sorted for now for convenience.
define-command selection-cycle-from-selections \
    %(
        evaluate-commands -save-regs ^ %(
            execute-keys -save-regs '' Z
            echo
            %sh(
                ruby -e '
                  def sort_descs(descs)
                    descs.sort_by do |position_pair|
                      position_pair.split(",").first.split(".").map(&:to_i)
                    end
                  end
                  caret, registers, selections = ARGV
                  registers = registers.split(":")
                  descs, buffer = caret.split("@")
                  # These seem to come in various orders.
                  descs = descs.split(":")
                  descs = sort_descs(descs)
                  # These seem to be sorted by position.
                  selections = selections.split(":")
                  # Group selection descriptions by their content.
                  descs =
                    descs
                    .zip(selections)
                    .group_by(&:last)
                    .values
                    .map {|pairs| sort_descs(pairs.map(&:first)).join(":")}
                  descs = sort_descs(descs)
                  descs.zip(registers).each do |sel, reg|
                    puts "set-register '"'"'#{reg}'"'"' #{sel}@#{buffer}\n"
                  end
                  puts "set-option global selection_cycle_count #{descs.size}"
                ' "$kak_reg_caret" "$kak_opt_selection_cycle_registers" "$kak_selections"
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
