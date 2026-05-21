# terraform-azure-infrastructure

実務で担当した Azure インフラの Terraform 管理コードを抜粋したものです。

## 対応内容

- Azure Blob Storage をリモートバックエンドとして tfstate を管理
- 既存リソースグループを `data` ソースで参照し、Terraform 管理外リソースと共存する構成
- DNS ゾーンの作成・管理
- アクセス制御用 IP 許可リストを `locals` で一元管理し、複数リソースから参照できる構造に整理
- 環境ごとの子ワークスペースを `develop/` ディレクトリで分離

## 使用技術

- Terraform `1.8.2`
- azurerm `3.80.0`
- Microsoft Azure（Japan East）