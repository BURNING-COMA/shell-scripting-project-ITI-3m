#inf while loop 

# using null commmand ':' which always exit with status true
# while :
# do
# 	echo "Press [CTRL+C] to stop.."
# 	sleep 1
# done:

# using readable while true 
# while true
# do
# 	echo "Press [CTRL+C] to stop.."
# 	sleep 1
# done


############################3



#select 
#PS3 to set custom prompt
# select item in "a a" "a b" "a c"
# do  
#     echo $item 
#     echo $REPLAY 
# done


#case 
# case $var in 
#     op1) 
#         code 
#         ;;
#     op2) 
#         code
#         ;;
#     opn) 
#         break 
#         ;;
#     *) 
#         default case 
#         ;;
# esac




# https://stackoverflow.com/questions/15668170/if-statement-and-calling-function-in-if-using-bash/28202712
# trick with return value 
# By the way, the function could be more simply written as:
# check_log() {
#     ! [ -f "/usr/apps/appcheck.log" ]
# }
# The return value from a function is the exit status of the last command, so no need for explicit return statements.



# if statements 
    # if is_file_name_valid $REPLY
    # then 
    #     echo fine 
    # elif is_file_name_used $REPLY
    # then
    #     echo duplicate 
    # else 
    #     echo fine
    # fi



# how to ignore error msg of commands 
#https://stackoverflow.com/questions/11231937/bash-ignoring-error-for-a-particular-command#:~:text=Just%20add%20%7C%7C%20true%20after,want%20to%20ignore%20the%20error.




# sed substitute command 

    ls --classify | grep / | sed 's!/!!' # syntax: sed 's for substitute command' 'seperator I choosed !' 'search pattern' 'sep' 'replacement str' 'sep'
    # sed 's!/!!' means substitute each '/' with empty string. which has same effect as deleting each /. 

    # https://unix.stackexchange.com/questions/369149/the-differences-between-sed-and



# sed tutorial 
# https://www.grymoire.com/Unix/Sed.html#uh-1



# check existance of a patten inside a file or string 
# grep -q pattern file -> then use exit code to construct logic 


# why printf instead of echo 
# https://stackoverflow.com/questions/8467424/echo-newline-in-bash-prints-literal-n



# print file exept first line 
# https://stackoverflow.com/questions/339483/how-can-i-remove-the-first-line-of-a-text-file-using-bash-sed-script{}


# replace first occurance using sed's range specifier 
# https://stackoverflow.com/questions/148451/how-to-use-sed-to-replace-only-the-first-occurrence-in-a-file