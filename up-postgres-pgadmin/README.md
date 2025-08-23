# PostgreSQL + pgAdmin with Docker Compose

This project provides a simple setup for running **PostgreSQL** with **pgAdmin** using Docker Compose.  
It automatically initializes the database with the **Northwind** sample schema.

## Services
- **PostgreSQL**
  - Image: `postgres:latest`
  - Port: `55432` (mapped to `5432` inside container)
  - Default database: `northwind`
  - User: `postgres`
  - Password: `postgres`
  - Automatically loads `northwind.sql` on first run

- **pgAdmin**
  - Image: `dpage/pgadmin4`
  - Port: `5050`
  - Default login:
    - Email: `pgadmin4@pgadmin.org`
    - Password: `postgres`

## Volumes
- `postgresql_data` → persists PostgreSQL data  
- `pgadmin_root_prefs` → saves pgAdmin user preferences  
- `pgadmin_working_dir` → pgAdmin internal data  
- `./files` → shared folder between both containers (for scripts, dumps, etc.)  

## Usage
1. Clone this repository  
2. Make sure the file `northwind.sql` exists in the project root  
3. Start the containers:
```bash
docker-compose up -d
```

4. Access pgAdmin at: [http://localhost:5050](http://localhost:5050)
5. Add a new server in pgAdmin with:
   * **Name**: `Postgres DB`
   * **Host**: `db`
   * **Port**: `5432`
   * **Database**: `northwind`
   * **User**: `postgres`
   * **Password**: `postgres`

## Stopping
To stop and remove containers:
```bash
docker-compose down
```

To stop but keep data:
```bash
docker-compose down -v
```

## Notes
* The `northwind.sql` file is executed **only the first time** the database is created.
* If you want to re-run the initialization, remove the existing volume:
```bash
docker-compose down -v
docker-compose up -d
```

* Place additional `.sql` or `.sh` scripts inside the `./files` directory to run them manually inside the containers.