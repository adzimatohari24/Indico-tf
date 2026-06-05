#!/bin/bash
set -e

echo "==> Terraform Init"
terraform init

echo "==> Terraform Format"
terraform fmt -recursive

echo "==> Terraform Validate"
terraform validate

echo "==> Terraform Plan"
terraform plan