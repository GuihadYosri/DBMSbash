#!/bin/bash
DATABASE_FOLDER="databases"

# Check if the databases folder exists, if not, create it
if [ ! -d "$DATABASE_FOLDER" ]; then
    mkdir "$DATABASE_FOLDER"
    zenity --info --text="Databases folder created successfully."
fi

main_menu() {
    choice=$(zenity --list --title="Main Menu" --text="Choose an option:" --column="Options" \
        "Create Database" "List Databases" "Connect To Database" "Drop Database" "Exit")

    case $choice in
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
            zenity --error --text="Invalid choice. Please select a valid option."
            main_menu
            ;;
    esac
}
##############################################
 create_database() {
# Prompt the user to enter the database name
    dbname=$(zenity --entry --title="Create Database" --text="Enter database name (DB name must not begin with a number and must not have any spaces):")

    # Check if the user canceled the input dialog
    if [ $? -ne 0 ]; then
        return
    fi

    # Check if the database name is empty
    if [ -z "$dbname" ]; then
        zenity --error --text="Error: Database name cannot be empty."
        return
    fi

    # Check if the database name already exists
    if [ -d "$DATABASE_FOLDER/$dbname" ]; then
        zenity --error --text="Error: Database '$dbname' already exists."
        return
    fi

    # Check if the database name matches the required regex pattern
    if [[ ! "$dbname" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; then
        zenity --error --text="Error: Invalid database name. DB name must be a string that does not begin with a number and must not have any spaces."
        return
    fi

    # Create the database directory
    mkdir "$DATABASE_FOLDER/$dbname"
    zenity --info --text="Database '$dbname' created successfully."
}
##########################################################
list_databases() {
    # Get the list of databases
    database_list=$(ls -F "$DATABASE_FOLDER" | grep / | sed 's|/$||')

    # Check if there are no databases
    if [ -z "$database_list" ]; then
        zenity --info --text="No databases found."
        return
    fi

    # Display the list of databases in a Zenity dialog
    zenity --list --title="List of Databases" --column="Databases" $database_list

}
##########################################################
connect_to_database() 

{    local database_list=$(list_databases)

    # Check if there are no databases
    if [ -z "$database_list" ]; then
        zenity --info --text="No databases found."
        return
    fi

    # Prompt the user to select a database from the list
    local selected_database=$(zenity --list --title="Select Database" --column="Databases" $database_list)

    # Check if a database is selected
    if [ -n "$selected_database" ]; then
        # Check if the selected database exists
        if [ -d "$DATABASE_FOLDER/$selected_database" ]; then
            cd "$DATABASE_FOLDER/$selected_database" || return
            zenity --info --text="Connected to database: $selected_database"
            # Here you can call the function for the database menu if needed
        else
            zenity --error --text="Database $selected_database does not exist."
        fi
    fi
database_menu
}
#########################################################
drop_database() {
    # Prompt the user to enter the database name
    dbname=$(zenity --entry --title="Drop Database" --text="Enter database name to drop:")

    # Check if the user canceled or left the entry empty
    if [ -z "$dbname" ]; then
        zenity --error --text="Database name cannot be empty."
        return
    fi

    # Check if the database folder exists
    if [ -d "$DATABASE_FOLDER/$dbname" ]; then
        # Confirm with the user before dropping the database
        if zenity --question --title="Confirm Drop" --text="Are you sure you want to drop database '$dbname' ?"; then
            # Remove the database directory
            rm -r "$DATABASE_FOLDER/$dbname"
            zenity --info --text="Database $dbname dropped successfully."
        else
            zenity --info --text="Drop operation canceled."
        fi
    else
        zenity --error --text="Database $dbname does not exist."
    fi
}
###################################################################################
database_menu() {
    choice=$(zenity --list --title="Database Menu" --text="Select an option:" --column="Options" \
    "Create Table" "List Tables" "Drop Table" "Insert Into Table" "Select From Table" "Delete From Table" "Update Table" "Back to Main Menu" "Exit")

    # Check the user's choice and call the appropriate function
    case $choice in
        "Create Table") 
            create_table ;;
        "List Tables") 
            list_tables ;;
        "Drop Table") 
            drop_table ;;
        "Insert Into Table") 
            insert_into_table ;;
        "Select From Table") 
            select_from_table ;;
        "Delete From Table") 
            delete_from_table ;;
        "Update Table") 
            update_table ;;
        "Back to Main Menu") 
            main_menu ;;
        "Exit")
            exit ;;
        *) 
            zenity --error --text="Invalid choice. Please enter a valid option." ;;
    esac
}
#######################################
create_table() {
# Display input dialog to get the table name
    tablename=$(zenity --entry --title="Create Table" --text="Enter table name:")

    # Check if the user clicked cancel or entered an empty table name
    if [ -z "$tablename" ]; then
        zenity --error --text="Error: Table name cannot be empty."
        return
    fi

    # Check if the table already exists
    if [ -e "./$tablename" ]; then
        zenity --error --text="Error: Table '$tablename' already exists."
        return
    fi

    # Check if the table name matches the required regex pattern
    if [[ ! "$tablename" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; then
        zenity --error --text="Error: Invalid table name. Table name must be a string that does not begin with a number and must not have any spaces."
        return
    fi

    # Display input dialog to get the number of fields
    num_fields=$(zenity --entry --title="Create Table" --text="Enter number of fields (columns):")

    # Check if the user clicked cancel or entered an empty value
    if [ -z "$num_fields" ]; then
        zenity --error --text="Error: Number of fields cannot be empty."
        return
    fi

    # Loop through each field to gather field name and type
    fields=()
    field_types=()
    for ((i=1; i<=$num_fields; i++)); do
        # Display input dialogs to get field name and type
        field_name=$(zenity --entry --title="Create Table" --text="Enter name of field $i:")
        field_type=$(zenity --entry --title="Create Table" --text="Enter type of field $i (string/int):")

        # Validate field name and type
        if [ -z "$field_name" ]; then
            zenity --error --text="Error: Field name cannot be empty."
            return
        fi

        if [ -z "$field_type" ] || [[ ! "$field_type" =~ ^(string|int)$ ]]; then
            zenity --error --text="Error: Field type must be string or int."
            return
        fi

        # Add field name and type to arrays
        fields+=("$field_name")
        field_types+=("$field_type")
    done

    # Join field names and types into single strings
    fields_string=$(IFS=:; echo "${fields[*]}")
    field_types_string=$(IFS=:; echo "${field_types[*]}")

    # Write field names and types to the table file
    echo "$fields_string" > "./$tablename"
    echo "$field_types_string" >> "./$tablename"

    # Display success message
    zenity --info --text="Table $tablename created successfully."
}

###############################################

list_tables() {
 # List all files (tables) in the current directory (database)
    tables=$(ls -p | grep -v /)  # Exclude directories from the listing

    # Check if there are tables in the database
    if [ -z "$tables" ]; then
        zenity --info --text="No tables found in the database."
    else
        # Display message dialog with the list of tables
        zenity --info --title="List of Tables" --text="List of Tables:\n$tables"
    fi
}

##############################################

drop_table() {
    # Get the list of tables from the list_tables function
     tabless=$(list_tables)

    # Check if there are tables in the database
    if [ -n "$tabless" ]; then
        # Prompt the user to select the table to drop
        local selected_table=$(zenity --list --title="Select Table to Drop" --text="Select the table to drop:" --column="Table" --hide-header $tabless)

        # Check if a table is selected
        if [ -n "$selected_table" ]; then
            # Ask for confirmation before deleting the table
            local confirmation=$(zenity --question --title="Confirm Drop" --text="Are you sure you want to drop table $selected_table?")

            # Process the user's confirmation
            if [ $? -eq 0 ]; then
                # Remove the file representing the selected table
                rm "databases/$selected_table"
                zenity --info --title="Success" --text="Table $selected_table dropped successfully."
            else
                zenity --info --title="Canceled" --text="Operation canceled. Table $selected_table was not dropped."
            fi
        fi
    else
        zenity --info --title="No Tables" --text="No tables found in the database."
    fi
}

###########################################


# Function to list tables in the database folder
list_table() {
    local DATABASE_FOLDER="databases"
    local tables=$(ls -p "$DATABASE_FOLDER" | grep "/")
    echo "$tables"
}

# Function to insert data into a table using a GUI
insert_into_table() {
    local table=$(list_table)
    
    # Check if there are tables in the database
    if [ -n "$table" ]; then
        # Prompt the user to select the table to insert into
        local tablename=$(zenity --list --title="Select Table to Insert Into" --text="Select the table to insert data into:" --column="Table" $table)

        # Check if a table is selected
        if [ -n "$tablename" ]; then
            # Check if the table exists
            if [ -f "databases/$tablename" ]; then
                # Read column names from the first line of the file
                read -r first_line < "databases/$tablename"
                columns_names=$(echo "$first_line" | cut -d: -f2-)
                IFS=':' read -r -a columns_names <<< "$columns_names"

                # Read data types from the second line of the file
                read -r second_line < <(tail -n +2 "databases/$tablename" | head -n 1)
                columns_datatypes=$(echo "$second_line" | cut -d: -f2-)
                IFS=':' read -r -a columns_datatypes <<< "$columns_datatypes"

                num_columns=${#columns_datatypes[@]}

                # Create an array to store data
                declare -a data

                # Loop through each column to get user input for data
                for ((i=0; i<num_columns; i++)); do
                    value=$(zenity --entry --title="Enter Data" --text="Enter value for ${columns_names[i]} (${columns_datatypes[i]}):")
                    data+=("$value")
                done

                # Join the data array elements into a single string
                data_string=":"
                data_string+="$(IFS=:; echo "${data[*]}")"
                data_string+=":"

                # Append the data to the table file
                echo "$data_string" >> "databases/$tablename"
                zenity --info --title="Success" --text="Data inserted into table $tablename."
            else
                zenity --error --title="Table Not Found" --text="Table $tablename does not exist."
            fi
        fi
    else
        zenity --error --title="No Tables" --text="No tables found in the database."
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
echo "Columns in table $tablename"
 head -n 1 "$tablename"
        # Provide option to enter column name and value = select by row
        read -p "Enter the column name to select: " column_name
        read -p "Enter the value of $column_name to select the row: " column_value
        
        # Validate if the specified column exists
        if grep -q ":$column_name:" "$tablename"; then
            # Get the column number of the specified column
            column_number=$(awk -F: -v col_name="$column_name" 'NR==1 { for(i=1; i<=NF; i++) { if ($i == col_name) { print i } } }' "$tablename")
            
            if [ -n "$column_number" ]; then
                # Search for the specified value only in the specified column
                found=$(awk -F: -v col_num="$column_number" -v val="$column_value" '$col_num == val' "$tablename")
                if [ -n "$found" ]; then
                    echo "Row with $column_name = $column_value found."
                    echo "$found"
                else
                    echo "Row with $column_name = $column_value not found."
                fi
            else
                echo "Column $column_name does not exist in $tablename."
            fi
        else
            echo "Column $column_name does not exist in $tablename."
        fi
        
                ;;
            3)
                echo "Columns in table $tablename"
                head -n 1 "$tablename"
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
        # Display all data starting from line 3
                tail -n +3 "$tablename"
        
        # Provide options for deletion criteria
        echo "Select an option:"
        echo "1. Delete by specific column value"
        echo "2. Delete all data"
        read -p "Enter your choice: " choice
        
        case $choice in
            
            1)
  echo "Columns in table $tablename:"
        head -n 1 "$tablename"

        # Provide option to enter column name and value
        read -p "Enter the column name to delete by: " column_name
        if [[ "$column_name" == "string" || "$column_name" == "int" ]]; then
   echo "Column $column_name does not exist in $tablename."
return
fi
       
        # Check if the specified column name exists
        if grep -q ":$column_name:" "$tablename"; then
             read -p "Enter the value of $column_name to delete the row: " column_value
            # Check if the specified value exists in the specified column
            if grep -q ":$column_value:" "$tablename"; then
                # Delete the row(s) based on the provided column value
                sed -i "/^.*:$column_value:/d" "$tablename"
                echo "Rows with $column_name = $column_value deleted from $tablename."
            else
                echo "Value $column_value not found in column $column_name of $tablename."
            fi
        else
            echo "Column $column_name does not exist in $tablename."
        fi
        ;; 
            2)
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
: <<'END_COMMENT'
update_table() {
    read -p "Enter table name to select from: " tablename

    if [ -f "./$tablename" ]; then
        # Ask user for column name and column value to select a specific row
        read -p "Enter the column name to select: " column_name
        read -p "Enter the value of $column_name to select the row: " column_value

        # Find the row number where the specified column value exists
       row_number=$(awk -F: -v col_name="$column_name" -v col_value="$column_value" '
    $0 ~ ":" col_value ":" { print NR; exit }' "$tablename")


        if [ "$row_number" -gt 0 ]; then
            echo "Selected row: $row_number"

            # Ask user for the column they want to update a value in
            read -p "Enter the column name to update: " update_column_name

# Search for the column name in the first line of the file and count the number of occurrences of : before the specified column
                # Search for the column name in the first line of the file and count the number of occurrences of : before the specified column
update_column_number=$(awk -F: -v col_name="$update_column_name" 'NR==1 { for(i=1; i<=NF; i++) { if ($i == col_name) { print i } } }' "$tablename")




            echo "column num: $update_column_number"
            if [ -n "$update_column_number" ]; then
                # Ask user for the new value
                read -p "Enter the new value for $update_column_name: " new_value

                # Update the value at the specific row and column
                sed -i "${row_number}s/:[^:]*:/:$new_value:/${update_column_number-1}" "$tablename"
                echo "Row updated successfully."
            else
                echo "Column $update_column_name not found in $tablename."
            fi
        else
            echo "Row with $column_name = $column_value not found."
        fi
    else
        echo "Table $tablename does not exist."
    fi
}

END_COMMENT



update_table() {
    read -p "Enter the table name to update: " tablename

    if [ -f "./$tablename" ]; then
        # Display table contents
        echo "Table: $tablename"
        cat "$tablename"

        # Ask user for the column they want to update
        read -p "Enter the column name to update: " column_name

        # Check if the column exists in the table
        if grep -q ":$column_name:" "$tablename"; then
            # Get the column number
            col_number=$(awk -F: -v col_name="$column_name" 'NR==1 { for(i=1; i<=NF; i++) { if ($i == col_name) { print i } } }' "$tablename")
            
            # Get the datatype of the column
            col_datatype=$(awk -F: -v num="$col_number" 'NR==2 {print $num}' "$tablename")

            # Ask user for the specific value in the column they want to change
            read -p "Enter the value in $column_name to update: " old_value

            # Check if the old value exists in the specified column
            if grep -q ":$old_value:" "$tablename"; then
                # Ask user for the new value
                read -p "Enter the new value for $column_name: " new_value
                echo "$col_number"

                # Check if the column is the first column
                if [ "$col_number" -eq 2 ]; then
                    # Check if the new value is unique
                    if grep -q "^$value:" "$tablename"; then
                        echo "Error: New value for column '$column_name' must be unique."
                        return
                    fi
                fi

                # Validate the new value based on the column's datatype
                case $col_datatype in
                    "string")
                             if [[ ! "$new_value" =~ ^[a-zA-Z]+$ ]]; then
            echo "Error: New value must contain only string characters for column '$column_name'."
            return
        fi
        ;;
                    "int")
                        # Validate if the new value is an integer
                        if ! [[ "$new_value" =~ ^[0-9]+$ ]]; then
                            echo "Error: New value must be an integer for column '$column_name'."
                            return
                        fi
                        ;;
                    *)
                        echo "Error: Unsupported datatype '$col_datatype' for column '$column_name'."
                        return
                        ;;
                esac

                # Update the specified value in the column with the new value
                sed -i "s/:$old_value:/:$new_value:/" "$tablename"
                echo "Value '$old_value' in column '$column_name' updated to '$new_value' successfully."
            else
                echo "Error: Value '$old_value' not found in column '$column_name'."
            fi
        else
            echo "Error: Column '$column_name' does not exist in the table."
        fi
    else
        echo "Error: Table '$tablename' does not exist."
    fi
}





main_menu
