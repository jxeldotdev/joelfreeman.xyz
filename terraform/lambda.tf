// create iam role for lambda 
resource "aws_iam_role" "lambda_iam_role" {
  name = "lambda_iam_role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com",
        "Service": "edgelambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

// create lambda function
resource "aws_lambda_function" "lambda_cloudfront_redirect" {

  filename      = "lambda_function.zip"
  function_name = "cloudfront_redirect"
  role          = "${aws_iam_role.lambda_iam_role.arn}"
  handler       = "index.handler"
  runtime       = "nodejs8.10"
  publish       = "true"

  depends_on = ["aws_iam_role.lambda_iam_role"]
}
