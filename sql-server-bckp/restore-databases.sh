#!/bin/bash

# Aguarda o SQL Server iniciar completamente
echo "Aguardando o SQL Server iniciar..."
sleep 20s

# Define a senha do administrador
SA_PASSWORD="YourStrongPassword!123"

# Conecta ao SQL Server e restaura os bancos com os respectivos filegroups

echo "Restaurando o banco de dados auxiliar (waves)..."
/opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P "$SA_PASSWORD" -Q "
RESTORE DATABASE [waves] 
FROM DISK = N'/var/opt/mssql/backup/waves.bak'"

echo "Restauração dos bancos de dados concluída."
