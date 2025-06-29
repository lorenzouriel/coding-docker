<div align="center">
  <p>
    <a name="stars"><img src="https://img.shields.io/github/stars/lorenzouriel/coding-docker?style=for-the-badge"></a>
    <a name="forks"><img src="https://img.shields.io/github/forks/lorenzouriel/coding-docker?logoColor=green&style=for-the-badge"></a>
    <a name="contributions"><img src="https://img.shields.io/github/contributors/lorenzouriel/coding-docker?logoColor=green&style=for-the-badge"></a>
    <a name="madeWith"><img src="https://img.shields.io/badge/Made%20with-Markdown-1f425f.svg?style=for-the-badge"></a>
  </p>
</div>

# 🐳 Coding Docker

[![Docker](https://img.shields.io/badge/Docker-24.0+-2496ED?logo=docker&style=flat-square)](https://www.docker.com/)
[![Docker Compose](https://img.shields.io/badge/Compose-1.29+-2496ED?logo=docker&style=flat-square)](https://docs.docker.com/compose/)

Welcome to **Coding Docker**, a personal collection of Dockerized solutions. Each subfolder includes a self-contained setup designed for practical use or experimentation.

## 📦 Projects
### 1. `sql-server-bckp`
Automates SQL Server database backups locally using Docker.
**Features:**
- SQL Server container with mounted volumes  
- Scheduled backup scripts  
- Persistent backup storage  

### 2. `sql-server-cloud-bckp`
Extends local SQL backups with automated **cloud uploads** (e.g., Azure Blob).
**Features:**
- SQL Server containerized instance  
- Cloud storage integration (Azure CLI required)  
- Automated backup + upload  

### 3. `up-ssrs`
Deploy **SQL Server Reporting Services (SSRS)** in a container.

**Features:**
- Pre-configured SSRS environment  
- Ideal for local dev and report testing  
- Environment-variable-based configuration  

## 🚀 Getting Started
To run a project:
```bash
cd <project-name>
```
Then follow the individual project's `README.md` for environment variables, volumes, and cloud credentials.

## 🧰 Requirements
* [Docker](https://docs.docker.com/get-docker/)
* [Docker Compose](https://docs.docker.com/compose/)
* Cloud CLI tools (if using `sql-server-cloud-bckp`)
