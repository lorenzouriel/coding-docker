# Running per environment
```bash
# For Dev
docker-compose --env-file .env.dev up -d

# For QA
docker-compose --env-file .env.qa up -d

# For Prod
docker-compose --env-file .env.prod up -d
```

### Benefits:
- Same docker-compose.yml for all environments.
- Environment-specific .env controls password, ports, resources, and volumes.
- Easy to extend if new envs appear.