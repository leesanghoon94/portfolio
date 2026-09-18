resource "aws_codepipeline" "codepipeline" {
  name     = "tf-pipeline"
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.codepipeline_bucket.bucket
    type     = "S3"

    # encryption_key {
    #   id   = data.aws_kms_alias.s3kmskey.arn
    #   type = "KMS"
    # }
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        ConnectionArn    = "arn:aws:codeconnections:ap-northeast-2:650251731474:connection/b360c8b7-06b8-461e-8758-76e02d1b1d97"
        FullRepositoryId = "leesanghoon94/myApp"
        BranchName       = "main"
      }
    }
  }

  stage {
    name = "Build"
    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.name.name
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name     = "front"
      category = "Deploy"
      owner    = "AWS"
      provider = "ECS"
      version  = "1"

      input_artifacts = ["build_output"]

      configuration = {
        ClusterName = aws_ecs_cluster.name.name
        ServiceName = aws_ecs_service.frontend.name
        FileName    = "frontend-imagedefinitions.json"
      }

      run_order = 1
    }

    action {
      name     = "back"
      category = "Deploy"
      owner    = "AWS"
      provider = "ECS"
      version  = "1"

      input_artifacts = ["build_output"]

      configuration = {
        ClusterName = aws_ecs_cluster.name.name
        ServiceName = aws_ecs_service.back.name
        FileName    = "backend-imagedefinitions.json"
      }

      run_order = 1
    }
  }
}

# resource "aws_codestarconnections_connection" "github" {
#   name          = "github-connection"
#   provider_type = "GitHub"
# }

resource "aws_s3_bucket" "codepipeline_bucket" {
  bucket = "codepipelineb-ucket"
}

resource "aws_s3_bucket_public_access_block" "codepipeline_bucket_pab" {
  bucket = aws_s3_bucket.codepipeline_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "codepipeline_role" {
  name               = "codepipelineRole"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "aws_iam_policy_document" "codepipeline_policy" {
  statement {
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:GetBucketVersioning",
      "s3:PutObjectAcl",
      "s3:PutObject",
    ]

    resources = [
      aws_s3_bucket.codepipeline_bucket.arn,
      "${aws_s3_bucket.codepipeline_bucket.arn}/*",
      "*"
    ]
  }

  statement {
    effect    = "Allow"
    actions   = ["codestar-connections:UseConnection"]
    resources = ["arn:aws:codeconnections:ap-northeast-2:650251731474:connection/b360c8b7-06b8-461e-8758-76e02d1b1d97"]
  }

  statement {
    effect = "Allow"

    actions = [
      "codebuild:BatchGetBuilds",
      "codebuild:StartBuild",
    ]

    resources = ["*"]
  }
  statement {
    effect = "Allow"
    actions = [
      "ecs:RegisterTaskDefinition",
      "ecs:DescribeServices",
      "ecs:UpdateService",
      "ecs:DescribeTaskDefinition"
    ]
    resources = ["*"]
  }
  statement {
    effect = "Allow"
    actions = [
      "codedeploy:*"
    ]
    resources = [
      "*"
    ]
  }
  statement {
    effect = "Allow"

    actions = [
      "ecs:DescribeServices",
      "ecs:DescribeTaskDefinition",
      "ecs:RegisterTaskDefinition",
      "ecs:UpdateService",
      "ecs:DescribeClusters",
      "ecs:ListTaskDefinitions",
      "ecs:TagResource"
    ]

    resources = ["*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "iam:PassRole"
    ]

    resources = [
      aws_iam_role.ecs_task_iam_role.arn,
      "arn:aws:iam::650251731474:role/service-role/ecsTaskExecutionRole"
    ]
  }
}

resource "aws_iam_role_policy" "codepipeline_policy" {
  name   = "codepipeline_policy"
  role   = aws_iam_role.codepipeline_role.id
  policy = data.aws_iam_policy_document.codepipeline_policy.json
}

# data "aws_kms_alias" "s3kmskey" {
#   name = "alias/myKmsKey"
# }




###############코드빌드
resource "aws_iam_role" "name" {
  name               = "codebuildrole"
  assume_role_policy = data.aws_iam_policy_document.codebuild_assume_role.json
}

data "aws_iam_policy_document" "codebuild_assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}
resource "aws_iam_role_policy" "name" {
  role   = aws_iam_role.name.name
  policy = data.aws_iam_policy_document.name.json
}

data "aws_iam_policy_document" "name" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "ec2:CreateNetworkInterface",
      "ec2:DescribeDhcpOptions",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DeleteNetworkInterface",
      "ec2:DescribeSubnets",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeVpcs",
    ]

    resources = ["*"]
  }
  statement {
    effect = "Allow"

    actions = [
      "codeconnections:GetConnectionToken",
      "codeconnections:GetConnection",
      "codeconnections:UseConnection"
    ]
    resources = ["arn:aws:codeconnections:ap-northeast-2:650251731474:connection/b360c8b7-06b8-461e-8758-76e02d1b1d97"]
  }
  statement {
    effect = "Allow"
    actions = [
      "ecr:*"
    ]
    resources = ["*"]
  }
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:GetBucketVersioning",
      "s3:PutObjectAcl",
      "s3:PutObject",
    ]
    resources = [
      "*"
    ]
  }
}


resource "aws_codebuild_project" "name" {
  name         = "build"
  service_role = aws_iam_role.name.arn
  source {
    buildspec       = file("${path.module}/buildspec.yml")
    git_clone_depth = 1
    # location        = "https://github.com/leesanghoon94/myApp"
    type = "CODEPIPELINE"
  }
  environment {
    compute_type                = "BUILD_GENERAL1_MEDIUM"
    image                       = "aws/codebuild/amazonlinux-x86_64-standard:6.0"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true
    type                        = "LINUX_CONTAINER"
  }

  artifacts {
    encryption_disabled    = false
    override_artifact_name = false
    type                   = "CODEPIPELINE"

  }
}

