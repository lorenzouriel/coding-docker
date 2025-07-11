# How to Run

#### 1. First build the solution: `docker build -t sqlserver-backup .`

#### 2. After completing the build, run the container pointing to your `.env` file: `docker run -d --name sqlserver-backup -p 1433:1433 --env-file .env sqlserver-backup`

Example of `.env`:
```bash
# SQL Server
ACCEPT_EULA=Y
MSSQL_SA_PASSWORD=Password
MSSQL_PID=Developer

# Blob Storage
BLOB_STORAGE_URL="https://your-storage.blob.core.windows.net/your-container?sas-token"
DEST_DIR="/your/dir/backup/"
AZCOPY_CMD="/your/dir/azcopy"
```

#### 3. Check the logs to track the restoration of the backups: `docker logs sqlserver-backup`

## Possible Solutions
- `BACPAC`: It is not possible to import a database using BACPAC when it contains a cross-database reference (`Cross-Database Reference`). This occurs because some database is referenced in multiple tables, which prevents the database from being released for import.

- `SQL Script (Empty)`: Empty SQL scripts work, but you need to update the scripts to reflect the correct file path.

- `SQL Script (With Data)`: These also work, but, as with empty scripts, you need to adjust the path of the files in the script. One downside is that importing the structure and data took a long time, taking approximately 15 minutes. In addition, the resulting file size was much larger than the backup (15GB versus 652MB), which made the process heavier and less efficient.

- `BACKUP`: Backup seems to be the most effective and efficient solution, offering better results in terms of time and file size.

## Solution Idea with Backup
- `Import`: Import the .bak from a storage blob, add a script called `import-bak-files.sh`.
- `Build`: Build the image with the two scripts running in sequence, first `import-bak-files.sh` to bring the files and then `resore-databases.sh`