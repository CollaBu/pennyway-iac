# IAM 역할 생성
resource "aws_iam_role" "lambda_role" {
  name = "lambda_s3_exec_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# IAM 역할 정책 첨부 - Lambda Basic Execution Role
resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# IAM 역할 정책 첨부 - S3 Full Access
resource "aws_iam_role_policy_attachment" "s3_policy" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

# Lambda 함수 생성
resource "aws_lambda_function" "lambda" {
  function_name    = "lambda_s3"
  role             = aws_iam_role.lambda_role.arn
  handler          = "index.handler"
  runtime          = "nodejs18.x"
  filename         = var.function_name
  source_code_hash = filebase64sha256(var.function_name)
}
