# Get KMS Key data
data "aws_kms_key" "ssm_key" {
  key_id = "alias/aws/ssm"
}

# For GokabotTaskExecutionRole
resource "aws_iam_policy" "GokabotSecretAccess" {
  name = "GokabotSecretAccess"
  path = "/service-role/"

  policy = jsonencode(
    {
      Version = "2012-10-17",
      Statement = [
        {
          Action = [
            "ssm:GetParameters",
            "kms:Decrypt",
          ]
          Effect = "Allow"
          Resource = [
            var.ssm_parameter_gokabot_all,
            data.aws_kms_key.ssm_key.arn
          ]
        }
      ]
    }
  )

  tags = {
    Name = "GokabotSecretAccess"
    cost = var.cost_tag
  }
}

resource "aws_iam_role" "GokabotTaskExecutionRole" {
  name = "GokabotTaskExecutionRole"
  path = "/service-role/"

  assume_role_policy = file("${path.module}/assume_role_policy_ecs_task.json")

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy",
    aws_iam_policy.GokabotSecretAccess.arn
  ]

  tags = {
    Name = "GokabotTaskExecutionRole"
    cost = var.cost_tag
  }
}

# For GokabotCodeBuildServiceRole
resource "aws_iam_policy" "GokabotCodeBuildBasePolicy" {
  name = "GokabotCodeBuildBasePolicy"
  path = "/service-role/"

  policy = file("${path.module}/codebuild_base_policy.json")

  tags = {
    Name = "GokabotCodeBuildBasePolicy"
    cost = var.cost_tag
  }
}

resource "aws_iam_policy" "SecretsManagerGetDockerHubLogin" {
  name = "SecretsManagerGetDockerHubLogin"
  path = "/service-role/"

  policy = jsonencode(
    {
      Version = "2012-10-17"
      Statement = [
        {
          Action   = "secretsmanager:GetSecretValue"
          Effect   = "Allow"
          Resource = var.dockerhub_login.arn
        },
      ]
    }
  )

  tags = {
    Name = "SecretsManagerGetDockerHubLogin"
    cost = var.cost_tag
  }
}

resource "aws_iam_role" "GokabotCodeBuildServiceRole" {
  name = "GokabotCodeBuildServiceRole"
  path = "/service-role/"

  assume_role_policy = file("${path.module}/assume_role_policy_codebuild.json")

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser",
    aws_iam_policy.GokabotCodeBuildBasePolicy.arn,
    aws_iam_policy.SecretsManagerGetDockerHubLogin.arn
  ]

  tags = {
    Name = "GokabotCodeBuildServiceRole"
    cost = var.cost_tag
  }
}

# For GokabotCodeDeployServiceRole
resource "aws_iam_role" "GokabotCodeDeployServiceRole" {
  name = "GokabotCodeDeployServiceRole"
  path = "/service-role/"

  assume_role_policy = file("${path.module}/assume_role_policy_codedeploy.json")

  managed_policy_arns = ["arn:aws:iam::aws:policy/AWSCodeDeployRoleForECS"]

  tags = {
    Name = "GokabotCodeDeployServiceRole"
    cost = var.cost_tag
  }
}

# For GokabotCodePipelineBasePolicy
resource "aws_iam_policy" "GokabotCodePipelineBasePolicy" {
  name = "GokabotCodePipelineBasePolicy"
  path = "/service-role/"

  policy = file("${path.module}/codepipeline_base_policy.json")

  tags = {
    Name = "GokabotCodePipelineBasePolicy"
    cost = var.cost_tag
  }
}

resource "aws_iam_role" "GokabotCodePipelineServiceRole" {
  name = "GokabotCodePipelineServiceRole"
  path = "/service-role/"

  assume_role_policy = file("${path.module}/assume_role_policy_codepipeline.json")

  managed_policy_arns = [
    aws_iam_policy.GokabotCodePipelineBasePolicy.arn
  ]

  tags = {
    Name = "GokabotCodePipelineServiceRole"
    cost = var.cost_tag
  }
}

# For GokabotEventTargetRole
resource "aws_iam_policy" "GokabotEventTargetPolicy" {
  name = "GokabotEventTargetPolicy"
  path = "/service-role/"

  policy = file("${path.module}/event_target_policy.json")

  tags = {
    Name = "GokabotEventTargetPolicy"
    cost = var.cost_tag
  }
}

resource "aws_iam_role" "GokabotEventTargetRole" {
  name = "GokabotEventTargetRole"
  path = "/service-role/"

  assume_role_policy = file("${path.module}/assume_role_policy_events.json")

  managed_policy_arns = [
    aws_iam_policy.GokabotEventTargetPolicy.arn
  ]

  tags = {
    Name = "GokabotEventTargetRole"
    cost = var.cost_tag
  }
}
