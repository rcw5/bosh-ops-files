resource "aws_iam_policy" "bosh_spot" {
  name = "${var.env_id}_bosh_spot_policy"
  path = "/"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ec2:CancelSpotInstanceRequests",
        "ec2:RequestSpotInstances",
        "ec2:DescribeSpotInstanceRequests"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Action": [
        "iam:CreateServiceLinkedRole"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Action": [
        "sts:AssumeRole"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "bosh_spot" {
  role       = "${var.env_id}_bosh_role"
  policy_arn = "${aws_iam_policy.bosh_spot.arn}"
}
