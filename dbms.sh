#!/bin/bash


# some config  
# set -e # suppress command errors 

# helper functions


# test whether there is a regurlar file or directory in the current directory which has the given name 
is_file_name_used() {
    # using [] is equivalent to executing test command which exit with 0 if condition is met and 1 otherwise
    # by default, return value of a function is the exit status of the last command 
    [ -d $1 ] || [ -f $1 ];
}


# make sure the given string ( assumed to be a proposed file name ) not containing '/'. To make sure database folder will be in current dir
is_file_name_valid() {
    #   no '/'
    [[ "$1" != *"/"* ]]
}

#===============================================================================================#
# key components

# prompt user to enter a name and then check the name
create_database () {
    read -p "Database Name: "
    file_name=$REPLY
    if ! is_file_name_valid "$file_name" # no '/' in the name
    then 
        echo 'illegal name: name cannot contain /'
    else 
        if ! mkdir "$file_name" 2>> 'bash-error-log'  # to supress errors produced by mkdir by redirecting it to bash-error-log
        then 
            echo 'something wrong: try another name'
        else 
            echo 'CREATE DATABASE'
        fi
    fi  
}


drop_database() {
    read -p "Database Name To Drop: "
    file_name=$REPLY
    if [ -d "$file_name" ] 
    then 
        read -p "Are you sure that you want to drop ${file_name} database. There is no undo for this action. Enter 'YES!' without quotes to confirm: "
        if [ $REPLY == "YES!" ] 
        then 
            rm -r "${file_name}" 2>> bash-error-log
            echo "DROP DATABASE"
            return 
        else 
            echo "cancel drop database"
            return 
        fi
    else 
        echo 'Database does not exist!'
    fi      
}

list_databases() { 
    ls --classify | grep / | sed 's!/!!' # syntax: sed 's for substitute command' 'seperator I choosed !' 'search pattern' 'sep' 'replacement str' 'sep'
    # sed 's!/!!' means substitute each '/' with empty string. which has same effect as deleting each /. 
}

connect_to_database() {
    return 1;
}


# main menu 
    # into to program msg
    # general actions
        # create db
        # drop db 
        # list dbs
        # connet to db
        # exit



    # Main Menu
PS3="Command Number: "
select item in "CREATE DATABASE" "DROP DATABASE" "LIST DATABASES" "CONNECT TO DATABASE" "EXIT"
do  
    case $REPLY in 
        1) 
            create_database
            ;;
        2) 
            drop_database 
            ;;
        3) 
            list_databases 
            ;;
        4)
            connect_to_database
            ;;
        5) 
            exit
            ;;
        *) 
            echo "Invalid Command!" 
            ;;
    esac 
done

# db menu
    # header msg 
    # create table  
    # drop 
    # list  
    # update  
    # insert  
    # delete from table 
    # disconn from this db and back to main menu
    # exit dbms

