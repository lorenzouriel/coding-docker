#!/bin/bash

# Definir variáveis de ambiente
BLOB_STORAGE_URL=$BLOB_STORAGE_URL
DEST_DIR=$DEST_DIR
AZCOPY_CMD=$AZCOPY_CMD

echo "Baixando os backups do Blob Storage para o diretório de destino..."

# Comando para copiar arquivos do Blob Storage para o diretório de destino
$AZCOPY_CMD cp "$BLOB_STORAGE_URL" $DEST_DIR --recursive=true

# Verificar se o comando foi bem-sucedido
if [ $? -eq 0 ]; then
  echo "Backups baixados com sucesso!"
else
  echo "Erro ao baixar os backups."
  exit 1
fi