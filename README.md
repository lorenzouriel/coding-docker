# Coding Docker

Welcome to **Coding Docker**, a personal collection of Dockerized solutions.

## Projects
### 1. `sql-server-bckp`
A Docker solution to automate SQL Server database backups locally.

**Features:**
- SQL Server container with mounted volumes
- Automated scheduled backup scripts
- Persistent storage for backup files

### 2. `sql-server-cloud-bckp`
A Dockerized setup to automate SQL Server backups and upload them to cloud storage.

**Features:**
- SQL Server container
- Integration with cloud services (Azure Blob Storage)
- Scheduled backup and upload tasks

### 3. `up-ssrs`
Deploy SQL Server Reporting Services (SSRS) using Docker.

**Features:**
- Easy SSRS setup for development/testing
- Pre-configured environment for report deployment
- Environment variables for credentials and server settings

## Getting Started
To run a solution:
1. Navigate to the project: `cd <project-name>`
2. Check the README.md of each

## Requirements
* [Docker](https://docs.docker.com/get-docker/)
* [Docker Compose](https://docs.docker.com/compose/)
* Cloud CLI tools if applicable (e.g., AWS CLI, Azure CLI)