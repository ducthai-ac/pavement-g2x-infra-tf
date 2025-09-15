# G2X Wiki Infrastructure

Infrastructure as Code cho dự án G2X Wiki sử dụng Terraform trên AWS Sydney region.

## Kiến trúc

- **EC2**: Chạy FE và API containers với Docker
- **MySQL**: Local database trong Docker container
- **S3**: Lưu trữ hình ảnh
- **SES**: Gửi email
- **EBS Backup**: Backup hàng ngày với retention 7 ngày

## Cấu trúc thư mục

```
├── modules/
│   ├── ec2/          # EC2 instance với Docker setup
│   ├── s3/           # S3 bucket cho images
│   ├── ses/          # SES configuration
│   └── backup/       # EBS backup daily
├── main.tf           # Main configuration
├── variables.tf      # Variables definition
├── outputs.tf        # Outputs
└── provider.tf       # AWS provider
```

## Cách sử dụng

1. **Chuẩn bị**:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. **Cấu hình terraform.tfvars**:
   - Cập nhật `vpc_id` và `subnet_ids` từ VPC hiện có
   - Cập nhật `key_pair_name` 
   - Cập nhật `ses_domain`

3. **Deploy**:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

## Sau khi deploy

1. **SSH vào EC2**:
   ```bash
   ssh -i your-key.pem ec2-user@<public_ip>
   ```

2. **Kiểm tra containers**:
   ```bash
   cd /opt/app
   docker-compose ps
   ```

3. **Upload code**:
   - Frontend code vào `/opt/app/frontend/`
   - API code vào `/opt/app/api/`

4. **Cấu hình SES**:
   - Thêm DNS records cho domain verification
   - Thêm DKIM records

## Thông tin kết nối

- **MySQL**: 
  - Host: localhost:3306
  - Database: g2x-wiki
  - User: appuser
  - Password: apppassword

- **S3 Bucket**: `g2x-wiki-prod-images`
- **Frontend**: http://<public_ip>:3000
- **API**: http://<public_ip>:8000

## Backup

- EBS snapshots tự động hàng ngày lúc 2:00 AM
- Retention: 7 ngày
- Backup vault: `g2x-wiki-prod-backup-vault`# pavement-g2x-infra-tf
