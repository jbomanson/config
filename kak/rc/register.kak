# TODO: Write a version that pops up on demand and shows register values in
# an info box. 

#===============================================================================

# # NOTE: This brings up the following error:
# # error running hook InsertBegin()/register-echo-group: 1:1: 'register-echo-update' parse error: unterminated string '...'
# 
# # TODO: Hook on the first InsertCompletionShow event after an InsertBegin event.
# hook -group register-echo-group global InsertBegin .* register-echo-update
# # hook -group register-echo-group global InsertCompletionShow .* register-echo-update
# 
# declare-option -hidden str-list _register_echo_historical
# declare-option -hidden str-list _register_echo_fresh
# 
# define-command -hidden register-echo-update %{
#     set-option current _register_echo_fresh %sh{
#         ruby -e '
#             quote = ARGV.shift
#             added =
#                 ARGV.map do |element|
#                     f = element.each_line.first
#                     next unless f
#                     next if f.index(quote)
#                     f = f.clone
#                     f.chomp!
#                     f.gsub!(/:/, "\\\\:")
#                     f.strip!
#                     f
#                 end
#             added.compact!
#             output = added.join(":")
#             print "#{quote}#{output}#{quote}"
#         ' \
#             "'" \
#             "$kak_reg_0" \
#             "$kak_reg_1" \
#             "$kak_reg_2" \
#             "$kak_reg_3" \
#             "$kak_reg_4" \
#             "$kak_reg_5" \
#             "$kak_reg_6" \
#             "$kak_reg_7" \
#             "$kak_reg_8" \
#             "$kak_reg_9" \
#             "$kak_reg_a" \
#             "$kak_reg_b" \
#             "$kak_reg_c" \
#             "$kak_reg_d" \
#             "$kak_reg_e" \
#             "$kak_reg_f" \
#             "$kak_reg_g" \
#             "$kak_reg_h" \
#             "$kak_reg_i" \
#             "$kak_reg_j" \
#             "$kak_reg_k" \
#             "$kak_reg_l" \
#             "$kak_reg_m" \
#             "$kak_reg_n" \
#             "$kak_reg_o" \
#             "$kak_reg_p" \
#             "$kak_reg_q" \
#             "$kak_reg_r" \
#             "$kak_reg_s" \
#             "$kak_reg_t" \
#             "$kak_reg_u" \
#             "$kak_reg_v" \
#             "$kak_reg_w" \
#             "$kak_reg_x" \
#             "$kak_reg_y" \
#             "$kak_reg_z"
#     }
#     set-option current static_words %sh{
#         ruby -e '
#             quote = ARGV.shift
#             current, historical, fresh =
#                 ARGV.map do |str_list|
#                     str_list.split(/(?<!\\\\):/)
#                 end
#             remaining = historical.clone
#             current.reject! do |element|
#                 remaining.delete(element)
#             end
#             output = (current + fresh).join(":")
#             print "#{quote}#{output}#{quote}"
#         ' \
#             "'" \
#             "$kak_opt_static_words" \
#             "$kak_opt__register_echo_historical" \
#             "$kak_opt__register_echo_fresh"
#     }
#     set-option current _register_echo_historical %opt{_register_echo_fresh}
# }

#===============================================================================

# define-command \
#     -params ..1 \
#   -shell-completions %{
#       echo abc
#       echo uvw
#       echo xyz
#     prefix=$(printf %s\\n "$1" | cut -c1-${kak_pos_in_token} 2>/dev/null)
#     for page in /usr/share/man/*/${prefix}*.[1-8]*; do
#         candidate=$(basename ${page%%.[1-8]*})
#         pagenum=$(printf %s\\n "$page" | sed 's,^.*\.\([1-8].*\)\..*$,\1,')
#         case $candidate in
#             *\*) ;;
#             *) printf %s\\n "$candidate($pagenum)";;
#         esac
#     done
#   } \
#     -docstring "Just something" \
#     register-vvv \
#     %{
#         echo %sh{
#             printf "%s" "$1"
#         }
#     }

# define-command register-echo \
#     -params 1 \
#     -shell-completion \
#     %{
#         echo uvw
#         echo abc
# #         first () 
# #         {
# #             if test "$1" -ne ""
# #             then
# #                 printf -- "%s\n" "$1"
# #             fi
# #         }
# #         first $kak_reg_0
# #         first $kak_reg_1
# #         first $kak_reg_2
# #         first $kak_reg_3
# #         first $kak_reg_4
# #         first $kak_reg_5
# #         first $kak_reg_6
# #         first $kak_reg_7
# #         first $kak_reg_8
# #         first $kak_reg_9
# #         first $kak_reg_a
# #         first $kak_reg_b
# #         first $kak_reg_c
# #         first $kak_reg_d
# #         first $kak_reg_e
# #         first $kak_reg_f
# #         first $kak_reg_g
# #         first $kak_reg_h
# #         first $kak_reg_i
# #         first $kak_reg_j
# #         first $kak_reg_k
# #         first $kak_reg_l
# #         first $kak_reg_m
# #         first $kak_reg_n
# #         first $kak_reg_o
# #         first $kak_reg_p
# #         first $kak_reg_q
# #         first $kak_reg_r
# #         first $kak_reg_s
# #         first $kak_reg_t
# #         first $kak_reg_u
# #         first $kak_reg_v
# #         first $kak_reg_w
# #         first $kak_reg_x
# #         first $kak_reg_y
# #         first $kak_reg_z
#     } \
#     %{
#         echo %sh{
#             printf "%s" "$1"
#         }
#     }
