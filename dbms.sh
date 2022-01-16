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
        return 
    elif [ -f "$file_name" ]
    then 
        echo 'Table name is already used. pick another name!'
        return 
    fi

    # create table file 
    touch "$file_name" 2>> '../bash-error-log'  # to supress errors produced by mkdir by redirecting it to bash-error-log


    # input columns of the table - first is pk - no types 
    # first line of table file contain col names 
    read -p "primary key column name: "; 
    echo -n "$REPLY:" >> "$file_name";
    select option in "enter new column" "completed"
    do  
        case $REPLY in 
            1) 
                read -p "column name: "; 
                # each col name must be unique
                if grep -q "$REPLY" "$file_name"; # grep -q simply exit with 0 if at least one match found, otherwise 1
                then
                    echo 'column name is used. pick other name!';
                else 
                    echo -n "$REPLY:" >> "$file_name";
                fi 
                ;;
            2) 
                echo 'CREATE TABLE'
                return 
        esac 
    done 
}

list_tables() {
    echo 'Tables in this database: '
    ls
    echo '--------------------------------'
}


drop_table() { 
    read -p "Table Name To Drop: "
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

# TODO
# DONE check on PK 
insert_into_table() {
    # input table name
    read -p "table name: "
    # check table existence -> skip 
    # display table header  
    table_name="$REPLY"
    # take pk and check it -> skip 
    # take a record form user
    

    while true 
    do 
        select option in "insert new record" "done"
        do
            case $REPLY in 
                1) 
                    echo '' 
                    echo "enter a value for each column seprated by ':'. example-> c1:c2:c3: "
                    head -1 "$table_name";
                    echo ''
                    read
                    # trust user and append the record 
                    user_record="$REPLY"
                    record_pk=`cut -f1 -d: <<< "$user_record"` # using what's called 'Here Strings' in Bash
                    if grep -q "^$record_pk:" "$table_name"; 
                    then 
                        echo "primary key is used. pick another one!"
                        echo ''
                    else 
                        echo '' >> "$table_name" # new line 
                        echo -n "$REPLY" >> "$table_name"
                        echo 'Record Added'
                    fi
                    break
                    ;;
                2) 
                    return
                    ;;
            esac
        done
    done 
}


# TODO
select_from_table() {
    read -p "table name: "
    table_name="$REPLY"
    while true 
    do  
        select option in "select all" "select by primary key" "done"
        do 
            case $REPLY in 
                1) 
                    cat "$table_name"
                    echo ''
                    break
                    ;;
                2) 
                    read -p "primary key: "
                    primary_key="$REPLY"
                    grep "^$primary_key:" "$table_name"
                    break 
                    ;; 
                3) 
                    return  
                    ;; 
            esac 
        done 
    done 
}


# TODO 
delete_from_table() {
    read -p "table name: ";
    table_name="$REPLY"
    while true
    do
        select option in "delete all" "delete by primary key" "no more delete"
        do 
            case $REPLY in 
                1) 
                    echo `head -1 "$table_name"` > "$table_name"
                    break
                    ;; 
                2) 
                    read -p "primary key: "
                    primary_key="$REPLY"
                    sed -i "/^${primary_key}:/d" "$table_name"
                    break
                    ;;
                3) 
                    return 
                    ;;
            esac
        done 
    done
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
        select command in "CREATE TABLE" "LIST TABLES" "DROP TABLE" "INSERT INTO TABLE" "DELETE FROM TABLE" "UPDATE TABLE" "SELECT" "DISCONNECT FROM DATABASE"
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
                    select_from_table 
                    break
                    ;;
                8) 
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

