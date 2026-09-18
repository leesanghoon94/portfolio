output "vpc_id" {
  value = module.vpc.vpc_id
}
output "private" {
  value = module.vpc.private_subnets
}
output "public" {

  value = module.vpc.public_subnets
}
