# Allow Lambda to invoke our functions:

resource "aws_iam_role" "this" {
  name = "${local.prefix_with_name}"
  tags = "${var.tags}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "lambda.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

# Allow writing logs to CloudWatch from our functions:

resource "aws_iam_policy" "this" {
  count = "${var.lambda_logging_enabled ? 1 : 0}"
  name  = "${local.prefix_with_name}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "this" {
  count      = "${var.lambda_logging_enabled ? 1 : 0}"
  role       = "${aws_iam_role.this.name}"
  policy_arn = "${aws_iam_policy.this.arn}"
}

# Add the scheduled execution rules & permissions:

resource "aws_cloudwatch_event_rule" "this" {
  name                = "${local.prefix_with_name}---scheduled-invocation"
  schedule_expression = "${var.schedule_expression}"
  tags                = "${var.tags}"
}

resource "aws_cloudwatch_event_target" "this" {
  rule      = "${aws_cloudwatch_event_rule.this.name}"
  target_id = "${aws_cloudwatch_event_rule.this.name}"
  arn       = "${local.function_arn}"
}

resource "aws_lambda_permission" "this" {
  statement_id  = "${local.prefix_with_name}---scheduled-invocation"
  action        = "lambda:InvokeFunction"
  function_name = "${local.function_id}"
  principal     = "events.amazonaws.com"
  source_arn    = "${aws_cloudwatch_event_rule.this.arn}"
}
