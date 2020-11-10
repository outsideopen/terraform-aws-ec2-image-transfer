module bucket {
  source     = "cloudposse/s3-bucket/aws"
  version    = "0.25.0"
  namespace  = var.namespace
  stage      = var.stage
  name       = "vm-import-export"
  attributes = var.attributes
  tags       = module.this.tags
}

data aws_iam_policy_document assume_role {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["vmie.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "sts:Externalid"
      values   = ["vmimport"]
    }
  }
}

data aws_iam_policy_document bucket_access {
  statement {
    actions   = [
      "s3:GetBucketLocation",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:PutObject",
      "s3:GetBucketAcl"
    ]
    resources = [
      "${var.arn_format}:s3:::${module.bucket.bucket_id}",
      "${var.arn_format}:s3:::${module.bucket.bucket_id}/*"
    ]
  }
  statement {
    actions   = [
      "ec2:ModifySnapshotAttribute",
      "ec2:CopySnapshot",
      "ec2:RegisterImage",
      "ec2:Describe*"
    ]
    resources = ["*"]
  }
}

resource aws_iam_role vmimport {
  count              = module.this.enabled ? 1 : 0
  name               = "vmimport"
  tags               = module.this.tags
  description        = "vm import export"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource aws_iam_policy bucket_access {
  count       = module.this.enabled ? 1 : 0
  name        = "vm-import-export-bucket-access"
  description = "vm import export access to EC2 and ${module.bucket.bucket_id} S3 bucket"
  policy      = data.aws_iam_policy_document.bucket_access.json
}

resource aws_iam_role_policy_attachment bucket_access {
  count      = module.this.enabled ? 1 : 0
  role       = join("", aws_iam_role.vmimport.*.name)
  policy_arn = join("", aws_iam_policy.bucket_access.*.arn)
}

resource aws_iam_role_policy_attachment vmie_role {
  count      = module.this.enabled ? 1 : 0
  role       = join("", aws_iam_role.vmimport.*.name)
  policy_arn = "${var.arn_format}:iam::aws:policy/service-role/VMImportExportRoleForAWSConnector"
}


