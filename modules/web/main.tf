resource "aws_amplify_app" "app" {
  name        = "pennyway-web-test"
  repository  = "https://github.com/CollaBu/pennyway-client-webview"
  oauth_token = var.github_access_token

  build_spec = <<-EOT
    version: 1
    frontend:
      phases:
          preBuild:
            commands:
                - yarn install
          build:
            commands:
                - yarn run build
      artifacts:
          baseDirectory: dist
          files:
            - '**/*'
      cache:
          paths:
            - node_modules/**/*
  EOT

  environment_variables = {
    # 추후 환경 변수 추가
  }
}

resource "aws_amplify_branch" "dev_branch" {
  app_id                        = aws_amplify_app.app.id
  branch_name                   = "develop"
  enable_pull_request_preview   = true
  pull_request_environment_name = "dev_pr"
}

resource "aws_amplify_branch" "main_branch" {
  app_id                        = aws_amplify_app.app.id
  branch_name                   = "main"
  enable_pull_request_preview   = true
  pull_request_environment_name = "main_pr"
}
