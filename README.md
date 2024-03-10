# Bash Shell Script Database Management System (DBMS)

Welcome to the Bash Shell Script Database Management System (DBMS) project! This CLI-based application enables users to store and retrieve data from the hard disk using simple command-line interactions.

## Project Overview

The DBMS project aims to provide a user-friendly interface for managing databases and tables through a series of menu-driven options. Users can perform operations such as creating databases, listing existing databases, connecting to specific databases, dropping databases, and performing table-related actions like creating, listing, dropping, inserting, selecting, deleting, and updating tables.

## Project Features

### Main Menu
- **Create Database**: Allows users to create a new database.
- **List Databases**: Displays a list of existing databases.
- **Connect To Database**: Enables users to connect to a specific database to perform table-related actions.
- **Drop Database**: Allows users to delete an existing database.

### Database Menu
- **Create Table**: Enables users to create a new table within the connected database.
- **List Tables**: Displays a list of tables within the connected database.
- **Drop Table**: Allows users to delete a table from the connected database.
- **Insert Into Table**: Enables users to insert new records into a table.
- **Select From Table**: Allows users to retrieve and display records from a table.
- **Delete From Table**: Enables users to delete specific records from a table.
- **Update Table**: Allows users to update existing records in a table.

## Implementation Hints

- **Database Storage**: Databases are stored as directories within the same directory as the script file.
- **Column Datatypes**: Users are prompted to specify column datatypes (e.g., string or int) during table creation. Data input and updates are validated against these datatypes.
- **Primary Key**: Users are prompted to specify a primary key during table creation. This key is used for data uniqueness and integrity.

## Usage

1. Clone the repository to your local machine.
2. Ensure that you have Bash installed.
3. Run the main script file to start the DBMS application.
4. Follow the on-screen prompts and menu options to interact with the DBMS.

Thank you for using the Bash Shell Script Database Management System (DBMS)! If you have any questions or feedback, please feel free to reach out.
