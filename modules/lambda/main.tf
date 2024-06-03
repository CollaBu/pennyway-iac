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

# IAM 역할 정책 첨부 (Lambda Basic Execution Role)
resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# IAM 역할 정책 첨부 (S3 Full Access)
resource "aws_iam_role_policy_attachment" "s3_policy" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

# Lambda Layer 생성
resource "aws_lambda_layer_version" "layer" {
  filename            = var.layer
  layer_name          = "nodejs"
  compatible_runtimes = ["nodejs18.x"]
  source_code_hash    = filebase64sha256(var.layer)
}

# Lambda 함수 생성 - Profile
resource "aws_lambda_function" "lambda_profile" {
  function_name    = "lambda_${var.function_name}_profile"
  role             = aws_iam_role.lambda_role.arn
  handler          = "index.handler"
  runtime          = "nodejs18.x"
  filename         = "${var.function}/profile.zip"
  source_code_hash = filebase64sha256("${var.function}/profile.zip")

  layers = [
    aws_lambda_layer_version.layer.arn,
    "arn:aws:lambda:ap-northeast-2:826293736237:layer:AWS-AppConfig-Extension:113"
  ]

  environment {
    variables = {
      BUCKET = var.bucket.name
    }
  }
}

# S3 버킷에 Lambda 함수 실행 권한 부여 - Profile
resource "aws_lambda_permission" "s3_invoke_lambda_profile" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_profile.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = var.bucket.arn
}

# S3 버킷에 Lambda 함수 트리거 설정 - Profile
resource "aws_s3_bucket_notification" "lambda_notification" {
  bucket = var.bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.lambda_profile.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "profile/"
  }

  lambda_function {
    lambda_function_arn = aws_lambda_function.lambda_chatroom.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "chatroom/"
  }

  lambda_function {
    lambda_function_arn = aws_lambda_function.lambda_feed.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "feed/"
  }
}

# Lambda 함수 생성 - Chatroom
resource "aws_lambda_function" "lambda_chatroom" {
  function_name    = "lambda_${var.function_name}_chatroom"
  role             = aws_iam_role.lambda_role.arn
  handler          = "index.handler"
  runtime          = "nodejs18.x"
  filename         = "${var.function}/chatroom.zip"
  source_code_hash = filebase64sha256("${var.function}/chatroom.zip")

  layers = [
    aws_lambda_layer_version.layer.arn,
    "arn:aws:lambda:ap-northeast-2:826293736237:layer:AWS-AppConfig-Extension:113"
  ]

  environment {
    variables = {
      BUCKET = var.bucket.name
    }
  }
}

# S3 버킷에 Lambda 함수 실행 권한 부여 - Chatroom
resource "aws_lambda_permission" "s3_invoke_lambda_chatroom" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_chatroom.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = var.bucket.arn
}

# Lambda 함수 생성 - Feed
resource "aws_lambda_function" "lambda_feed" {
  function_name    = "lambda_${var.function_name}_feed"
  role             = aws_iam_role.lambda_role.arn
  handler          = "index.handler"
  runtime          = "nodejs18.x"
  filename         = "${var.function}/feed.zip"
  source_code_hash = filebase64sha256("${var.function}/feed.zip")

  layers = [
    aws_lambda_layer_version.layer.arn,
    "arn:aws:lambda:ap-northeast-2:826293736237:layer:AWS-AppConfig-Extension:113"
  ]

  environment {
    variables = {
      BUCKET = var.bucket.name
    }
  }
}

# S3 버킷에 Lambda 함수 실행 권한 부여 - Feed
resource "aws_lambda_permission" "s3_invoke_lambda_feed" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_feed.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = var.bucket.arn
}
