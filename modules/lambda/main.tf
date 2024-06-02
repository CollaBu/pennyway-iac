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
  function_name    = "lambda_${var.function_name}"
  role             = aws_iam_role.lambda_role.arn
  handler          = "index.handler"
  runtime          = "nodejs18.x"
  filename         = var.function
  source_code_hash = filebase64sha256(var.function)

  environment {
    variables = {
      BUCKET = var.bucket.name
    }
  }
}

# S3 버킷에 Lambda 함수 실행 권한 부여
resource "aws_lambda_permission" "s3_invoke_lambda" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = var.bucket.arn
}

# S3 버킷에 Lambda 함수 트리거 설정
resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = var.bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.lambda.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "delete/"
  }
}
