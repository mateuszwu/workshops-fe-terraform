output "IAM_user_name_1" {
  value = module.ci_user_1.IAM_user_name
}

output "IAM_user_id_1" {
  value = module.ci_user_1.IAM_user_id
}

output "IAM_user_secret_1" {
  value     = module.ci_user_1.IAM_user_secret
  sensitive = true
}

output "IAM_user_name_2" {
  value = module.ci_user_2.IAM_user_name
}

output "IAM_user_id_2" {
  value = module.ci_user_2.IAM_user_id
}

output "IAM_user_secret_2" {
  value     = module.ci_user_2.IAM_user_secret
  sensitive = true
}
