//task role
resource "aws_iam_role" "ecs_task_iam_role" {
  name = "ecsTaskIamRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

data "aws_iam_policy_document" "task_assume_role_policy" {
  statement {
    actions = ["sts:Assumerole"]

    principals {
      type = "Service"
      identifiers = [ "ecs-tasks.amazonaws.com" ]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_poliy" {
  role = aws_iam_role.ecs_task_iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}



// ec2 컨테이너
resource "aws_iam_role" "ec2_instance_role" {
  name = "ec2InstanceRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = ["ec2.amazonaws.com",
          "ecs.amazonaws.com"]
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ec2_instance_role_policy" {
  role = aws_iam_role.ec2_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"

}

resource "aws_iam_instance_profile" "ec2_instance_role_profile" {
  name = "Ec2InstanceRoleProfile"
  role = aws_iam_role.ec2_instance_role.id
}

data "aws_iam_policy_document" "ec2_instance_role_policy" {
  statement {
    actions = [ "sts:AssumeRole" ]
    effect = "Allow"

    principals {
      type = "Service"
      identifiers = [ 
        "ec2.amazonaws.com",
        "ecs.amazonaws.com"
       ]
    }
  }
}
///////////////////
//ecs role       //
///////////////////
resource "aws_iam_role" "ecs_role" {
  name = "ecsServiceRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "name" {
  role = aws_iam_role.ecs_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}


# data "aws_iam_policy_document" "ecs_svc_policy" {
#   statement {
#     actions = [ "sts:AssumeRole" ]
#     effect = "Allow"

#     principals {
#       type = "Service"
#       identifiers = [ "ecs.amazonaws.com", ]
#     }
#   } 
# }

//////////////////
/// ecs-svc-role//
//////////////////

resource "aws_iam_role" "ecs_svc_role" {
  name = "tf_ecsServiceRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ecs.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy" "ecs_service_role_policy" {
  name = "ecs_service_role_policy"
  policy = data.aws_iam_policy_document.ecs_service_role_policy.json
  role = aws_iam_role.ecs_svc_role.id
}

data "aws_iam_policy_document" "ecs_service_role_policy" {
  statement {
    effect = "Allow"
    actions = [ 
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:Describe*",
      "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
      "elasticloadbalancing:DeregisterTargets",
      "elasticloadbalancing:Describe*",
      "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
      "elasticloadbalancing:RegisterTargets",
      "ec2:DescribeTags",
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:DescribeLogStreams",
      "logs:PutSubscriptionFilter",
      "logs:PutLogEvents"
     ]
     resources = [ "*" ]
  }
}
