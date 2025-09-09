# How to Run
- `docker compose up -d`

# Docker Compose 
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
      SA_PASSWORD: "${MSSQL_SA_PASSWORD}"
      MSSQL_AGENT_ENABLED: "true"
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

# Kubernetes StatefulSet (starter)
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