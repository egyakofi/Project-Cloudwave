resource "aws_iam_role" "cloudwave_ec2_role" {
  name = "ec2_role"
  
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "cloudwave_s3_policy" {
  name = "cloudwave_s3_policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "s3:*",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "cloudwave_s3_attachment" {
  role = "${aws_iam_role.cloudwave_ec2_role.name}"
  policy_arn = "${aws_iam_policy.cloudwave_s3_policy.arn}"
}

resource "aws_iam_instance_profile" "cloudwave-profile" {
  name = "cloudwave_profile"
  role = aws_iam_role.cloudwave_ec2_role.name
}