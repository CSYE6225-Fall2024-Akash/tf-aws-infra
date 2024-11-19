# Lambda Function
resource "aws_lambda_function" "email_verification" {
  filename      = var.lambda_function_path
  function_name = "${var.environment}-email-verification"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.handler"
  runtime       = "nodejs18.x"
  timeout       = 30

  environment {
    variables = {
      SENDGRID_API_KEY = var.sendgrid_api_key
      FROM_EMAIL       = "noreply@${var.environment}.${var.domain_name}"
      DOMAIN_NAME      = "${var.environment}.${var.domain_name}"
    }
  }

}

# Lambda IAM Role
resource "aws_iam_role" "lambda_role" {
  name = "${var.environment}-lambda-verification-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

# Lambda Role Policies
resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_vpc" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_iam_role_policy" "lambda_sns_policy" {
  name = "${var.environment}-lambda-sns-policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sns:Subscribe",
          "sns:Receive"
        ]
        Resource = [aws_sns_topic.user_verification.arn]
      }
    ]
  })
}