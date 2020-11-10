output bucket_id {
  value       = module.bucket.bucket_id
  description = "The bucket id"
}

output bucket_regional_domain_name {
  value       = module.bucket.bucket_regional_domain_name
  description = "The regional domain name of the bucket"
}

output role_name {
  value       = join("", aws_iam_role.vmimport.*.name)
  description = "The name of the IAM role created"
}

output role_id {
  value       = join("", aws_iam_role.vmimport.*.unique_id)
  description = "The stable and unique string identifying the role"
}

output role_arn {
  value       = join("", aws_iam_role.vmimport.*.arn)
  description = "The Amazon Resource Name (ARN) specifying the role"
}