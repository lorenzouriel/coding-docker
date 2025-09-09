# Running per environment
```bash
# For Dev
docker-compose --env-file .env.dev up -d

# For QA
docker-compose --env-file .env.qa up -d

# For Prod
docker-compose --env-file .env.prod up -d

# Running All
docker-compose -f docker-compose-all.yaml up -d
```
