# data "aws_iam_policy_document" "assume_role" {
#   statement {
#     effect  = "Allow"
#     actions = ["sts:AssumeRole"]

#     principals {
#       type        = "Service"
#       identifiers = ["ec2.amazonaws.com"]
#     }
#   }
# }

# data "aws_iam_policy_document" "s3" {
#   statement {
#     sid       = "s3"
#     effect    = "Allow"
#     resources = ["${aws_s3_bucket.software.arn}", "${aws_s3_bucket.software.arn}/*"]

#     actions = [
#       "s3:ListBucket",
#       "s3:GetObject"
#     ]
#   }
# }

# resource "aws_iam_role" "instance" {
#   name               = "nl-instance-role"
#   assume_role_policy = data.aws_iam_policy_document.assume_role.json
# }

# resource "aws_iam_role_policy" "instance" {
#   name   = "nl-instance-role-policy"
#   role   = aws_iam_role.instance.id
#   policy = data.aws_iam_policy_document.s3.json
# }

# resource "aws_iam_instance_profile" "instance" {
#   name = "nl-instance-profile"
#   role = aws_iam_role.instance.name
# }
