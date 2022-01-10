# terraform-example

# Features

Terraform で Azure VM を作成するサンプルコード

実行すると，Azure VM が作成され，docker で nginx が起動した状態となります．

# Requirements

* Azure アカウント

* Terraform  
 https://www.terraform.io/downloads

* Azure CLI  
 https://docs.microsoft.com/ja-jp/cli/azure/install-azure-cli  
 ※ Azure CLI で az login が必要です．

# Usage

変更内容確認

```bash
cd terraform-example
terraform plan
```

実行

```bash
terraform apply
```

削除

```bash
terraform destroy
```

# Note

設定値などは，Terraform の公式ドキュメントを参照ください．

https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs