#!/usr/bin/env bash

SQL_DIR="./SQL Scripts"
CONTAINER_NAME="sqlserver"
DB_USER="sa"
DB_PASS="YourStrongPassword123!"

if [ ! -d "$SQL_DIR" ]; then
    echo "Error: Directory '$SQL_DIR' not found."
    exit 1
fi

# Enable recursive globbing and null globbing
shopt -s globstar nullglob
sql_files=("$SQL_DIR"/**/*.sql)

if [ ${#sql_files[@]} -eq 0 ]; then
    echo "No .sql files found in '$SQL_DIR'."
    exit 1
fi

echo "=================================================="
echo "      SQL DATA EXPLORATION CRIME INDIA"
echo "=================================================="
echo "Available SQL Scripts across all Phases:"
echo ""

PS3="Select a script number to execute (or type 'q' to quit): "

select file in "${sql_files[@]}" "Quit"; do
    if [ "$REPLY" = "q" ] || [ "$file" = "Quit" ]; then
        echo "Exiting script runner."
        exit 0
    elif [ -n "$file" ]; then
        echo ""
        echo "[EXEC] Running $file against SQL Server..."
        echo "--------------------------------------------------"
        
        docker exec -i "$CONTAINER_NAME" /opt/mssql-tools18/bin/sqlcmd \
            -S localhost \
            -U "$DB_USER" \
            -P "$DB_PASS" \
            -C < "$file"

        echo "--------------------------------------------------"
        echo "[SUCCESS] Finished executing $file."
        break
    else
        echo "Invalid selection. Please enter a valid option number."
    fi
done