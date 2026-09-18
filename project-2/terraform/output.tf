output "aws_ecr_repo" {
  value = [aws_ecr_repository.backend.arn, aws_ecr_repository.frontend.arn]
}
