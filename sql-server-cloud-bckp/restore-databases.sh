#!/bin/bash

echo "Checking if SQL is up..."
/opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P "$MSSQL_SA_PASSWORD" -Q "SELECT 1" > /dev/null 2>&1

echo "Restoring database..."

/opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P "$MSSQL_SA_PASSWORD" -Q "
RESTORE DATABASE [waves] 
FROM DISK = N'/var/opt/mssql/backup/fullbckps/example.bak' 
WITH 
    MOVE N'waves' TO N'/var/opt/mssql/data/example.mdf',
    MOVE N'COLD' TO N'/var/opt/mssql/data/COLD.ndf',
    MOVE N'WARM' TO N'/var/opt/mssql/data/WARM.ndf',
    MOVE N'HOT' TO N'/var/opt/mssql/data/HOT.ndf',
    MOVE N'example_log' TO N'/var/opt/mssql/data/example_log.ldf',  
    NOUNLOAD,  
    STATS = 5;

GO
"

echo "Database restored succesfully!"