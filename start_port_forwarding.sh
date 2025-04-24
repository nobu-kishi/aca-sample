#!/bin/bash

BASTION_NAME="$1"
BASTION_RG="$2"
VM_NAME="$3"
VM_PORT="$4"
LOCAL_PORT="$5"

# VMのリソースID取得
VM_RESOURCE_ID=$(az vm show \
  --name "$VM_NAME" \
  --resource-group "$VM_RG" \
  --query id \
  --output tsv)

# Bastion経由でSSH接続
az network bastion tunnel \
  --name "$BASTION_NAME" \
  --resource-group "$BASTION_RG" \
  --target-resource-id "$VM_RESOURCE_ID" \
  --resource-port "$VM_PORT" \
  --port "$LOCAL_PORT"