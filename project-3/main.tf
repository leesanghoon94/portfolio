module "eks" {
  source          = "./modules"
  cluster_name    = ""
  cluster_version = ""
  vpc_id          = module.vpc.vpc_id
  public_subnets  = module.vpc.public
  private_subnets = module.vpc.private
}


module "vpc" {
  source = "./vpc"
}
