module "web" {
  source                       = "../../../modules/web"
  aws_profile                  = var.aws_profile
  region                       = var.region
  env                          = "dev"
  network_remote_state_bucket  = var.bucket
  network_remote_state_key     = var.key_network
  database_remote_state_bucket = var.bucket
  database_remote_state_key    = var.key_database
  instance_type                = "t2.micro"
}
