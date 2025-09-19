#!/bin/bash

DBMS_DIR="./DBMS"

mkdir -p "$DBMS_DIR"

main_menu(){
	while true; do
		echo "------------------------"
		echo " Simple Bash Data Base "
		echo "------------------------"
		echo "1. Create Database "
		echo "2. List Databases "
		echo "3. Connent to Datebase "
		echo "4. Drop Dataabse "
		echo "5. Exit"
		echo -n "Choose an option: "
		read choice

		case $choice in
			1) create_database ;;
			2) list_databases ;;
			3) connect_database ;;
			4) drop_database ;;
			5) echo "Goodbye"; exit ;;
			*) echo "Invalid choice" ;;
		esac
	done
}

create_database(){
	echo -n "Enter database name: "
	read dbname
	if [[ -z "$dbname" ]]; then
		echo "you must write any thing! "
		return
	fi

	if [ -d "$DBMS_DIR/$dbname" ]; then
		echo "Database already exists."
	else
		mkdir "$DBMS_DIR/$dbname" 2>/dev/null
		if [ $? -eq 0 ]; then
			echo "Database '$dbname' created."
		else
			echo "Failed to create database."
		fi
	fi
}

list_databases(){
	echo "Databases:"
	ls "$DBMS_DIR"
}

connect_database(){
	echo -n "Enter database name to connect: "
	read dbname
	if [ -d "$DBMS_DIR/$dbname" ]; then
		echo "Connected to '$dbname' ."
		table_menu "$dbname"
	else
		echo "Database does not exist."
	fi
}

drop_database(){
	echo -n "Enter database name to drop: "
	read dbname
	rm -r "$DBMS_DIR/$dbname" 2>/dev/null
	if [ $? -eq 0 ]; then
		echo "Database '$dbname' dropped."
	else
		echo "Error: Database not found."
	fi
}

table_menu(){
	dbname=$1
	while true; do
		echo "-------- Connected to [$dbname] --------"
		echo "1. Create Table "
		echo "2. List Tables "
		echo "3. Drop Table "
		echo "4. Insert into Table "
		echo "5. Select from Table "
		echo "6. Delete from Table "
		echo "7. Update Table "
		echo "8. Back to Main Menu "
		echo -n "Choose an option: "
		read choice

		case $choice in 
			1) create_table "$dbname" ;;
			2) list_tables "$dbname" ;;
			3) drop_table "$dbname" ;;
			4) insert_into_table "$dbname" ;;
			5) select_from_table "$dbname" ;;
			6) delete_from_table "$dbname" ;;
			7) update_table "$dbname" ;;
			8) break ;;
			*) echo "Invalid choice" ;;
		esac
	done
}

create_table(){
	dbname=$1
	echo -n "Enter table name: "
	read tablename
	filepath="$DBMS_DIR/$dbname/$tablename"

	if [ -f "$filepath" ]; then
		echo "Table already exists."
		return
	fi

	echo -n "Enter number of columns: "
	read col_count

	echo "Enter column names (comma-separated):"
	read columns

	echo "$columns" > "$filepath"
	echo "Table '$tablename' created."
}


list_tables(){
	dbname=$1
	echo " Data in the database [$dbname] : "
	ls "$DBMS_DIR/$dbname"
}

drop_table(){
	dbname=$1
	echo -n "Enter table name to drop: "
	read tablename

	if [[ -z "$tablename" ]]; then
		echo "you must enter the table's name"
		return
	fi
	
	filepath="$DBMS_DIR/$dbname/$tablename"

	if [ -f "$filepath" ]; then
		rm "$filepath"
		echo "Table '$tablename' dropped. "
	else
		echo "Table doesnot exist. "
	fi
}

insert_into_table(){
	dbname=$1
	echo -n "Enter table name to insert into : "
	read tablename
	filepath="$DBMS_DIR/$dbname/$tablename"

	if [ ! -f "$filepath" ]; then
		echo "Table doesnot exist."
		return
	fi 

	header=$(head -n 1 "$filepath")
	IFS=',' read -ra columns <<< "$header"

	row=""
	for col in "${columns[@]}"; do
		echo -n "Enter value for [$col]: "
		read value

		row+="$value,"
	done

	row=${row%,}
	echo "$row" >> "$filepath"
	echo "Row inserted"
}

select_from_table(){
	dbname=$1
	echo -n "Enter table name to select from: "
	read tablename
	filepath="$DBMS_DIR/$dbname/$tablename"

	if [ ! -f "$filepath" ]; then
		echo "Table doesnot exist."
		return
	fi
	echo "Content Table [$tablename]:"
	column -t -s ',' "$filepath"
}

delete_from_table(){
	dbname=$1
	echo -n "Enter table name to delete from: "
	read tablename
	filepath="$DBMS_DIR/$dbname/$tablename"

	if [ ! -f "$filepath" ]; then
		echo "Table doesnot exist."
		return
	fi

	echo -n "Enter value to match for delete : "
	read value
	
	header=$(head -n 1 "$filepath")
	tail -n +2 "$filepath" | grep -v "$value" > "$filepath.tmp"
	echo "$header" > "$filepath"
	cat "$filepath.tmp" >> "$filepath"
	rm "$filepath.tmp"

	echo "Rows with value '$value' deleted. "
}

update_table(){
	dbname=$1
	echo -n "Enter table name update: "
	read tablename
	filepath="$DBMS_DIR/$dbname/$tablename"

	if [ ! -f "$filepath" ]; then
		echo "Table does not exist."
		return
	fi

	echo -n "Enter value to search for any column: "
	read search_value

	header=$(head -n 1 "$filepath")
	IFS=',' read -ra columns <<< "$header"

	echo "Enter new value for row:"
	row=""
	for col in "${columns[@]}"; do
		echo -n "Enter value for [$col]: "
		read value
		row+="$value,"
	done
	row=${row%,}

	matched=false
	echo "$header" > "$filepath.tmp"

	while IFS= read -r line; do
		if [[ "$line" == *"$search_value"* ]]; then
			echo "$row" >> "$filepath.tmp"
			matched=true
		else
			echo "$line" >> "$filepath.tmp"
		fi
	done < <(tail -n +2 "$filepath")

	if $matched; then
		mv "$filepath.tmp" "$filepath"
		echo "Matching rows update."
	else
		rm "$filepath.tmp"
		echo "No matching rows found."
	fi
}


main_menu














