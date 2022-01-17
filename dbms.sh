#!/bin/bash


# some config  
# set -e # suppress command errors 

############################################################

# helper functions
# make sure the given string ( assumed to be a proposed file name ) not containing '/'. To make sure database folder will be in current dir
is_file_name_valid() {
    #   no '/'
    [[ "$1" != *"/"* ]]
}

# check that column name does not contain ':' since it is preserved for table format
# precondition : there is 1 argument: the suggested name of column
# postcondition : Exit code is 0 if given string doesn't contain ':', otherwise 1
is_column_name_valid() {
     # pass given string to grep -q ':' using Here strings and then negate it's exit code
    ! grep -q ':' <<< $1 

}

#===============================================================================================#
# inside db menu 

create_table() { 
    read -p "Table Name to Create: "
    file_name=$REPLY
    # check 1. name valie, 2. name is not taken 
    if ! is_file_name_valid "$file_name" # no '/' in the name
    then 
        printf '\n!\nillegal name: name cannot contain /\n\n'
        return 
    elif [ -f "$file_name" ] # to prevent duplicate table names
    then 
        printf '\n!\ntable name is already used. pick another name.\n\n'
        return 
    fi

    # create table file 
    touch "$file_name" 2>> '../bash-error-log'  # to supress errors produced by mkdir by redirecting it to bash-error-log


    # input columns of the table - first is pk - no types 
    # first line of table file contain col names 
    # second line contains col numbers
    read -p "primary key column name: "; 
    echo -n "$REPLY:" >> "$file_name";

    while true 
    do 
        select option in "enter new column" "completed"
        do  
            case $REPLY in 
                1) 
                    read -p "column name: "; 
                    column_name="$REPLY"
                    # each col name must be unique
                    if ! is_column_name_valid "$column_name"
                    then 
                        printf "\n!\n column name is not valid. Don't use ':'\n\n"
                    elif grep -q "$column_name" "$file_name"; # grep -q simply exit with 0 if at least one match found, otherwise 1
                    then
                        echo 'column name is used. pick other name!';
                    else 
                        echo -n "$column_name:" >> "$file_name";
                    fi
                    break 
                    ;;
                2) 
                    echo '' >> "$file_name" 
                    echo 'CREATE TABLE'
                    return 
            esac 
        done
    done  
}

list_tables() {
    echo ''
    echo 'Tables in this database: '
    echo '--------------------------------'
    ls -1
    echo '--------------------------------'
    echo ''
}


drop_table() { 
    
    read -p "table Name To Drop: "
    file_name=$REPLY
    
    if ! [ -f "$file_name" ] 
    then
        printf "\n!\ntable does not exist!\n\n" 
        return 
    fi 
    
    printf "\n!\nare you sure that you want to drop table ${file_name} ?\n"
    printf "there is no undo for this action.\nenter 'YES!' without quotes to confirm or anything else to cancel: "
    read
    if [ $REPLY == "YES!" ] 
    then 
        rm "${file_name}" 2>> "../bash-error-log"
        printf "\n!\ndone drop table\n\n"
    else 
        printf "\n!\ncancel drop table\n\n"
    fi
}


# DONE check on PK 
# TODO check and enforce new records to match table format 
insert_into_table() {
    read -p "table name: "
 
    if ! [ -f "$REPLY" ]
    then
        printf "\n!\ntable does not exist.\n\n"
        return  
    fi 

    # display table header  
    table_name="$REPLY"
    # take a record form user and insert it       
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
                    # extract primary key from user record
                    record_pk=`cut -f1 -d: <<< "$user_record"` # using what's called 'Here Strings' in Bash
                    # check that primary key value is not used 
                    # 'tail -n +2' used to exclude table header from PK check 
                    if tail -n +2 "$table_name" | grep -q "^$record_pk:"; 
                    then 
                        echo "duplicate primary key!"
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


# TODO display table in a good readalbe format using awk
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
    # skip table existance check
    table_name="$REPLY"

    if ! [ -f "$table_name" ]
    then
        printf "\n!\ntable does not exist!\n\n" 
    fi 

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


# TODO
# there are only 2 updates: 
# 1. add new column 
# 2. delete column that are not primary key
update_table() { 
    read -p "table name: "
    table_name="$REPLY"
    if ! [ -f "$table_name" ]
    then
        printf "\n!\nno such table\n\n"
        return 
    fi

    while true 
    do 
        select option in "delete column" "add column" "done"
        do 
            case $REPLY in
                1) 
                    # user enter column name 

                    # check that column exist TODO
                    # check that col is not pk TODO 
                    # delete col reserving table format TODO 
                    break 
                    ;; 
                2) 
                    # user enter column name 
                    read -p "new column name: "
                    column_name="$REPLY"
                    if ! is_column_name_valid "$column_name"
                    then
                        printf "\n!\n column name is not valid. Don't use ':'\n\n"
                    # prevent duplicate column names
                    elif head -1  "$table_name" | grep -q "$column_name:"; # if column name is taken
                    then
                        printf "\n!\nthis name is used.\n\n"
                    else    
                    # if all good, append col
                    # by replacing table header(first line) with new column add using sed
                    header_temp=`head -1 $table_name`
                    # I must stop 'awk' at first line which is table header, otherwise 
                    # In case of a record exactly as table header, awk will update both.
                    # to prevent that, I used awk's 'sub' to update first header only
                    # TODO with awk and avoid previous bug
                    # using sed and range specifier 
                    sed -i "0,/$header_temp/{s/"$header_temp"/"$header_temp$column_name:"/}" "$table_name"
                    printf "\n added column $column_name"
                    fi 
                    
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

