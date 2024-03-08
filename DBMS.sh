#!/bin/bash
DATABASE_FOLDER="databases"

# Check if the databases folder exists, if not, create it
if [ ! -d "$DATABASE_FOLDER" ]; then
    mkdir "$DATABASE_FOLDER"
    echo "Databases folder created successfully."
fi

main_menu() {
    clear
    echo "Main Menu:"
    PS3="Enter your choice: "
    options=("Create Database" "List Databases" "Connect To Database" "Drop Database" "Exit")
    select opt in "${options[@]}"
    do
        case $opt in
            "Create Database")
                create_database
                ;;
            "List Databases")
                list_databases
                ;;
            "Connect To Database")
                connect_to_database
                ;;
            "Drop Database")
                drop_database
                ;;
            "Exit")
                exit
                ;;
            *) 
                echo "Invalid choice. Please enter a valid option."
                ;;
        esac
    done
}

##############################################
 create_database() {
    read -p "Enter database name (DB name must not begin with a number and must not have any spaces): " dbname

    # Check if the database name is empty
    if [ -z "$dbname" ]; then
        echo "Error: Database name cannot be empty."
        return
    fi

    # Check if the database name already exists
    if [ -d "$DATABASE_FOLDER/$dbname" ]; then
        echo "Error: Database '$dbname' already exists."
        return
    fi

    # Check if the database name matches the required regex pattern
    if [[ ! "$dbname" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; then
        echo "Error: Invalid database name. DB name must be a string that does not begin with a number and must not have any spaces."
        return
    fi

    # Create the database directory
    mkdir "$DATABASE_FOLDER/$dbname"
    echo "Database '$dbname' created successfully."
}
##########################################################
list_databases() {
    echo "List of Databases:"
   ls -F "$DATABASE_FOLDER" | grep / | sed 's|/$||'

}
##########################################################
connect_to_database() 

{   list_databases
    read -p "Enter database name: " dbname
    if [ -d "$DATABASE_FOLDER/$dbname" ]; then
        cd "$DATABASE_FOLDER/$dbname" || return
        PS1="$dbname>"
        database_menu
    else
        echo "Database $dbname does not exist."
    fi
}
#########################################################
drop_database() {
    read -p "Enter database name to drop: " dbname
    if [ -d "$DATABASE_FOLDER/$dbname" ]; then
        rm -r "$DATABASE_FOLDER/$dbname"
        echo "Database $dbname dropped successfully."
    else
        echo "Database $dbname does not exist."
    fi
}
###################################################################################
database_menu() {
    clear
    PS3="Enter your choice: "
    options=("Create Table" "List Tables" "Drop Table" "Insert Into Table" "Select From Table" "Delete From Table" "Update Table" "Back to Main Menu")
    select choice in "${options[@]}"
    do
        case $REPLY in
            1) create_table ;;
            2) list_tables ;;
            3) drop_table ;;
            4) insert_into_table ;;
            5) select_from_table ;;
            6) delete_from_table ;;
            7) update_table ;;
            8) main_menu ;;
            *) echo "Invalid choice. Please enter a valid option." ;;
        esac
    done
}
#######################################
create_table() {
    read -p "Enter table name: " tablename
    if [ ! -e "./$tablename" ]; then
        touch "./$tablename"
        read -p "Enter number of fields (columns): " num_fields
        declare -a fields
        declare -a field_types
        for ((i=1; i<=$num_fields; i++)); do
            if [ "$i" == 1 ]; then 
                echo "Please note that the first column will be considered as the primary key of the table."
            fi
            valid_field_name=false
            while [ "$valid_field_name" = false ]; do
                read -p "Enter name of field $i: " field_name
                # Check if the field name already exists
                if grep -q "^$field_name$" "./$tablename"; then
                    echo "Field name $field_name already exists."
                # Check if the field name starts with a number
                elif [[ "$field_name" =~ ^[0-9] ]]; then
                    echo "Field name must not start with a number."
                # Check if the field name contains spaces
                elif [[ "$field_name" =~ [[:space:]] ]]; then
                    echo "Field name must not contain spaces."
                elif [[ "$field_name" =~ [[:punct:]] ]]; then
                    echo "Field name must not contain symbols."
                else
                    valid_field_name=true
                fi
            done
            valid_field_type=false
            while [ "$valid_field_type" = false ]; do
                read -p "Enter type of field $i (string/int): " field_type
                if [[ $field_type != "string" && $field_type != "int" ]]; then
                    echo "Field type must be string or int"
               else 
                    valid_field_type=true
                fi
            done
            fields+=("$field_name")
            field_types+=("$field_type")
        done
        # Join the fields and field_types array elements into single strings
        fields_string=$(IFS=:; echo "${fields[*]}")
        field_types_string=$(IFS=:; echo "${field_types[*]}")
        echo "$fields_string" > "./$tablename"
        echo "$field_types_string" >> ".$tablename"
        echo "Table $tablename created successfully."
    else
        echo "Table $tablename already exists."
    fi
}



main_menu
