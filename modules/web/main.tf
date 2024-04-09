resource "aws_amplify_app" "app" {
  name        = "pennyway-web-test"
  repository  = "https://github.com/CollaBu/pennyway-client-webview"
  oauth_token = var.github_access_token

  auto_branch_creation_config {
    enable_auto_build = true
  }

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
