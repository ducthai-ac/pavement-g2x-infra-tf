# G2X Wiki Infrastructure

Infrastructure as Code for G2X Wiki project using Terraform on AWS Sydney region.

## Architecture

- **EC2**: Ubuntu instance running containerized applications
- **Docker Services**: Wiki API, Frontend, MySQL, Redis, Nginx
- **S3**: Image storage with CloudFront CDN
- **CloudFront**: CDN for fast image delivery
- **EBS Backup**: Daily automated backups
- **Elastic IP**: Static IP address

## Infrastructure Components

```
├── modules/
│   ├── ec2/          # EC2 instance with Docker setup
│   ├── s3/           # S3 bucket for images
│   ├── cloudfront/   # CloudFront distribution
│   └── backup/       # EBS backup configuration
├── main.tf           # Main configuration
├── variables.tf      # Variables definition
├── outputs.tf        # Outputs
└── provider.tf       # AWS provider
```

## Prerequisites

- AWS CLI configured
- Terraform >= 1.0
- Existing VPC and subnets
- EC2 Key Pair

## Quick Start

1. **Clone and configure**:
   ```bash
   git clone <repository-url>
   cd g2x-wiki-infra-tf
   cp terraform.tfvars.example terraform.tfvars
   ```

2. **Update terraform.tfvars**:
   ```hcl
   vpc_id = "vpc-xxxxxxxxx"
   subnet_ids = ["subnet-xxxxxxxxx", "subnet-yyyyyyyyy"]
   key_pair_name = "your-key-pair"
   domain_name = "your-domain.com"
   api_domain_name = "api.your-domain.com"
   ```

3. **Deploy infrastructure**:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

## Post-Deployment

### Access the server
```bash
ssh -i your-key.pem ubuntu@<elastic_ip>
```

### Check services
```bash
cd ~/wiki
docker compose ps
docker compose logs
```

### Service URLs
- **Frontend**: http://\<elastic_ip\> or https://your-domain.com
- **API**: http://\<elastic_ip\>:4000 or https://api.your-domain.com
- **Images**: https://\<cloudfront_domain\>

## Configuration

### Database Connection
```json
{
  "host": "mysql",
  "port": 3306,
  "username": "wiki_admin",
  "password": "letmein12345",
  "database": "g2x_wiki"
}
```

### Redis Connection
```json
{
  "host": "redis",
  "port": 6379,
  "password": "secret_redis"
}
```

### S3 Configuration
- **Bucket**: `g2x-wiki-{environment}-images`
- **Region**: ap-southeast-2
- **Access**: Via IAM user credentials

## Security

- SSH access restricted to company IPs:
  - 115.79.6.153/32
  - 14.161.39.236/32
- S3 bucket private with CloudFront access
- All EBS volumes encrypted
- Security groups with minimal required ports

## Backup & Recovery

- **Automated daily backups** at 2:00 AM
- **Retention**: Configurable (default 7 days)
- **Backup vault**: `g2x-wiki-{environment}-backup-vault`
- **Recovery**: Via AWS Backup console

## Monitoring

### Check application logs
```bash
docker compose logs wiki-api
docker compose logs wiki-fe
docker compose logs mysql
```

### Check nginx logs
```bash
tail -f /var/www/pavement/nginx/logs/g2x-wiki-access.log
tail -f /var/www/pavement/nginx/logs/g2x-wiki-error.log
```

## Customization

### Variables
| Variable | Description | Default |
|----------|-------------|----------|
| `project_name` | Project name | g2x-wiki |
| `environment` | Environment | prod |
| `instance_type` | EC2 instance type | t3.medium |
| `ami_id` | Ubuntu AMI ID | ami-0279a86684f669718 |
| `domain_name` | Frontend domain | pavement-beta.appscyclone.com |
| `api_domain_name` | API domain | pavement-beta-api.appscyclone.com |
| `backup_retention_days` | Backup retention | 7 |

### Docker Images
- **API**: docker-registry.appscyclone.com/g2x-wiki-api:master-latest
- **Frontend**: docker-registry.appscyclone.com/g2x-wiki-fe:master-latest

## Troubleshooting

### Common Issues

1. **Docker registry authentication**:
   ```bash
   docker login docker-registry.appscyclone.com
   ```

2. **Permission denied for docker**:
   ```bash
   sudo usermod -aG docker ubuntu
   newgrp docker
   ```

3. **Services not starting**:
   ```bash
   cd ~/wiki
   docker compose down
   docker compose up -d
   ```

### Logs Location
- **Application logs**: `docker compose logs <service_name>`
- **Nginx logs**: `/var/www/pavement/nginx/logs/`
- **System logs**: `/var/log/`

## Cleanup

```bash
# Destroy infrastructure
terraform destroy

# Note: May need to manually delete:
# - S3 bucket contents
# - Backup recovery points
```

## Support

For issues and questions, please contact the infrastructure team.