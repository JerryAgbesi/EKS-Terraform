data "aws_caller_identity" "current" {}

resource "aws_iam_role" "eks_admin_role" {
  name = "eks-admin-role-${data.aws_caller_identity.current.account_id}"

  assume_role_policy = jsonencode(
    {
        "Version": "2012-10-17",
        "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
            },
            "Action": "sts:AssumeRole"
        }
        ]
    }
  ) 
}

resource "aws_iam_policy" "eks_admin" {
    name = "AmazonEKSAdminPolicy"

    policy = jsonencode(
        {
            "Version": "2012-10-17",
            "Statement": [
            {
                "Effect": "Allow",
                "Action": [
                    "eks:*"
                ],
                "Resource": "*"
            },
            {
                "Effect": "Allow",
                "Action": "iam:PassRole",
                "Resource": "*",
                "Condition": {
                    "StringEquals": {
                        "iam:PassedToService": "eks.amazonaws.com"
                    }
                }

            }
            ]
        }
    )
  
}

resource "aws_iam_policy" "eks_assume_admin" {
    name = "AmazonEKSAssumeAdminPolicy"

    policy = jsonencode(
        {
            "Version": "2012-10-17",
            "Statement": [
            {
                "Effect": "Allow",
                "Action": [
                    "sts:AssumeRole"
                ],
                "Resource": "${aws_iam_role.eks_admin_role.arn}"
            }
            ]
        }
    )
  
}

resource "aws_iam_role_policy_attachment" "eks_admin_role_attachment" {
    role       = aws_iam_role.eks_admin_role.name
    policy_arn = aws_iam_policy.eks_admin.arn
}

resource "aws_iam_user" "cluster_admin" {
    name = "cluster-admin-${data.aws_caller_identity.current.account_id}"
    tags = {
        Name      = "cluster-admin-${data.aws_caller_identity.current.account_id}"
        Terraform = "true"
    }
  
}

resource "aws_iam_group" "cluster_admin_group" {
    name = "cluster-admin-group"  
}

resource "aws_iam_group_policy_attachment" "cluster_admin_group_attachment" {
    group      = aws_iam_group.cluster_admin_group.name
    policy_arn = aws_iam_policy.eks_assume_admin.arn
}

resource "aws_iam_group_membership" "cluster_admin_group_membership" {
    name = "Initial admin membership"
    group = aws_iam_group.cluster_admin_group.name
    users = [aws_iam_user.cluster_admin.name]
  
}

#Use the EKS API to now bind the role to the kubernetes group "cluster-admins"
resource "aws_eks_access_entry" "cluster_admin_access" {
    cluster_name = module.eks.cluster_name
    principal_arn    = aws_iam_role.eks_admin_role.arn
    kubernetes_groups  = ["cluster-admins"]
}



