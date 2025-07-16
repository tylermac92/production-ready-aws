terraform {
  backend "s3" {
    bucket         = "multi-tier-prod-infra-tf-state"
    key            = "env/dev/terraform.tfstate" 
    region         = "us-east-1"
    dynamodb_table = "multi-tier-prod-infra-lock-table"
    encrypt        = true
  }
}

module "vpc" {
  source      = "../../modules/vpc"
  name_prefix = "dev"
  vpc_cidr    = "10.0.0.0/16"
}

module "iam" {
  source             = "../../modules/iam"
  env                = "dev"
  app_s3_bucket_name = "dev-app-bucket"
  alb_s3_bucket_arn  = "arn:aws:s3:::dev-alb-logs-faithful-escargot"
}

module "app_tier" {
  source                = "../../modules/app_tier"
  env                   = "dev"
  vpc_id                = module.vpc.vpc_id
  private_subnet_ids    = module.vpc.private_subnet_ids
  instance_profile      = module.iam.ec2_instance_profile
  alb_security_group_id = module.alb.alb_security_group_id
}

module "alb" {
  source            = "../../modules/alb"
  env               = "dev"
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
}

resource "aws_autoscaling_attachment" "app_to_alb" {
  autoscaling_group_name = module.app_tier.asg_name
  lb_target_group_arn    = module.alb.target_group_arn
}

module "rds" {
  source                = "../../modules/rds"
  env                   = "dev"

  vpc_id                = module.vpc.vpc_id
  private_subnet_ids    = module.vpc.private_subnet_ids
  app_security_group_id = module.app_tier.app_security_group_id
}

data "aws_caller_identity" "current" {}

module "s3" {
  source        = "../../modules/s3"
  env           = "dev"
  iam_role_arn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${module.iam.ec2_role_name}"
}

