output "domain_identity" {
  description = "SES domain identity"
  value       = aws_ses_domain_identity.main.domain
}

output "dkim_tokens" {
  description = "DKIM tokens for DNS verification"
  value       = aws_ses_domain_dkim.main.dkim_tokens
}

output "mail_from_domain" {
  description = "Mail from domain"
  value       = aws_ses_domain_mail_from.main.mail_from_domain
}