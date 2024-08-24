# 데이터베이스 호스트
output "db_host" {
  value = aws_db_instance.rds.address
}
