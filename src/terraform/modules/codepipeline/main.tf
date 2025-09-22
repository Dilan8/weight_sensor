# ==============================
# Random ID for unique artifact bucket
# ==============================
resource "random_id" "suffix" {
  byte_length = 4
}

# ==============================
# S3 Bucket for Pipeline Artifacts
# ==============================
resource "aws_s3_bucket" "artifacts" {
  bucket = "${var.project_name}-pipeline-artifacts-${random_id.suffix.hex}"
}

# ==============================
# IAM Role for CodeBuild
# ==============================
data "aws_iam_policy_document" "codebuild_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "codebuild_role" {
  name               = "${var.project_name}-codebuild-role"
  assume_role_policy = data.aws_iam_policy_document.codebuild_assume.json
}

# Policies for CodeBuild
resource "aws_iam_policy" "codebuild_logs_policy" {
  name        = "${var.project_name}-CodeBuildCloudWatchLogsPolicy"
  description = "Allows CodeBuild to write to CloudWatch Logs"
  policy      = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect   = "Allow",
      Action   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"],
      Resource = "*"
    }]
  })
}

resource "aws_iam_policy" "codebuild_s3_policy" {
  name        = "${var.project_name}-CodeBuildS3AccessPolicy"
  description = "Allows CodeBuild to access S3 bucket for pipeline artifacts"
  policy      = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect   = "Allow",
      Action   = ["s3:GetObject", "s3:GetObjectVersion", "s3:PutObject"],
      Resource = "${aws_s3_bucket.artifacts.arn}/*"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "codebuild_logs_attachment" {
  role       = aws_iam_role.codebuild_role.name
  policy_arn = aws_iam_policy.codebuild_logs_policy.arn
}

resource "aws_iam_role_policy_attachment" "codebuild_s3_attachment" {
  role       = aws_iam_role.codebuild_role.name
  policy_arn = aws_iam_policy.codebuild_s3_policy.arn
}

resource "aws_iam_role_policy_attachment" "codebuild_ecr_access" {
  role       = aws_iam_role.codebuild_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}

resource "aws_iam_role_policy_attachment" "codebuild_attach" {
  role       = aws_iam_role.codebuild_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeBuildDeveloperAccess"
}

# ==============================
# CodeBuild Project (Node.js App)
# ==============================
resource "aws_codebuild_project" "nodejs_build" {
  name         = "${var.project_name}-build"
  service_role = aws_iam_role.codebuild_role.arn
  build_timeout = 20

  source {
    type      = "CODEPIPELINE"
    buildspec = var.buildspec_path
  }

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/standard:7.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = true

    environment_variable {
      name  = "NODEJS_ECR_URL"
      value = var.nodejs_ecr_repository
    }

    environment_variable {
      name  = "AWS_REGION"
      value = var.aws_region
    }
  }

  artifacts {
    type = "CODEPIPELINE"
  }
}

# ==============================
# IAM Role for CodePipeline
# ==============================
data "aws_iam_policy_document" "codepipeline_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "codepipeline_role" {
  name               = "${var.project_name}-pipeline-role"
  assume_role_policy = data.aws_iam_policy_document.codepipeline_assume.json
}

resource "aws_iam_role_policy" "codepipeline_inline" {
  name = "${var.project_name}-CodePipelineInlinePolicy"
  role = aws_iam_role.codepipeline_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "codebuild:BatchGetBuilds",
          "codebuild:StartBuild",
          "s3:*",
          "ecr:*",
          "iam:PassRole"
        ],
        Resource = "*"
      }
    ]
  })
}

# ==============================
# CodePipeline
# ==============================
resource "aws_codepipeline" "nodejs_pipeline" {
  name     = "${var.project_name}-pipeline"
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.artifacts.bucket
    type     = "S3"
  }

  stage {
    name = "Source"
    action {
      name             = "Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["source_output"]
      configuration = {
        Owner      = var.github_owner
        Repo       = var.github_repo
        Branch     = var.github_branch
        OAuthToken = var.github_token
      }
    }
  }

  stage {
    name = "Build"
    action {
      name             = "CodeBuild"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      version          = "1"
      configuration = {
        ProjectName = aws_codebuild_project.nodejs_build.name
      }
    }
  }
}
