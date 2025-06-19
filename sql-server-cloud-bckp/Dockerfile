# Baixa a imagem oficial do SQL Server
FROM mcr.microsoft.com/mssql/server:2022-latest

# Instalar o mssql-tools (sqlcmd) como root
USER root

# Atualizar e instalar dependências
RUN apt-get update \
    && apt-get install -y curl gnupg2 \
    && curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
    && curl https://packages.microsoft.com/config/debian/10/prod.list > /etc/apt/sources.list.d/mssql-release.list \
    && apt-get update \
    && ACCEPT_EULA=Y apt-get install -y mssql-tools 

# Baixar e mover o azcopy
RUN curl -sL https://aka.ms/downloadazcopy-v10-linux | tar xz && \
    mv azcopy*/azcopy /usr/local/bin/azcopy && \
    rm -rf azcopy* && \
    # Verificar se o azcopy foi instalado corretamente
    ls -l /usr/local/bin/azcopy
    
# Cria um diretório para armazenar os backups
RUN mkdir -p /var/opt/mssql/backup

# Copia os scripts para o contêiner com permissões
COPY --chmod=0755 restore-databases.sh /usr/src/app/restore-databases.sh
COPY --chmod=0755 import-bak-files.sh /usr/src/app/import-bak-files.sh

# Exposição da porta padrão do SQL Server
EXPOSE 1433

# Comando de inicialização para baixar os backups e restaurar os bancos de dados
CMD /bin/bash /usr/src/app/import-bak-files.sh && /bin/bash /usr/src/app/restore-databases.sh & /opt/mssql/bin/sqlservr