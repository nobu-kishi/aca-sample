#!/bin/bash

BASTION_NAME="$1"
BASTION_RG="$2"
VM_NAME="$3"
VM_RG="$4"
VM_USERNAME="$5"
SSH_KEY_PATH="${6:-"./bas_ssh_key.pem"}"  # 省略時はデフォルトの鍵パス

# VMのリソースID取得
VM_RESOURCE_ID=$(az vm show \
  --name "$VM_NAME" \
  --resource-group "$VM_RG" \
  --query id \
  --output tsv)

# Bastion経由でSSH接続
az network bastion ssh \
  --name "$BASTION_NAME" \
  --resource-group "$BASTION_RG" \
  --target-resource-id "$VM_RESOURCE_ID" \
  --auth-type ssh-key \
  --username "$VM_USERNAME" \
  --ssh-key "$SSH_KEY_PATH"