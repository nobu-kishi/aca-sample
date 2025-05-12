#!/bin/bash

BASTION_NAME="$1"
RESOURCE_GROUP="$2"
VM_NAME="$3"
LOCAL_PORT="$5"
PORTS=(22 8080 3000)

# VMのリソースID取得
VM_RESOURCE_ID=$(az vm show \
  --name "$VM_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --query id \
  --output tsv)

for PORT in "${PORTS[@]}"; do

  # sshポートが重複しないように、ローカルポートを2222に設定
  if [[ "$PORT" -eq 22 ]]; then
    LOCAL_PORT=2222
  fi

  az network bastion tunnel \
    --name "$BASTION_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --target-resource-id "$VM_RESOURCE_ID" \
    --resource-port "$PORT" \
    --port "$LOCAL_PORT" &

done

# バックグラウンドのすべてのポートフォワーディングプロセスを待つ
wait
