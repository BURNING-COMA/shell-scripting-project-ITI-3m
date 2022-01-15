#!/bin/bash


# some config  
# set -e # suppress command errors 

# helper functions


# make sure the given string ( assumed to be a proposed file name ) not containing '/'. To make sure database folder will be in current dir
is_file_name_valid() {
    #   no '/'
    [[ "$1" != *"/"* ]]
}

#===============================================================================================#
# inside db menu 

#TODO 
#

# 1) 
#     create_table
#     break 
#     ;;
# 2) 
#     list_tables DONE
#     break 
#     ;; 
# 3) 
#     drop_table 
#     break
#     ;;
# 4) 
#     insert_into_table
#     break 
#     ;; 
# 5) 
#     delete_from_table 
#     break 
#     ;; 
# 6) 
#     update_table 
#     break 
#     ;; 

create_table() { 
    read -p "Table Name to Create: "
    file_name=$REPLY
    if ! is_file_name_valid "$file_name" # no '/' in the name
    then 
        echo 'illegal name: name cannot contain /'
    else 
        if ! touch "$file_name" 2>> '../bash-error-log'  # to supress errors produced by mkdir by redirecting it to bash-error-log
        then 
            echo 'something wrong: try another name'
        else 
            echo 'CREATE TABLE'
        fi
    fi 
}

list_tables() {
    echo 'Tables in this database: '
    ls
    echo '--------------------------------'
}


drop_table() { 
    read -p "Database Name To Drop: "
    file_name=$REPLY
    if [ -f "$file_name" ] 
    then 
        read -p "Are you sure that you want to drop ${file_name} table. There is no undo for this action. Enter 'YES!' without quotes to confirm: "
        if [ $REPLY == "YES!" ] 
        then 
            rm "${file_name}" 2>> "../bash-error-log"
            echo "DROP TABLE"
        else 
            echo "cancel drop table"
        fi
    else 
        echo 'Table does not exist!'
    fi  
}
#===============================================================================================#
# main menu functions 

# prompt user to enter a name and then check the name
create_database () {
    read -p "Database Name to Create: "
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
            rm -r "${file_name}" 2>> "./bash-error-log"
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
    echo 'Your Databases: '

    ls --classify | grep / | sed 's!/!!' # syntax: sed 's for substitute command' 'seperator I choosed !' 'search pattern' 'sep' 'replacement str' 'sep'
    # sed 's!/!!' means substitute each '/' with empty string. which has same effect as deleting each /. 

    echo '------------------------------';
}

connect_to_database() {
    read -p 'Database Name to Connet: '
    file_name=$REPLY
    if ! [ -d "$file_name" ];
    then 
        echo 'Database does not exist.'
        return 
    fi 


     # go to inside-database command menu
    clear
    cd "$file_name"
    while true 
    do 
        echo "Connected to Database $file_name ..."
        select command in "CREATE TABLE" "LIST TABLES" "DROP TABLE" "INSERT INTO TABLE" "DELETE FROM TABLE" "UPDATE TABLE" "DISCONNECT FROM DATABASE"
        do 
            case $REPLY in 
                1) 
                    create_table
                    break 
                    ;;
                2) 
                    list_tables
                    break 
                    ;; 
                3) 
                    drop_table
                    break
                    ;;
                4) 
                    insert_into_table
                    break 
                    ;; 
                5) 
                    delete_from_table 
                    break 
                    ;; 
                6) 
                    update_table 
                    break 
                    ;; 
                7) 
                    # leave current database: switch to general directory, clean screen
                    cd ..
                    clear # to clear the screen for the main menu 
                    echo "Disconnected from Database $file_name ..."
                    return
                    break
                    ;;
                *) 
                    echo "Command Invalid."
                    break
                    ;; 
            esac
        done 
    done
}

#======================================================================#


    # Main Menu
# The goal of this construct is to display the menu options after each time user pick an option
while true
do

    PS3="Command Number: "
    echo 'Main Menu'
    select command in "CREATE DATABASE" "DROP DATABASE" "LIST DATABASES" "CONNECT TO DATABASE" "EXIT"
    do  
        case $REPLY in 
            1) 
                create_database
                break
                ;;
            2) 
                drop_database 
                break
                ;;
            3) 
                list_databases 
                break
                ;;
            4)
                connect_to_database
                break
                ;;
            5) 
                exit
                ;;
            *) 
                echo "Invalid Command!" 
                break
                ;;
        esac 
    done
done 

