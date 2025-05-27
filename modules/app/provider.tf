# NOTE: デフォルトではterraform/azapiと解釈されるため、azure/azapiを使用するモジュールで宣言する
terraform {
  required_providers {
    azapi = {
      source  = "azure/azapi"
      version = "2.4.0"
    }
  }
}