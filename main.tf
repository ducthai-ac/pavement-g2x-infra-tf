locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# EC2 Module
module "ec2" {
  source = "./modules/ec2"
  
  project_name    = var.project_name
  environment     = var.environment
  vpc_id          = var.vpc_id
  subnet_ids      = var.subnet_ids
  key_pair_name   = var.key_pair_name
  instance_type   = var.instance_type
  ami_id          = var.ami_id
  
  tags = local.common_tags
}



# CloudFront Module
module "cloudfront" {
  source = "./modules/cloudfront"
  
  project_name     = var.project_name
  environment      = var.environment
  s3_bucket_domain = module.s3.bucket_domain
  
  tags = local.common_tags
}

# S3 Module for images
module "s3" {
  source = "./modules/s3"
  
  project_name       = var.project_name
  environment        = var.environment
  cloudfront_oai_arn = module.cloudfront.oai_iam_arn
  tags = local.common_tags
}

# SES Module
module "ses" {
  source = "./modules/ses"
  
  domain = var.ses_domain
  
  tags = local.common_tags
}

# EBS Backup Module
module "backup" {
  source = "./modules/backup"
  
  project_name        = var.project_name
  environment         = var.environment
  instance_id         = module.ec2.instance_id
  retention_days      = var.backup_retention_days
  
  tags = local.common_tags
}