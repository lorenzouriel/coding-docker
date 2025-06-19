#!/bin/bash

# export $(cat .env | xargs)

# Função para verificar se o SQL Server está disponível
echo "Verificando se o SQL Server está disponível..."
/opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P "$MSSQL_SA_PASSWORD" -Q "SELECT 1" > /dev/null 2>&1

# Combina os dois restores em um único script com um GO
echo "Restaurando os bancos de dados..."

/opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P "$MSSQL_SA_PASSWORD" -Q "
-- Restauração do banco de dados principal
RESTORE DATABASE [geotracker.data] 
FROM DISK = N'/var/opt/mssql/backup/fullbckps/geotracker.data.bak' 
WITH 
    MOVE N'geotracker.data' TO N'/var/opt/mssql/data/geotracker.data.mdf',
    MOVE N'OLD' TO N'/var/opt/mssql/data/OLD.ndf',
    MOVE N'NEW' TO N'/var/opt/mssql/data/NEW.ndf',
    MOVE N'NEWEST' TO N'/var/opt/mssql/data/NEWEST.ndf',
    MOVE N'CORE' TO N'/var/opt/mssql/data/CORE.ndf',
    MOVE N'WK18' TO N'/var/opt/mssql/data/WK18.ndf',
    MOVE N'WK17' TO N'/var/opt/mssql/data/WK17.ndf',
    MOVE N'WK16' TO N'/var/opt/mssql/data/WK16.ndf',
    MOVE N'WK15' TO N'/var/opt/mssql/data/WK15.ndf',
    MOVE N'WK14' TO N'/var/opt/mssql/data/WK14.ndf',
    MOVE N'WK13' TO N'/var/opt/mssql/data/WK13.ndf',
    MOVE N'WK12' TO N'/var/opt/mssql/data/WK12.ndf',
    MOVE N'WK11' TO N'/var/opt/mssql/data/WK11.ndf',
    MOVE N'WK10' TO N'/var/opt/mssql/data/WK10.ndf',
    MOVE N'WK09' TO N'/var/opt/mssql/data/WK09.ndf',
    MOVE N'WK08' TO N'/var/opt/mssql/data/WK08.ndf',
    MOVE N'WK07' TO N'/var/opt/mssql/data/WK07.ndf',
    MOVE N'WK06' TO N'/var/opt/mssql/data/WK06.ndf',
    MOVE N'WK05' TO N'/var/opt/mssql/data/WK05.ndf',
    MOVE N'WK04' TO N'/var/opt/mssql/data/WK04.ndf',
    MOVE N'WK03' TO N'/var/opt/mssql/data/WK03.ndf',
    MOVE N'WK02' TO N'/var/opt/mssql/data/WK02.ndf',
    MOVE N'F20230113151413980' TO N'/var/opt/mssql/data/F20230113151413980.ndf',
    MOVE N'F20160111224657097' TO N'/var/opt/mssql/data/F20160111224657097.ndf',
    MOVE N'WK01' TO N'/var/opt/mssql/data/WK01.ndf',
    MOVE N'REST' TO N'/var/opt/mssql/data/REST.ndf',
    MOVE N'OLDEST' TO N'/var/opt/mssql/data/OLDEST.ndf',
    MOVE N'WK0' TO N'/var/opt/mssql/data/WK0.ndf',
    MOVE N'WK26' TO N'/var/opt/mssql/data/WK26.ndf',
    MOVE N'WK25' TO N'/var/opt/mssql/data/WK25.ndf',
    MOVE N'WK24' TO N'/var/opt/mssql/data/WK24.ndf',
    MOVE N'WK23' TO N'/var/opt/mssql/data/WK23.ndf',
    MOVE N'WK22' TO N'/var/opt/mssql/data/WK22.ndf',
    MOVE N'WK21' TO N'/var/opt/mssql/data/WK21.ndf',
    MOVE N'WK20' TO N'/var/opt/mssql/data/WK20.ndf',
    MOVE N'WK19' TO N'/var/opt/mssql/data/WK19.ndf',
    MOVE N'geotracker.data_log' TO N'/var/opt/mssql/data/geotracker.data_log.ldf',  
    NOUNLOAD,  
    STATS = 5;

GO

-- Restauração do banco de dados auxiliar
RESTORE DATABASE [geotracker.aux] 
FROM DISK = N'/var/opt/mssql/backup/fullbckps/geotracker.aux.bak' 
WITH 
    MOVE N'geotracker.aux' TO N'/var/opt/mssql/data/geotracker.aux_Primary.mdf',  
    MOVE N'geotracker.aux_log' TO N'/var/opt/mssql/data/geotracker.aux_Primary.ldf',  
    NOUNLOAD,  
    STATS = 5;
GO
"

echo "Restauração dos bancos de dados concluída."
