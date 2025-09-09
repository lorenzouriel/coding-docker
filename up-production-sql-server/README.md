# Plan (quick)
1. Prepare host: dedicated disk, filesystem, mount point, permissions.
2. Create persistent volumes (bind mount or Docker named volume).
3. Run SQL Server container with proper env, resource limits, and healthcheck.
4. Secure credentials with secrets and create non-SA admin.
5. Backups & DR: scheduled native backups, copy to object storage.
6. Monitoring & maintenance: DBCC, indexing, alerting.
7. (Optional) Move to Kubernetes StatefulSet for HA/scale.

# 1 Host preparation (recommended)
* Use a **dedicated disk** for SQL data (SSD/NVMe). Example: `/dev/sdb`.
* Format as `ext4` or `xfs` (ext4 is fine), mount at `/mnt/mssql-data`.
* Use `noatime` and a mountpoint with plenty of space.

Example (run as root / sudo — adjust device names):
```bash
# replace /dev/sdb with your device
sudo mkfs.ext4 -F /dev/sdb
sudo mkdir -p /mnt/mssql-data
echo '/dev/sdb  /mnt/mssql-data  ext4  defaults,noatime  0 2' | sudo tee -a /etc/fstab
sudo mount -a

# create folders for data/backups/logs
sudo mkdir -p /mnt/mssql-data/data /mnt/mssql-data/logs /mnt/mssql-data/backups
# set ownership to mssql user uid:gid that container uses (mssql: mssql is usually uid 10001)
# we'll chown after the container creates the user; below are permission commands to run later
```

> Note: using a dedicated mount prevents accidental OS disk fill and gives you control over disk performance.

# 2 Run SQL Server container (single-host) — with Docker
Create a Docker named volume or bind mount to `/var/opt/mssql` (SQL Server on Linux stores DB files in `/var/opt/mssql`).

**Recommended:** use bind mounts to your dedicated disk so you control the filesystem and performance:
```bash
# secure SA password — must meet complexity rules
export SA_PASS='YourVeryStr0ng!Passw0rd'

docker run -d \
  --name mssql-prod \
  --restart unless-stopped \
  -e "ACCEPT_EULA=Y" \
  -e "MSSQL_PID=Standard" \
  -e "SA_PASSWORD=${SA_PASS}" \
  -p 1433:1433 \
  -v /mnt/mssql-data/data:/var/opt/mssql/data \
  -v /mnt/mssql-data/logs:/var/opt/mssql/log \
  -v /mnt/mssql-data/backups:/var/opt/mssql/backups \
  --ulimit nofile=65536:65536 \
  --memory=8g --cpus="4" \
  mcr.microsoft.com/mssql/server:2022-latest
```

Important notes:
* Use `MSSQL_PID` to choose edition (e.g. `Express`, `Developer`, `Standard`, `Enterprise`) depending on licensing.
* Memory/CPU set appropriately — SQL Server prefers having a lot of memory; tune `--memory` and SQL `max server memory` later.
* `--ulimit nofile` helps with many connections/files.
* Map separate host directories for data, logs and backups so you can snapshot/backup logs separately.

After container starts, set ownership to the mssql user inside container. If container created DB files already, chown them on host to the UID the container runs as (commonly `mssql` uid 10001 — but verify):
```bash
# find container uid for mssql home (run as root)
CONTAINER_ID=$(docker ps -qf "name=mssql-prod")
docker exec -it $CONTAINER_ID id mssql
# example output: uid=10001(mssql) gid=0(root) groups=0(root)
# then chown on host:
sudo chown -R 10001:0 /mnt/mssql-data
```

# 3 Basic post-install hardening & config
Connect and change settings using `sqlcmd` (install on host or use `docker exec`).

Create a non-SA sysadmin user and disable SA login if you want:
```bash
docker exec -it mssql-prod /opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P "$SA_PASS" -Q "
CREATE LOGIN admin_user WITH PASSWORD = 'AnotherStr0ng!Passw0rd';
ALTER SERVER ROLE sysadmin ADD MEMBER [admin_user];
ALTER LOGIN [sa] DISABLE;
"
```

Then test admin_user login.

Set `max server memory` to leave room for OS:
```bash
# set to 6GB as example (if container/machine has 8GB)
docker exec -it mssql-prod /opt/mssql-tools/bin/sqlcmd -S localhost -U admin_user -P 'AnotherStr0ng!Passw0rd' -Q "
EXEC sp_configure 'show advanced options', 1; RECONFIGURE;
EXEC sp_configure 'max server memory (MB)', 6144; RECONFIGURE;
"
```

Enable TLS (recommended) — generate cert on host and mount it, then configure SQL Server to use cert. This is a multi-step process; at minimum, ensure connections inside private network or via VPN.

# 4 Backups & DR
Do **regular full backups**, plus differential and transaction log backups for point-in-time recovery (if DB in full recovery model).

Example backup script (run in host cron or a CI job) that uses `docker exec` with `sqlcmd` to create a backup file inside mounted backups directory and then push to S3/Blob:

`/usr/local/bin/mssql_backup.sh`
```bash
#!/usr/bin/env bash
CONTAINER="mssql-prod"
DB="YourDatabase"
BACKUP_DIR="/var/opt/mssql/backups"
DATE=$(date +%F_%H%M)
BACKUP_FILE="${BACKUP_DIR}/${DB}_full_${DATE}.bak"

docker exec -i $CONTAINER /opt/mssql-tools/bin/sqlcmd -S localhost -U admin_user -P 'AnotherStr0ng!Passw0rd' -Q "BACKUP DATABASE [$DB] TO DISK=N'${BACKUP_FILE}' WITH INIT, CHECKSUM;"
# Then copy to remote object storage (example with aws cli)
# aws s3 cp /mnt/mssql-data/backups/${DB}_full_${DATE}.bak s3://my-backups-bucket/sqlserver/${DB}/
```

Schedule:
* Full backup: daily (or weekly based on size/requirements)
* Differential: every 4–12 hours
* Transaction log backups: every 10–60 minutes for low RPO

Test restores regularly (monthly) to verify backups.

If using cloud: prefer **Backup to URL** (SQL Server supports BACKUP TO URL) for direct backup to Azure blob (native) or copy to S3 after backup.

# 5 Monitoring & alerts
* Export metrics: use `mssql_exporter` for Prometheus or use `telegraf` + InfluxDB. Monitor: CPU, memory, disk I/O, buffer cache, page life expectancy, log growth, long-running queries.
* DB alerts: disk usage, failed backups, DBCC CHECKDB failures, high wait stats.
* Use Grafana dashboards for visualization.

# 6 Maintenance (important)
* Daily: transaction log backup, check free disk space, check job failures
* Weekly: index rebuild or reorganize based on fragmentation, update statistics
* Monthly: `DBCC CHECKDB` on each DB (run on a restored copy if possible or during maintenance window)
* Keep trace flags and autogrowth settings sane: pre-allocate files to reduce autogrowth frequency and fragmentation.

Example: set autogrowth to fixed MB (e.g., data file growth 512MB, log growth 256MB).

# 7 Security best practices
* Use Docker secrets (Swarm) or Kubernetes secrets for passwords — do **not** store SA in plain env in production.
* Restrict network: host firewall, VPC rules; only allow application subnets to talk to DB.
* Use TLS for connections. Turn on `Force Encryption`.
* Use least privilege accounts for apps; avoid using sysadmin roles.
* Enable Transparent Data Encryption (TDE) for encryption at rest if required (note: TDE may require licensing—check edition licensing).
* Keep images patched: schedule update windows to pull `mcr.microsoft.com/mssql/server:2022-latest` (or a specific tagged version you test and approve).

# 8 High Availability (options)
* For single-host, consider VM-level HA (host replication) if container HA isn’t available.
* For true SQL Server HA (Always On Availability Groups) you’ll need:
  * Multiple SQL Server instances (containers or VMs)
  * Proper cluster networking and SAN or replicated storage
  * Kubernetes + StatefulSets + persistent volumes can host AG replicas (complex)
* Alternative simpler approach: active-passive using regular failover at infra level (VM failover, storage replication).

If you want HA in containers, Kubernetes StatefulSet + PVs + an operator (or manual setup of AG) is typical, but this is advanced and I can provide a full example if you want it.

# 9 Docker Compose example (simple)
`docker-compose.yml` for single-host production-ish deployment (still consider secrets & systemd for restarting):
```yaml
services:
  mssql:
    image: mcr.microsoft.com/mssql/server:2022-latest
    container_name: mssql-prod
    restart: unless-stopped
    environment:
      ACCEPT_EULA: "Y"
      MSSQL_PID: "Standard"
      SA_PASSWORD: "${SA_PASSWORD}"
    ports:
      - "14330:1433"
    ulimits:
      nofile:
        soft: 65536
        hard: 65536
    volumes:
      - ./mnt/mssql-data/data:/var/opt/mssql/data
      - ./mnt/mssql-data/logs:/var/opt/mssql/log
      - ./mnt/mssql-data/backups:/var/opt/mssql/backups
    deploy:
      resources:
        limits:
          memory: 8G
          cpus: '4.0'
```

Use `.env` file for `SA_PASSWORD` when deploying with Compose (but in production prefer secrets).

# 10 Kubernetes StatefulSet (starter)
If you want to run on k8s for better orchestration, here’s a minimal idea: use a StatefulSet with a PersistentVolumeClaim template (StorageClass must provide RWX/RWO depending on your backend). This is a simplified snippet — SQL Server AG in k8s needs extra steps.
```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: mssql
spec:
  serviceName: "mssql"
  replicas: 1
  selector:
    matchLabels:
      app: mssql
  template:
    metadata:
      labels:
        app: mssql
    spec:
      containers:
      - name: mssql
        image: mcr.microsoft.com/mssql/server:2022-latest
        ports:
        - containerPort: 1433
        env:
        - name: ACCEPT_EULA
          value: "Y"
        - name: SA_PASSWORD
          valueFrom:
            secretKeyRef:
              name: mssql-secret
              key: sa-password
        volumeMounts:
        - name: mssql-data
          mountPath: /var/opt/mssql
        resources:
          limits:
            memory: "8Gi"
            cpu: "4"
  volumeClaimTemplates:
  - metadata:
      name: mssql-data
    spec:
      accessModes: ["ReadWriteOnce"]
      storageClassName: "fast-ssd"
      resources:
        requests:
          storage: 500Gi
```

> StatefulSet gives stable network identity and persistent volumes. For HA, add more replicas and configure Always On Availability Groups.

# Quick checklist before you go live
* [ ] Dedicated SSD backed mount for DB files.
* [ ] Backups tested and stored off-host (object storage).
* [ ] Monitoring and alerts in place.
* [ ] TLS enforced for client connections.
* [ ] Least-privilege accounts for apps.
* [ ] Regular maintenance jobs (DBCC/Index/Stats).
* [ ] Patch/update plan for SQL images.
* [ ] Disaster Recovery runbook & tested restores.