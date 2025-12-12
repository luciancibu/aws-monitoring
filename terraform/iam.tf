resource "aws_iam_role" "secret_manager_role" {
  name = "${var.projectName}-secret-manager-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

data "aws_iam_policy_document" "secret_manager_policy" {
  statement {
    effect = "Allow"
    actions = ["secretsmanager:GetSecretValue"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "secret_manager_attach" {
  role   = aws_iam_role.secret_manager_role.name
  policy = data.aws_iam_policy_document.secret_manager_policy.json
}

resource "aws_iam_instance_profile" "secret_manager_profile" {
  name = "${var.projectName}-flask"
  role = aws_iam_role.secret_manager_role.name
}
