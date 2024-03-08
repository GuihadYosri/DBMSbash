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
    options=("Create Table" "List Tables" "Drop Table" "Insert Into Table" "Select From Table" "Delete From Table" "Update Table" "Back to Main Menu" "Exit")
    select choice in "${options[@]}"
    do
        case $choice in
            "Create Table") 
               create_table 
               ;;
            "List Tables") 
               list_tables 
               ;;
            "Drop Table") 
               drop_table 
               ;;
            "Insert Into Table") 
               insert_into_table 
               ;;
            "Select From Table") 
               select_from_table
               ;;
            "Delete From Table") 
               delete_from_table 
               ;;
            "Update Table") 
               update_table
               ;;
            "Back to Main Menu") 
               main_menu
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
        echo "$field_types_string" >> "./$tablename"
        echo "Table $tablename created successfully."
    else
        echo "Table $tablename already exists."
    fi
}

###############################################

list_tables() {

    # List all files (tables) in the current directory (database)
    tables=$(ls -p | grep -v /)  # Exclude directories from the listing

    # Check if there are tables in the database
    if [ -z "$tables" ]; then
        echo "No tables found in the database."
    else
        echo "List of Tables:"
        echo "$tables"
    fi
}

##############################################

drop_table() {
    list_tables
    read -p "Enter table name to drop: " tablename

    # Check if the table exists
    if [ -f "$tablename" ]; then
        # Ask for confirmation before deleting the table
        read -p "Are you sure you want to drop table $tablename? (y/n): " confirmation
        case $confirmation in
            [Yy])
                rm "$tablename"  # Remove the file representing the table
                echo "Table $tablename dropped successfully."
                ;;
            [Nn])
                echo "Operation canceled. Table $tablename was not dropped."
                ;;
            *)
                echo "Invalid input. Please enter 'y' for yes or 'n' for no. Table $tablename was not dropped."
                ;;
        esac

    else
        echo "Table $tablename does not exist."
    fi
}

###########################################
insert_into_table() {
    read -p "Enter table name to insert into: " tablename
    if [ -f "./$tablename" ]; then
         # Read column names from the first line of the file
         IFS=: read -r -a columns_names < "$tablename"
         # Read data types from the second line of the file
         IFS=: read -r -a columns_datatypes < <(tail -n +2 "$tablename" | head -n 1)
         num_columns=${#columns_datatypes[@]}
        
        echo "Enter data for the table $tablename:"
        declare -a data
        
        for ((i=0; i<num_columns; i++)); do
            read -p "Enter value for ${columns_names[i]} (${columns_datatypes[i]}): " value
            
            # Validate data type
            if [[ "${columns_datatypes[i]}" == "int" && ! "$value" =~ ^[0-9]+$ ]]; then
                echo "Invalid input. ${columns_names[i]} must be an integer."
                return
            fi
            # Check if the value is unique for the first column
            if [ "$i" -eq 0 ]; then
                # Check if the value already exists in the file for the first column
                if grep -q "^$value:" "$tablename"; then
                    echo "Value for ${columns_names[i]} must be unique."
                    return
                fi
            fi


            # Add the data to the array
            data+=("$value")
        done
        
        # Join the data array elements into a single string
        data_string=$(IFS=:; echo "${data[*]}")
        data_string+=":"
        # Append the data to the table file
        echo "$data_string" >> "$tablename"
        echo "Data inserted into table $tablename."
    else
        echo "Table $tablename does not exist."
    fi
}
#############################################

select_from_table() {
    list_tables
    read -p "Enter table name to select from: " tablename
    if [ -f "./$tablename" ]; then
        # Check if the table has only two lines
        if [ "$(wc -l < "$tablename")" -eq 2 ]; then
            echo "Table $tablename is empty."
            return
        fi

        # Display options for selection
        echo "Select an option:"
        echo "1. Select all data from $tablename"
        echo "2. Select a specific row"
        echo "3. Select a specific column"
        read -p "Enter your choice: " choice

        case $choice in
            1)
                # Display column names
                IFS=: read -r -a columns_names < "$tablename"
                echo "Table ( $tablename ) data:"
                
                # Display all data starting from line 3
                tail -n +3 "$tablename"
                ;;
            2)
                # Provide option to enter column name and value = select by row
                read -p "Enter the column name to select: " column_name
                read -p "Enter the value of $column_name to select the row: " column_value
                # Validate if the specified column exists
                if grep -q "^$column_name:" "$tablename"; then
                    grep -i "$column_value" "$tablename" || echo "Row with $column_name = $column_value not found."
                else
                    echo "Column $column_name does not exist in $tablename."
                fi
                ;;
            3)
                read -p "Enter the column name to select: " column_name
                # Search for the column name in the first line of the file and count the number of occurrences of : before the specified column
                column_number=$(awk -F: -v col_name="$column_name" 'NR==1 { for(i=1; i<=NF; i++) { if ($i == col_name) { print i } } }' "$tablename")
                # If the column name is found print the data in the corresponding column from the other lines
                if [ -n "$column_number" ]; then
                    # Output the values of the specified column starting from the third line
                    awk -F: -v col_num="$column_number" 'NR>=3 { print $col_num }' "$tablename"
                else
                    echo "Column $column_name not found in $tablename."
                fi
                ;;
            *)
                echo "Invalid choice."
                ;;
        esac
    else
        echo "Table $tablename does not exist."
    fi
}
#################################################################################
delete_from_table() {
    read -p "Enter table name to delete from: " tablename
    if [ -f "./$tablename" ]; then
        # Display data before deletion
        echo "Data in $tablename before deletion:"
        cat "$tablename"
        
        # Provide options for deletion criteria
        echo "Select an option:"
        echo "1. Delete by ID"
        echo "2. Delete by specific column value"
        echo "3. Delete all data"
        read -p "Enter your choice: " choice
        
        case $choice in
            1)
                # Provide option to enter the ID to delete
                read -p "Enter the ID to delete: " id_to_delete
                # Delete the row(s) based on the provided ID
                sed -i "/^$id_to_delete:/d" "$tablename"
                echo "Data with ID $id_to_delete deleted from $tablename."
                ;;
            2)
                # Provide option to enter column name and value
                read -p "Enter the column name to delete by: " column_name
                read -p "Enter the value of $column_name to delete the row: " column_value
                # Delete the row(s) based on the provided column value
                sed -i "/^.*:$column_value:/d" "$tablename"
                echo "Rows with $column_name = $column_value deleted from $tablename."
                ;;
            3)
                # Delete all data starting from the 3rd line
                sed -i '3,$d' "$tablename"
                echo "All data starting from the 3rd line deleted from $tablename."
                ;;
            *)
                echo "Invalid choice."
                ;;
        esac
    else
        echo "Table $tablename does not exist."
    fi
}
###############################################################################






main_menu
