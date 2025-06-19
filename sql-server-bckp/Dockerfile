# Baixa a imagem oficial do SQL Server
FROM mcr.microsoft.com/mssql/server:2019-latest

# Instalar o mssql-tools (sqlcmd) como root
USER root

# Atualizar e instalar dependências
RUN apt-get update \
    && apt-get install -y curl gnupg2 \
    && curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
    && curl https://packages.microsoft.com/config/debian/10/prod.list > /etc/apt/sources.list.d/mssql-release.list \
    && apt-get update \
    && ACCEPT_EULA=Y apt-get install -y mssql-tools

# Define as variáveis de ambiente necessárias para o SQL Server
ENV ACCEPT_EULA=Y
ENV MSSQL_SA_PASSWORD=YourStrongPassword!123
ENV MSSQL_PID=Developer

# Cria um diretório para armazenar os backups
RUN mkdir -p /var/opt/mssql/backup
COPY backups/waves.bak /var/opt/mssql/backup/

# Copia o script de inicialização com permissões
COPY --chmod=0755 restore-databases.sh /usr/src/app/restore-databases.sh

# Exposição da porta padrão do SQL Server
EXPOSE 1433

# Comando de inicialização do SQL Server com o script de restauração dos backups
CMD /bin/bash /usr/src/app/restore-databases.sh & /opt/mssql/bin/sqlservr
