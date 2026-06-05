#!/bin/bash
# tf-check.sh - Automasi terraform init, fmt, validate, dan plan

set -e  # stop jika ada command yang gagal

# Warna output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Helper functions
info()    { echo -e "${CYAN}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[OK]${NC} $1"; }
warning() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error()   { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

echo ""
echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}   Terraform Check - Indico-tf          ${NC}"
echo -e "${CYAN}========================================${NC}"
echo ""

# Cek terraform terinstall
if ! command -v terraform &> /dev/null; then
  error "Terraform tidak ditemukan. Install dulu: https://developer.hashicorp.com/terraform/install"
fi

TF_VERSION=$(terraform version -json | python3 -c "import sys,json; print(json.load(sys.stdin)['terraform_version'])" 2>/dev/null || terraform version | head -1)
info "Terraform version: ${TF_VERSION}"
echo ""

# ----------------------------------------
# STEP 1: terraform init
# ----------------------------------------
info "Step 1/4 - terraform init..."
if terraform init -input=false; then
  success "init selesai"
else
  error "init gagal"
fi
echo ""

# ----------------------------------------
# STEP 2: terraform fmt
# ----------------------------------------
info "Step 2/4 - terraform fmt (cek formatting)..."
FMT_OUTPUT=$(terraform fmt -check -recursive 2>&1) || true

if [ -z "$FMT_OUTPUT" ]; then
  success "fmt OK - semua file sudah terformat dengan benar"
else
  warning "fmt menemukan file yang perlu diformat:"
  echo "$FMT_OUTPUT"
  echo ""
  read -p "  Auto-fix formatting sekarang? (y/n): " FMT_FIX
  if [[ "$FMT_FIX" =~ ^[Yy]$ ]]; then
    terraform fmt -recursive
    success "fmt - file berhasil diformat"
  else
    warning "fmt dilewati - jalankan 'terraform fmt -recursive' untuk fix manual"
  fi
fi
echo ""

# ----------------------------------------
# STEP 3: terraform validate
# ----------------------------------------
info "Step 3/4 - terraform validate..."
if terraform validate; then
  success "validate OK - konfigurasi valid"
else
  error "validate gagal - periksa error di atas"
fi
echo ""

# ----------------------------------------
# STEP 4: terraform plan
# ----------------------------------------
info "Step 4/4 - terraform plan..."

# Cek apakah terraform.tfvars ada
if [ ! -f "terraform.tfvars" ]; then
  warning "terraform.tfvars tidak ditemukan"
  warning "Salin dan isi dulu: cp examples/complete/terraform.tfvars.example terraform.tfvars"
  echo ""
  read -p "  Lanjut plan tanpa tfvars? (y/n): " CONTINUE_PLAN
  if [[ ! "$CONTINUE_PLAN" =~ ^[Yy]$ ]]; then
    info "Plan dibatalkan. Buat terraform.tfvars terlebih dahulu."
    exit 0
  fi
fi

PLAN_FILE="tfplan-$(date +%Y%m%d-%H%M%S).out"
info "Menyimpan plan ke: ${PLAN_FILE}"
echo ""

if terraform plan -out="${PLAN_FILE}" -input=false; then
  echo ""
  success "plan selesai - plan disimpan ke ${PLAN_FILE}"
  echo ""
  info "Untuk apply, jalankan:"
  echo -e "  ${YELLOW}terraform apply \"${PLAN_FILE}\"${NC}"
else
  error "plan gagal - periksa error di atas"
fi

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}   Semua step selesai tanpa error       ${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
