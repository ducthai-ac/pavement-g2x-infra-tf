# IAM Role for AWS Backup
resource "aws_iam_role" "backup_role" {
  name = "${var.project_name}-${var.environment}-backup-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "backup.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

# Attach AWS managed policy for backup service
resource "aws_iam_role_policy_attachment" "backup_policy" {
  role       = aws_iam_role.backup_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
}

# Backup Vault
resource "aws_backup_vault" "main" {
  name        = "${var.project_name}-${var.environment}-backup-vault"
  kms_key_arn = aws_kms_key.backup_key.arn

  tags = var.tags
}

# KMS Key for backup encryption
resource "aws_kms_key" "backup_key" {
  description             = "KMS key for backup encryption"
  deletion_window_in_days = 7

  tags = var.tags
}

resource "aws_kms_alias" "backup_key_alias" {
  name          = "alias/${var.project_name}-${var.environment}-backup-key"
  target_key_id = aws_kms_key.backup_key.key_id
}

# Backup Plan
resource "aws_backup_plan" "main" {
  name = "${var.project_name}-${var.environment}-backup-plan"

  rule {
    rule_name         = "daily_backup"
    target_vault_name = aws_backup_vault.main.name
    schedule          = "cron(0 2 * * ? *)" # Daily at 2 AM

    lifecycle {
      delete_after = var.retention_days
    }

    recovery_point_tags = var.tags
  }

  tags = var.tags
}

# Backup Selection
resource "aws_backup_selection" "main" {
  iam_role_arn = aws_iam_role.backup_role.arn
  name         = "${var.project_name}-${var.environment}-backup-selection"
  plan_id      = aws_backup_plan.main.id

  resources = [
    "arn:aws:ec2:*:*:instance/${var.instance_id}"
  ]

  condition {
    string_equals {
      key   = "aws:ResourceTag/Project"
      value = var.project_name
    }
  }
}