# troubleshooting

```console
Error: creating EKS Access Entry (my-cluster:arn:aws:iam::992382792232:role/something): operation error EKS: CreateAccessEntry, https response error StatusCode: 400, RequestID: d8f19198-889c-4c59-91bb-f0a63602fd94, InvalidParameterException: The specified principalArn is invalid: invalid principal.
```

│ with module.eks.module.eks.aws_eks_access_entry.this["example"],
│ on .terraform/modules/eks.eks/main.tf line 191, in resource "aws_eks_access_entry" "this":
│ 191: resource "aws_eks_access_entry" "this" {
│
╵
╷
│ Error: waiting for EKS Node Group (my-cluster:worker-node-2-20240703173548074600000015) create: unexpected state 'CREATE_FAILED', wanted target 'ACTIVE'. last error: subnet-09adb0ad02df7fc24, subnet-07b76fcba55b4330a: Ec2SubnetInvalidConfiguration: One or more Amazon EC2 Subnets of [subnet-09adb0ad02df7fc24, subnet-07b76fcba55b4330a] for node group worker-node-2-20240703173548074600000015 does not automatically assign public IP addresses to instances launched into it. If you want your instances to be assigned a public IP address, then you need to enable auto-assign public IP address for the subnet. See IP addressing in VPC guide: <https://docs.aws.amazon.com/vpc/latest/userguide/vpc-ip-addressing.html#subnet-public-ip>
│
│ with module.eks.module.eks.module.eks_managed_node_group["worker-node-2"].aws_eks_node_group.this[0],
│ on .terraform/modules/eks.eks/modules/eks-managed-node-group/main.tf line 385, in resource "aws_eks_node_group" "this":
│ 385: resource "aws_eks_node_group" "this" {
│
╵
╷
│ Error: waiting for EKS Node Group (my-cluster:worker-node-1-20240703173548077900000017) create: unexpected state 'CREATE_FAILED', wanted target 'ACTIVE'. last error: subnet-09adb0ad02df7fc24, subnet-07b76fcba55b4330a: Ec2SubnetInvalidConfiguration: One or more Amazon EC2 Subnets of [subnet-09adb0ad02df7fc24, subnet-07b76fcba55b4330a] for node group worker-node-1-20240703173548077900000017 does not automatically assign public IP addresses to instances launched into it. If you want your instances to be assigned a public IP address, then you need to enable auto-assign public IP address for the subnet. See IP addressing in VPC guide: <https://docs.aws.amazon.com/vpc/latest/userguide/vpc-ip-addressing.html#subnet-public-ip>
│
│ with module.eks.module.eks.module.eks_managed_node_group["worker-node-1"].aws_eks_node_group.this[0],
│ on .terraform/modules/eks.eks/modules/eks-managed-node-group/main.tf line 385, in resource "aws_eks_node_group" "this":
│ 385: resource "aws_eks_node_group" "this" {
│

module.eks.module.eks.aws_eks_access_entry.this["example"] will be created

- resource "aws_eks_access_entry" "this" {
  - access_entry_arn = (known after apply)
  - cluster_name = "my-cluster"
  - created_at = (known after apply)
  - id = (known after apply)
  - kubernetes_groups = (known after apply)
  - modified_at = (known after apply)
  - principal_arn = "arn:aws:iam::992382792232:root/eksview"
  - tags = {
    - "Environment" = "dev"
    - "Terraform" = "true"
      }
  - tags_all = {
    - "Environment" = "dev"
    - "Terraform" = "true"
      }
  - type = "STANDARD"
  - user_name = (known after apply)
    }

module.eks.module.eks.aws_eks_access_policy_association.this["cluster_creator_admin"] will be created

- resource "aws_eks_access_policy_association" "this" {

  - associated_at = (known after apply)
  - cluster_name = "my-cluster"
  - id = (known after apply)
  - modified_at = (known after apply)
  - policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  - principal_arn = "arn:aws:iam::992382792232:user/admin"

  - access_scope { + type = "cluster"
    }
    }

module.eks.module.eks.aws_eks_access_policy_association.this["example_example"] will be created

- resource "aws_eks_access_policy_association" "this" {

  - associated_at = (known after apply)
  - cluster_name = "my-cluster"
  - id = (known after apply)
  - modified_at = (known after apply)
  - policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy"
  - principal_arn = "arn:aws:iam::992382792232:root/eksview"

  - access_scope { + type = "cluster"
    }
    }

module.eks.module.vpc.aws_subnet.public[0] will be updated in-place

instanceprofile

{
"Version": "2012-10-17",
"Statement": [
{
"Sid": "VisualEditor0",
"Effect": "Allow",
"Action": [
"ec2:DescribeInstanceTypeOfferings",
"ec2:DescribeAvailabilityZones",
"ec2:DescribeImages",
"ec2:DescribeSpotPriceHistory",
"ec2:DescribeLaunchTemplates",
"ec2:CreateLaunchTemplate",
"ec2:CreateTags",
"ec2:CreateFleet",
"ec2:DeleteLaunchTemplate",
"ec2:RunInstances",
"ec2:TerminateInstances",
"pricing:GetProducts"
],
"Resource": "\*"
}
]
}

---

````json
{
    "Statement": [
        {
            "Action": [
                "ec2:RunInstances",
                "ec2:CreateFleet"
            ],
            "Effect": "Allow",
            "Resource": [
                "arn:aws:ec2:*::snapshot/*",
                "arn:aws:ec2:*::image/*",
                "arn:aws:ec2:*:*:subnet/*",
                "arn:aws:ec2:*:*:spot-instances-request/*",
                "arn:aws:ec2:*:*:security-group/*",
                "arn:aws:ec2:*:*:launch-template/*"
            ],
            "Sid": "AllowScopedEC2InstanceActions"
        },
        {
            "Action": [
                "ec2:RunInstances",
                "ec2:CreateLaunchTemplate",
                "ec2:CreateFleet"
            ],
            "Condition": {
                "StringEquals": {
                    "aws:RequestTag/kubernetes.io/cluster/my-cluster": "owned"
                },
                "StringLike": {
                    "aws:RequestTag/karpenter.sh/nodepool": "*"
                }
            },
            "Effect": "Allow",
            "Resource": [
                "arn:aws:ec2:*:*:volume/*",
                "arn:aws:ec2:*:*:spot-instances-request/*",
                "arn:aws:ec2:*:*:network-interface/*",
                "arn:aws:ec2:*:*:launch-template/*",
                "arn:aws:ec2:*:*:instance/*",
                "arn:aws:ec2:*:*:fleet/*"
            ],
            "Sid": "AllowScopedEC2InstanceActionsWithTags"
        },
        {
            "Action": "ec2:CreateTags",
            "Condition": {
                "StringEquals": {
                    "aws:RequestTag/kubernetes.io/cluster/my-cluster": "owned",
                    "ec2:CreateAction": [
                        "RunInstances",
                        "CreateFleet",
                        "CreateLaunchTemplate"
                    ]
                },
                "StringLike": {
                    "aws:RequestTag/karpenter.sh/nodepool": "*"
                }
            },
            "Effect": "Allow",
            "Resource": [
                "arn:aws:ec2:*:*:volume/*",
                "arn:aws:ec2:*:*:spot-instances-request/*",
                "arn:aws:ec2:*:*:network-interface/*",
                "arn:aws:ec2:*:*:launch-template/*",
                "arn:aws:ec2:*:*:instance/*",
                "arn:aws:ec2:*:*:fleet/*"
            ],
            "Sid": "AllowScopedResourceCreationTagging"
        },
        {
            "Action": "ec2:CreateTags",
            "Condition": {
                "ForAllValues:StringEquals": {
                    "aws:TagKeys": [
                        "karpenter.sh/nodeclaim",
                        "Name"
                    ]
                },
                "StringEquals": {
                    "aws:ResourceTag/kubernetes.io/cluster/my-cluster": "owned"
                },
                "StringLike": {
                    "aws:ResourceTag/karpenter.sh/nodepool": "*"
                }
            },
            "Effect": "Allow",
            "Resource": "arn:aws:ec2:*:*:instance/*",
            "Sid": "AllowScopedResourceTagging"
        },
        {
            "Action": [
                "ec2:TerminateInstances",
                "ec2:DeleteLaunchTemplate"
            ],
            "Condition": {
                "StringEquals": {
                    "aws:ResourceTag/kubernetes.io/cluster/my-cluster": "owned"
                },
                "StringLike": {
                    "aws:ResourceTag/karpenter.sh/nodepool": "*"
                }
            },
            "Effect": "Allow",
            "Resource": [
                "arn:aws:ec2:*:*:launch-template/*",
                "arn:aws:ec2:*:*:instance/*"
            ],
            "Sid": "AllowScopedDeletion"
        },
        {
            "Action": [
                "ec2:DescribeSubnets",
                "ec2:DescribeSpotPriceHistory",
                "ec2:DescribeSecurityGroups",
                "ec2:DescribeLaunchTemplates",
                "ec2:DescribeInstances",
                "ec2:DescribeInstanceTypes",
                "ec2:DescribeInstanceTypeOfferings",
                "ec2:DescribeImages",
                "ec2:DescribeAvailabilityZones"
            ],
            "Condition": {
                "StringEquals": {
                    "aws:RequestedRegion": "ap-northeast-2"
                }
            },
            "Effect": "Allow",
            "Resource": "*",
            "Sid": "AllowRegionalReadActions"
        },
        {
            "Action": "ssm:GetParameter",
            "Effect": "Allow",
            "Resource": "arn:aws:ssm:ap-northeast-2::parameter/aws/service/*",
            "Sid": "AllowSSMReadActions"
        },
        {
            "Action": "pricing:GetProducts",
            "Effect": "Allow",
            "Resource": "*",
            "Sid": "AllowPricingReadActions"
        },
        {
            "Action": [
                "sqs:ReceiveMessage",
                "sqs:GetQueueUrl",
                "sqs:GetQueueAttributes",
                "sqs:DeleteMessage"
            ],
            "Effect": "Allow",
            "Resource": "arn:aws:sqs:ap-northeast-2:992382792232:Karpenter-my-cluster",
            "Sid": "AllowInterruptionQueueActions"
        },
        {
            "Action": "iam:PassRole",
            "Condition": {
                "StringEquals": {
                    "iam:PassedToService": "ec2.amazonaws.com"
                }
            },
            "Effect": "Allow",
            "Resource": "arn:aws:iam::992382792232:role/sex-20240706113415365300000003",
            "Sid": "AllowPassingInstanceRole"
        },
        {
            "Action": "iam:CreateInstanceProfile",
            "Condition": {
                "StringEquals": {
                    "aws:RequestTag/kubernetes.io/cluster/my-cluster": "owned",
                    "aws:RequestTag/topology.kubernetes.io/region": "ap-northeast-2"
                },
                "StringLike": {
                    "aws:RequestTag/karpenter.k8s.aws/ec2nodeclass": "*"
                }
            },
            "Effect": "Allow",
            "Resource": "*",
            "Sid": "AllowScopedInstanceProfileCreationActions"
        },
        {
            "Action": "iam:TagInstanceProfile",
            "Condition": {
                "StringEquals": {
                    "aws:RequestTag/kubernetes.io/cluster/my-cluster": "owned",
                    "aws:ResourceTag/kubernetes.io/cluster/my-cluster": "owned",
                    "aws:ResourceTag/topology.kubernetes.io/region": "ap-northeast-2"
                },
                "StringLike": {
                    "aws:RequestTag/karpenter.k8s.aws/ec2nodeclass": "*",
                    "aws:ResourceTag/karpenter.k8s.aws/ec2nodeclass": "*"
                }
            },
            "Effect": "Allow",
            "Resource": "*",
            "Sid": "AllowScopedInstanceProfileTagActions"
        },
        {
            "Action": [
                "iam:RemoveRoleFromInstanceProfile",
                "iam:DeleteInstanceProfile",
                "iam:AddRoleToInstanceProfile"
            ],
            "Condition": {
                "StringEquals": {
                    "aws:ResourceTag/kubernetes.io/cluster/my-cluster": "owned",
                    "aws:ResourceTag/topology.kubernetes.io/region": "ap-northeast-2"
                },
                "StringLike": {
                    "aws:ResourceTag/karpenter.k8s.aws/ec2nodeclass": "*"
                }
            },
            "Effect": "Allow",
            "Resource": "*",
            "Sid": "AllowScopedInstanceProfileActions"
        },
        {
            "Action": "iam:GetInstanceProfile",
            "Effect": "Allow",
            "Resource": "*",
            "Sid": "AllowInstanceProfileReadActions"
        },
        {
            "Action": "eks:DescribeCluster",
            "Effect": "Allow",
            "Resource": "arn:aws:eks:ap-northeast-2:992382792232:cluster/my-cluster",
            "Sid": "AllowAPIServerEndpointDiscovery"
        }
    ],
    "Version": "2012-10-17"
}```


 policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:CreateLaunchTemplate",
          "ec2:CreateFleet",
          "ec2:RunInstances",
          "ec2:CreateTags",
          "ec2:TerminateInstances",
          "ec2:DescribeLaunchTemplates",
          "ec2:DescribeInstances",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeSubnets",
          "ec2:DescribeInstanceTypes",
          "ec2:DescribeInstanceTypeOfferings",
          "ec2:DescribeAvailabilityZones",
          "ssm:GetParameter"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "iam:PassRole",
        ]
        Effect   = "Allow"
        Resource = aws_iam_role.karpenter_node.arn
      }
    ]
  })
}
resource "aws_iam_role" "karpenter_node" {
  name = "karpenter-node-${var.cluster_name}"

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

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  ]
}

## Instance profile for nodes to pull images, networking, SSM, etc
resource "aws_iam_instance_profile" "karpenter_node" {
  name = "karpenter-node-${var.cluster_name}"
  role = aws_iam_role.karpenter_node.name
}
````

message":"ec2 api connectivity check failed","commit":"490ef94","error":"AccessDenied: User: arn:aws:sts::992382792232:assumed-role/KarpenterController-2024070717394039650000000d/eks-my-cluster-karpenter--d094f2c0-66bd-4695-8761-96a08fa8f3aa is not authorized to perform: sts:AssumeRole on resource: arn:aws:iam::992382792232:instance-profile/Karpenter-my-cluster-20240707173942407000000014\

---

module.eks.data.aws_eks_cluster_auth.cluster: Read complete after 0s [id=my-cluster]
module.eks.data.aws_eks_cluster.cluster: Read complete after 0s [id=my-cluster]
╷
│ Error: creating IAM Role (KarpenterController-20240708111044279500000001): operation error IAM: CreateRole, https response error StatusCode: 400, RequestID: 97f363a0-687b-463b-8c13-e97d987f9a2c, MalformedPolicyDocument: Federated principals must be valid domain names or SAML metadata ARNs
│
│ with module.eks.module.karpenter.aws_iam_role.controller[0],
│ on .terraform/modules/eks.karpenter/modules/karpenter/main.tf line 68, in resource "aws_iam_role" "controller":
│ 68: resource "aws_iam_role" "controller" {
│
╵
╷
│ Error: Null value found in list
│
│ with module.eks.module.karpenter.data.aws_iam_policy_document.controller[0],
│ on .terraform/modules/eks.karpenter/modules/karpenter/main.tf line 283, in data "aws_iam_policy_document" "controller":
│ 283: resources = ["*"]
│
│ Null values are not allowed for this attribute value.
╵

```hcl

module "karpenter" {
  source       = "terraform-aws-modules/eks/aws//modules/karpenter"
  version      = "20.17.2"
  cluster_name = module.eks.cluster_name

  create_node_iam_role            = false
  create_access_entry             = false
  enable_pod_identity             = true
  create_pod_identity_association = true
  enable_irsa                     = true
  irsa_oidc_provider_arn          = module.eks.oidc_provider_arn

  # Used to attach additional IAM policies to the Karpenter node IAM role
  node_iam_role_additional_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }


}

```

---

{"level":"ERROR","time":"2024-07-08T13:05:39.947Z","logger":"controller","message":"Reconciler error","commit":"490ef94","controller":"nodeclass.status","controllerGroup":"karpenter.k8s.aws","controllerKind":"EC2NodeClass","EC2NodeClass":{"name":"default"},"namespace":"","name":"default","reconcileID":"56bf5523-7a43-4ffe-a969-3e34f9c70491","error":"creating instance profile, adding role \"arn:aws:iam::992382792232:role/karpenter-eks-node-group-20240708111044279600000003\" to instance profile \"my-cluster*11693340466802365569\", ValidationError: The specified value for roleName is invalid. It must contain only alphanumeric characters and/or the following: +=,.@*-\n\tstatus code: 400, request id: b46d1ab8-2cec-4ee5-9fba-4a10b12875bf"}

teterraform state rm 'module.eks.kubectl_manifest.karpenter_node_class[default]'

╷
│ Error: Index value required
│
│ on line 1:
│ (source code not available)
│
│ Index brackets must contain either a literal number or a literal string.
╵

````tf state list
tf state rm "module.eks.kubectl_manifest.karpenter_node_class"```

---

{"level":"ERROR","time":"2024-07-08T14:16:47.483Z","logger":"controller","message":"Reconciler error","commit":"490ef94","controller":"nodeclass.status","controllerGroup":"karpenter.k8s.aws","controllerKind":"EC2NodeClass","EC2NodeClass":{"name":"default"},"namespace":"","name":"default","reconcileID":"f04a4f58-08e4-4de5-8ef4-d9be5ad96116","error":"creating instance profile, adding role \"arn:aws:iam::992382792232:role/KarpenterController-2024070814082964150000000d\" to instance profile \"my-cluster*11693340466802365569\", ValidationError: The specified value for roleName is invalid. It must contain only alphanumeric characters and/or the following: +=,.@*-\n\tstatus code: 400, request id: f0075961-7e8f-41f2-90aa-e068b6094def"}

Karpenter Role names exceeding 64-character limit
If you use a tool such as AWS CDK to generate your Kubernetes cluster name, when you add Karpenter to your cluster you could end up with a cluster name that is too long to incorporate into your KarpenterNodeRole name (which is limited to 64 characters).

Node role names for Karpenter are created in the form KarpenterNodeRole-${Cluster_Name} in the Create the KarpenterNode IAM Role section of the getting started guide. If a long cluster name causes the Karpenter node role name to exceed 64 characters, creating that object will fail.

Keep in mind that KarpenterNodeRole- is just a recommendation from the getting started guide. Instead of using the eksctl role, you can shorten the name to anything you like, as long as it has the right permissions.

> aws iam list-instance-profiles

````

resource "kubectl_manifest" "karpenter_node_class" {
yaml_body = <<-YAML
apiVersion: karpenter.k8s.aws/v1beta1
kind: EC2NodeClass
metadata:
name: default
spec:
amiFamily: AL2023
role: ${module.karpenter.iam_role_name}
subnetSelectorTerms: - tags:
karpenter.sh/discovery: ${module.eks.cluster_name}
securityGroupSelectorTerms: - tags:
karpenter.sh/discovery: ${module.eks.cluster_name}
tags:
karpenter.sh/discovery: ${module.eks.cluster_name}
YAML

depends_on = [
helm_release.karpenter
]
}

change

- metadata.spec.role: ${module.karpenter.iam_role_arn}

- metadata.spec.role: ${module.karpenter.iam_role_name}

---

{"level":"ERROR","time":"2024-07-08T14:39:32.269Z","logger":"controller","message":"Reconciler error","commit":"490ef94","controller":"nodeclass.status","controllerGroup":"karpenter.k8s.aws","controllerKind":"EC2NodeClass","EC2NodeClass":{"name":"default"},"namespace":"","name":"default","reconcileID":"285af6c9-3e78-451c-8275-bf2420d06fd7","error":"creating instance profile, adding role \"KarpenterController-2024070814082964150000000d\" to instance profile \"my-cluster_11693340466802365569\", AccessDenied: User: arn:aws:sts::992382792232:assumed-role/KarpenterController-2024070814082964150000000d/1720447906074644840 is not authorized to perform: iam:PassRole on resource: arn:aws:iam::992382792232:role/KarpenterController-2024070814082964150000000d because no identity-based policy allows the iam:PassRole action\n\tstatus code: 403, request id: eca9fcd9-5ff6-459e-8b93-f31a99e2ca09"}

`This can be controlled with the variable https://github.com/terraform-aws-modules/terraform-aws-eks/blob/771465be280450fc96d889ef9e15f191bb512849/modules/karpenter/variables.tf#L41C11-L41C31`

---

│
│ You are creating a plan with the -target option, which means that the result of this plan may not represent all of the changes requested by the current configuration.
│
│ The -target option is not for routine use, and is provided only for exceptional situations such as recovering from errors or mistakes, or when Terraform specifically suggests to use it as part of an error message.
╵

│ Warning: Applied changes may be incomplete
│
│ The plan was created with the -target option in effect, so some changes requested in the configuration may have been ignored and the output values may not be fully updated. Run the following command to verify that no
│ other changes are pending:
│ terraform plan
│
│ Note that the -target option is not suitable for routine use, and is provided only for exceptional situations such as recovering from errors or mistakes, or when Terraform specifically suggests to use it as part of an
\
│ Error: cannot re-use a name that is still in use
│
│ with module.eks.helm_release.karpenter-crd,
│ on modules/karpenter.tf line 141, in resource "helm_release" "karpenter-crd":
│ 141: resource "helm_release" "karpenter-crd" {
│
Helm Error when installing the karpenter-crd chart
Karpenter 0.26.1 introduced the karpenter-crd Helm chart. When installing this chart on your cluster, if you have previously added the Karpenter CRDs to your cluster through the karpenter controller chart or through kubectl replace, Helm will reject the install of the chart due to invalid ownership metadata.

In the case of invalid ownership metadata; label validation error: missing key "app.kubernetes.io/managed-by": must be set to "Helm" run:

Upgrading to 0.37.0+
Warning
0.33.0+ only supports Karpenter v1beta1 APIs and will not work with existing Provisioner, AWSNodeTemplate or Machine alpha APIs. Do not upgrade to 0.37.0+ without first upgrading to 0.32.x. This version supports both the alpha and beta APIs, allowing you to migrate all of your existing APIs to beta APIs without experiencing downtime.

---

### Error: could not download chart: public.ecr.aws/karpenter/karpenter:0.32.0: not found

│
│ with module.eks.helm_release.karpenter,
│ on modules/karpenter.tf line 22, in resource "helm_release" "karpenter":
│ 22: resource "helm_release" "karpenter" {

### resolved

<https://gallery.ecr.aws/karpenter/karpenter>

```hcl
resource "helm_release" "karpenter" {
  namespace        = "karpenter"
  create_namespace = true

  name                = "karpenter"
  repository          = "oci://public.ecr.aws/karpenter"
  repository_username = data.aws_ecrpublic_authorization_token.token.user_name
  repository_password = data.aws_ecrpublic_authorization_token.token.password
  chart               = "karpenter"
  - version             = "0.32.0"
  + version             = "v0.32.0"

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.karpenter.iam_role_arn
  }
  set {
    name  = "settings.clusterName"
    value = module.eks.cluster_name
  }
  set {
    name  = "settings.assumRoleARN"
    value = module.karpenter.node_iam_role_arn
  }
}

```

---

### Error: default failed to run apply: error when creating "/var/folders/h0/4s6ycqpn33v4160zt4p2b_ym0000gp/T/144255871kubectl_manifest.yaml": EC2NodeClass.karpenter.k8s.aws "default" is invalid: [spec.amiFamily: Unsupported value: "AL2023": supported values: "AL2", "Bottlerocket", "Ubuntu", "Custom", "Windows2019", "Windows2022", <nil>: Invalid value: "null": some validation rules were not checked because the object was invalid; correct the existing errors to complete validation]

│
│ with module.eks.kubectl_manifest.karpenter_node_class,
│ on modules/karpenter.tf line 49, in resource "kubectl_manifest" "karpenter_node_class":
│ 49: resource "kubectl_manifest" "karpenter_node_class" {
│
╵

### resolved

```
helm valuse.yaml
v0.32.x
settings:
  # -- AWS-specific settings (Deprecated: The AWS block inside of settings was flattened into settings)
  aws: {}

0.37
settings:
- aws: {}
```

---

### Error: default failed to run apply: error when creating "/var/folders/h0/4s6ycqpn33v4160zt4p2b_ym0000gp/T/713435154kubectl_manifest.yaml": EC2NodeClass.karpenter.k8s.aws "default" is invalid: [spec.amiFamily: Unsupported value: "AL2023": supported values: "AL2", "Bottlerocket", "Ubuntu", "Custom", "Windows2019", "Windows2022", <nil>: Invalid value: "null": some validation rules were not checked because the object was invalid; correct the existing errors to complete validation]

│
│ with module.eks.kubectl_manifest.karpenter_node_class,
│ on modules/karpenter.tf line 49, in resource "kubectl_manifest" "karpenter_node_class":
│ 49: resource "kubectl_manifest" "karpenter_node_class" {

### resolved

v.0.32.x disabled

````yaml
apiVersion: karpenter.k8s.aws/v1beta1
kind: EC2NodeClass
metadata:
  name: default
spec:
  amiFamily: AL2023```
````

---

### default-scheduler 0/2 nodes are available: 2 node(s) had untolerated taint {CriticalAddonsOnly: true}. preemption: 0/2 nodes are available: 2 Preemption is not helpful for scheduling. │

│ Warning FailedScheduling 68s karpenter Failed to schedule pod, incompatible with provisioner "dev", daemonset overhead={"cpu":"150m","pods":"3"}, did not tolerate dedicated=dev:NoSchedule

### resolved

```yaml
apiVersion: apps/v1
kind: Deployment
...
    spec:
 ...
      tolerations:
        - effect: "NoSchedule"
          key: "dev"
          operator: "Equal"
          value: "true"
        - effect: "NoSchedule"
          key: "CriticalAddonsOnly"
          value: "true"
          operator: "Equal"
```

---

### Warning FailedScheduling 4s default-scheduler 0/2 nodes are available: 2 node(s) didn't match Pod's node affinity/selector. preemption: 0/2 nodes are available: 2 Preemption is not helpful for scheduling. │

│ Warning FailedScheduling 3s karpenter Failed to schedule pod, incompatible with provisioner "dev", daemonset overhead={"cpu":"150m","pods":"3"}, incompatible requirements, key nodeType, nodeType In [dev] not in nod │
│ eType In [dev-2023]

### resolved

```
apiVersion: karpenter.sh/v1alpha5
kind: Provisioner
metadata:
  name: dev
spec:
  taints:
    - key: dev
      value: "true"
      effect: NoSchedule
  labels:
    nodeType: AL2023_x86_64_STANDARD
```

---

### k logs -f -n karpenter -c controller -l app.kubernetes.io/name=karpenter | grep -i error

{"level":"ERROR","time":"2024-07-08T18:34:57.487Z","logger":"controller","message":"Reconciler error","commit":"3a61217","controller":"machine.lifecycle","controllerGroup":"karpenter.sh","controllerKind":"Machine","Machine":{"name":"dev-r2gpd"},"namespace":"","name":"dev-r2gpd","reconcileID":"dcfe3fe7-85d1-4aa5-89c2-a85af193eb1e","error":"launching machine, creating instance, getting launch template configs, getting launch templates, neither spec.provider.instanceProfile nor --aws-default-instance-profile is specified"}

### resolved

sa settings
0.32.x use
settings.aws.interruptionQueueName
0.37.0 use
settings.assumRole

Enhancing and renaming components: For v1beta1, APIs have been enhanced to improve and solidify Karpenter APIs. Part of these enhancements includes renaming the Kinds for all Karpenter CustomResources. The following name changes have been made:
Provisioner -> NodePool
Machine -> NodeClaim
AWSNodeTemplate -> EC2NodeClass

---

{"level":"ERROR","time":"2024-07-08T19:19:38.181Z","logger":"webhook.ConfigMapWebhook","message":"Reconcile error","commit":"3a61217","knative.dev/traceid":"f194468a-89d3-4cf2-8082-6985e4c3984d","knative.dev/key":"validation.webhook.config.karpenter.sh","duration":"69.751µs","error":"secret \"karpenter-cert\" is missing \"ca-cert.pem\" key"}
{"level":"ERROR","time":"2024-07-08T19:19:38.181Z","logger":"webhook.ValidationWebhook","message":"Reconcile error","commit":"3a61217","knative.dev/traceid":"4d2b02a6-c8b1-43ba-96da-17912d7b1de7","knative.dev/key":"validation.webhook.karpenter.k8s.aws","duration":"125.664µs","error":"secret \"karpenter-cert\" is missing \"ca-cert.pem\" key"}
{"level":"ERROR","time":"2024-07-08T19:19:38.181Z","logger":"webhook.ValidationWebhook","message":"Reconcile error","commit":"3a61217","knative.dev/traceid":"6bbe7cd0-6c00-43d4-ac9e-d75ee5d9fde1","knative.dev/key":"validation.webhook.karpenter.sh","duration":"76.002µs","error":"secret \"karpenter-cert\" is missing \"ca-cert.pem\" key"}
{"level":"ERROR","time":"2024-07-08T19:19:38.181Z","logger":"webhook.DefaultingWebhook","message":"Reconcile error","commit":"3a61217","knative.dev/traceid":"13ca80b3-a0fc-4679-9444-4dbaaee9310d","knative.dev/key":"karpenter/karpenter-cert","duration":"45.815µs","error":"secret \"karpenter-cert\" is missing \"ca-cert.pem\" key"}
{"level":"ERROR","time":"2024-07-08T19:19:38.231Z","logger":"webhook.DefaultingWebhook","message":"Reconcile error","commit":"3a61217","knative.dev/traceid":"acab6de5-e260-4680-947c-c93d9a01abb6","knative.dev/key":"defaulting.webhook.karpenter.k8s.aws","duration":"28.29588ms","error":"failed to update webhook: Operation cannot be fulfilled on mutatingwebhookconfigurations.admissionregistration.k8s.io \"defaulting.webhook.karpenter.k8s.aws\": the object has been modified; please apply your changes to the latest version and try again"}
{"level":"ERROR","time":"2024-07-08T19:19:38.231Z","logger":"webhook.ValidationWebhook","message":"Reconcile error","commit":"3a61217","knative.dev/traceid":"4bd69548-1ee1-47b7-9c3d-1e5c89a4195d","knative.dev/key":"validation.webhook.karpenter.sh","duration":"28.787496ms","error":"failed to update webhook: Operation cannot be fulfilled on validatingwebhookconfigurations.admissionregistration.k8s.io \"validation.webhook.karpenter.sh\": the object has been modified; please apply your changes to the latest version and try again"}
{"level":"ERROR","time":"2024-07-08T19:19:38.241Z","logger":"webhook.ConfigMapWebhook","message":"Reconcile error","commit":"3a61217","knative.dev/traceid":"627102bb-e7dd-4fdf-a622-876b275157f4","knative.dev/key":"karpenter/karpenter-cert","duration":"40.256243ms","error":"failed to update webhook: Operation cannot be fulfilled on validatingwebhookconfigurations.admissionregistration.k8s.io \"validation.webhook.config.karpenter.sh\": the object has been modified; please apply your changes to the latest version and try again"}
{"level":"ERROR","time":"2024-07-08T19:19:38.241Z","logger":"webhook.ValidationWebhook","message":"Reconcile error","commit":"3a61217","knative.dev/traceid":"96d1abfa-31ab-4ae5-a26a-4fbc2fb34546","knative.dev/key":"validation.webhook.karpenter.k8s.aws","duration":"39.250109ms","error":"failed to update webhook: Operation cannot be fulfilled on validatingwebhookconfigurations.admissionregistration.k8s.io \"validation.webhook.karpenter.k8s.aws\": the object has been modified; please apply your changes to the latest version and try again"}
{"level":"ERROR","time":"2024-07-08T19:19:38.273Z","logger":"webhook.DefaultingWebhook","message":"Reconcile error","commit":"3a61217","knative.dev/traceid":"5ebd2126-8840-4cfc-b1ae-d1a66d85d1c3","knative.dev/key":"karpenter/karpenter-cert","duration":"45.427049ms","error":"failed to update webhook: Operation cannot be fulfilled on mutatingwebhookconfigurations.admissionregistration.k8s.io \"defaulting.webhook.karpenter.k8s.aws\": the object has been modified; please apply your changes to the latest version and try again"}

### resolved

---

### {"level":"DEBUG","time":"2024-07-08T20:00:30.606Z","logger":"controller","message":"loaded log configuration from file \"/etc/karpenter/logging/zap-logger-config\"","commit":"f0eb822"}

{"level":"DEBUG","time":"2024-07-08T20:00:30.606Z","logger":"controller","message":"discovered karpenter version","commit":"f0eb822","version":"v0.32.10"}
{"level":"FATAL","time":"2024-07-08T20:00:33.196Z","logger":"controller","message":"Checking EC2 API connectivity, AccessDenied: User: arn:aws:sts::992382792232:assumed-role/KarpenterController/1720468833129248622 is not authorized to perform: sts:AssumeRole on resource: arn:aws:iam::992382792232:role/KarpenterController\n\tstatus code: 403, request id: be430fd4-09de-4995-80b2-8919100b912c","commit":"f0eb822"}
{"level":"DEBUG","time":"2024-07-08T20:00:33.056Z","logger":"controller","message":"loaded log configuration from file \"/etc/karpenter/logging/zap-logger-config\"","commit":"f0eb822"}
{"level":"DEBUG","time":"2024-07-08T20:00:33.056Z","logger":"controller","message":"discovered karpenter version","commit":"f0eb822","version":"v0.32.10"}
{"level":"FATAL","time":"2024-07-08T20:00:35.672Z","logger":"controller","message":"Checking EC2 API connectivity, AccessDenied: User: arn:aws:sts::992382792232:assumed-role/KarpenterController/1720468835594565846 is not authorized to perform: sts:AssumeRole on resource: arn:aws:iam::992382792232:role/KarpenterController\n\tstatus code: 403, request id: fcfe7b3d-967c-4908-adc2-f3dde1683b36","commit":"f0eb822"}

### resloved

---

k logs -f -n karpenter -c controller -l app.kubernetes.io/name=karpenter
{"level":"DEBUG","time":"2024-07-08T21:52:19.574Z","logger":"controller","message":"loaded log configuration from file \"/etc/karpenter/logging/zap-logger-config\"","commit":"f0eb822"}
{"level":"DEBUG","time":"2024-07-08T21:52:19.574Z","logger":"controller","message":"discovered karpenter version","commit":"f0eb822","version":"v0.32.10"}
{"level":"FATAL","time":"2024-07-08T21:52:22.275Z","logger":"controller","message":"Checking EC2 API connectivity, AccessDenied: User: arn:aws:sts::992382792232:assumed-role/KarpenterController/eks-my-cluster-karpenter--0e30b9ac-1dbe-4116-9911-543facadc26c is not authorized to perform: sts:TagSession on resource: arn:aws:iam::992382792232:role/karpenter-eks-node-group-20240708212206532800000001\n\tstatus code: 403, request id: a3e5a5eb-53b1-412d-871e-bfd2860c9934","commit":"f0eb822"}
{"level":"DEBUG","time":"2024-07-08T21:52:18.893Z","logger":"controller","message":"loaded log configuration from file \"/etc/karpenter/logging/zap-logger-config\"","commit":"f0eb822"}
{"level":"DEBUG","time":"2024-07-08T21:52:18.893Z","logger":"controller","message":"discovered karpenter version","commit":"f0eb822","version":"v0.32.10"}
{"level":"FATAL","time":"2024-07-08T21:52:21.455Z","logger":"controller","message":"Checking EC2 API connectivity, AccessDenied: User: arn:aws:sts::992382792232:assumed-role/KarpenterController/eks-my-cluster-karpenter--9168faea-f8e2-4d7d-a705-47a332efad08 is not authorized to perform: sts:TagSession on resource: arn:aws:iam::992382792232:role/karpenter-eks-node-group-20240708212206532800000001\n\tstatus code: 403, request id: 788052e7-b96e-48c1-aaca-ae49a39827cf","commit":"f0eb822"}

---

### {"level":"FATAL","time":"2024-07-09T04:41:20.604Z","logger":"controller","message":"Checking EC2 API connectivity, NoCredentialProviders: no valid providers in chain. Deprecated.\n\tFor verbose messaging see aws.Config.CredentialsChainVerboseErrors","commit":"3a61217"}

### resolved

aws.defaultInstanceProfile

---

### Error from server (Invalid): error when creating "karpenter/nodepool.yaml": NodePool.karpenter.sh "default" is invalid: [spec.disruption.consolidationPolicy: Unsupported value: "WhenUnderutilized | WhenEmpty": supported values: "WhenEmpty", "WhenUnderutilized", <nil>: Invalid value: "null": some validation rules were not checked because the object was invalid; correct the existing errors to complete validation]

Error from server (Invalid): error when creating "karpenter/nodepool.yaml": EC2NodeClass.karpenter.k8s.aws "default" is invalid: [spec: Invalid value: "object": must specify exactly one of ['role', 'instanceProfile'], spec.tags: Invalid value: "object": tag contains a restricted tag matching kubernetes.io/cluster/]

### resolved

---

### Warning FailedScheduling 8s default-scheduler 0/2 nodes are available: 2 node(s) didn't match Pod's node affinity/selector. preemption: 0/2 nodes are available: 2 Preemption is not helpful for scheduling. │

│ Warning FailedScheduling 7s karpenter Failed to schedule pod, incompatible with nodepool "default", daemonset overhead={"cpu":"150m","pods":"3"}, no instance type satisfied resources {"cpu":"150m","pods":"4"} and r │
│ equirements karpenter.k8s.aws/instance-category In [c m r], karpenter.k8s.aws/instance-cpu In [16 32 4 8], karpenter.k8s.aws/instance-generation Exists >2, karpenter.k8s.aws/instance-hypervisor In [nitro], karpenter.sh/capacity-ty │
│ pe In [on-demand], karpenter.sh/nodepool In [default], kubernetes.io/arch In [amd64 arm64], node.kubernetes.io/instance-type In [t3.large], nodeType In [dev], topology.kubernetes.io/zone In [ap-northeast-2a ap-northeast-2c] (no in │
│ stance type met all requirements)

### resolved

https://karpenter.sh/v0.37/reference/instance-types/#t3large

---

### {"level":"ERROR","time":"2024-07-09T13:20:50.349Z","logger":"controller","message":"Reconciler error","commit":"490ef94","controller":"nodeclaim.lifecycle","controllerGroup":"karpenter.sh","controllerKind":"NodeClaim","NodeClaim":{"name":"default-2nhnh"},"namespace":"","name":"default-2nhnh","reconcileID":"8265a129-70f5-4568-849f-93192d5db06e","error":"launching nodeclaim, resolving ec2nodeclass, Failed to resolve AMIs"}

knodepool.karpenter.sh/default created
The EC2NodeClass "default" is invalid:

- spec.amiFamily: Unsupported value: "AL2023_x86_64_STANDARD": supported values: "AL2", "AL2023", "Bottlerocket", "Ubuntu", "Custom", "Windows2019", "Windows2022"
- <nil>: Invalid value: "null": some validation rules were not checked because the object was invalid; correct the existing errors to complete validation

{"level":"ERROR","time":"2024-07-09T13:26:06.262Z","logger":"controller","message":"Reconciler error","commit":"490ef94","controller":"nodeclaim.lifecycle","controllerGroup":"karpenter.sh","controllerKind":"NodeClaim","NodeClaim":{"name":"default-ws8lm"},"namespace":"","name":"default-ws8lm","reconcileID":"0769afa5-9de9-41e0-b83d-71da985aa801","error":"launching nodeclaim, resolving ec2nodeclass, Failed to resolve AMIs"}

### resolved

```amiSelectorTerms:
    # Select on any AMI that has both the "karpenter.sh/discovery: ${CLUSTER_NAME}" tag
    # AND the "environment: test" tag OR any AMI with the "my-ami" name
    # OR any AMI with ID "ami-123"
    - tags:
        karpenter.sh/discovery: "my-cluster"
        environment: test
     - name: my-ami
     - id: ami-123
```

### loadbalancer pening

kubernetes.io/role/internal-elb =1
태그 안걸렸음
