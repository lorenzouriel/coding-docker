FROM mcr.microsoft.com/mssql/server:2022-latest

USER root

RUN apt-get update \
    && apt-get install -y curl gnupg2 \
    && curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
    && curl https://packages.microsoft.com/config/debian/10/prod.list > /etc/apt/sources.list.d/mssql-release.list \
    && apt-get update \
    && ACCEPT_EULA=Y apt-get install -y mssql-tools 

RUN curl -sL https://aka.ms/downloadazcopy-v10-linux | tar xz && \
    mv azcopy*/azcopy /usr/local/bin/azcopy && \
    rm -rf azcopy* && \
    ls -l /usr/local/bin/azcopy
    
RUN mkdir -p /var/opt/mssql/backup

COPY --chmod=0755 restore-databases.sh /usr/src/app/restore-databases.sh
COPY --chmod=0755 import-bak-files.sh /usr/src/app/import-bak-files.sh

EXPOSE 1433

CMD /bin/bash /usr/src/app/import-bak-files.sh && /bin/bash /usr/src/app/restore-databases.sh & /opt/mssql/bin/sqlservr