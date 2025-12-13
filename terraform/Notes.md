#### Terraform + AWS Secrets Manager – Secret already exists ####

    # Option 1 – Restore and reuse (recommended)
export PROJECT_NAME_EXP=monitoring
aws secretsmanager restore-secret \
  --secret-id "${PROJECT_NAME_EXP}-mysql-secret"

export ARN= arn:aws:secretsmanager:<ZONE>:<ACC-ID>:secret:<NAME>"   -> this value will be also prited after you run the restore command above
terraform import   aws_secretsmanager_secret.mysql_secret  $ARN
terraform apply

    # Option 2 – DForce delete (NOT recommended)
aws secretsmanager delete-secret \
  --secret-id "${PROJECT_NAME_EXP}-mysql-secret" \
  --force-delete-without-recovery


# Checks:
aws secretsmanager get-secret-value \
  --secret-id "${PROJECT_NAME_EXP}-mysql-secret"
