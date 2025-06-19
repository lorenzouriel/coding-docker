# Command
```bash
docker run -d -p 1433:1433 -p 8060:8060 -v C:/temp/:C:/temp/ -e sa_password=SSRS_ADMIN -e ACCEPT_EULA=Y -e ssrs_user=SSRSAdmin -e ssrs_password=SSRS_ADMIN --memory 6048mb phola/ssrs
```