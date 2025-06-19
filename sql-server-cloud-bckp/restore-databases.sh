#!/bin/bash

# export $(cat .env | xargs)

# Função para verificar se o SQL Server está disponível
echo "Verificando se o SQL Server está disponível..."
/opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P "$MSSQL_SA_PASSWORD" -Q "SELECT 1" > /dev/null 2>&1

# Combina os dois restores em um único script com um GO
echo "Restaurando os bancos de dados..."

/opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P "$MSSQL_SA_PASSWORD" -Q "
-- Restauração do banco de dados principal
RESTORE DATABASE [waves] 
FROM DISK = N'/var/opt/mssql/backup/fullbckps/waves.bak' 
WITH 
    MOVE N'waves' TO N'/var/opt/mssql/data/waves.mdf',
    MOVE N'COLD' TO N'/var/opt/mssql/data/COLD.ndf',
    MOVE N'WARM' TO N'/var/opt/mssql/data/WARM.ndf',
    MOVE N'HOT' TO N'/var/opt/mssql/data/HOT.ndf',
    MOVE N'waves_log' TO N'/var/opt/mssql/data/waves_log.ldf',  
    NOUNLOAD,  
    STATS = 5;

GO

RESTORE DATABASE [waves.aux] 
FROM DISK = N'/var/opt/mssql/backup/fullbckps/waves.aux.bak' 
WITH 
    MOVE N'waves.aux' TO N'/var/opt/mssql/data/waves.aux_Primary.mdf',  
    MOVE N'waves.aux_log' TO N'/var/opt/mssql/data/waves.aux_Primary.ldf',  
    NOUNLOAD,  
    STATS = 5;
GO
"

echo "Restauração dos bancos de dados concluída."
