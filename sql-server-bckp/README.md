1. `docker build -t sqlserver-backup .`
2. `docker run -d --name sqlserver-backup -p 1434:1433 sqlserver-backup`
3. `docker logs sqlserver-backup`