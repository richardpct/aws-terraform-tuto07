terraform {
  backend "s3" {}
}

module "webserver" {
  source = "../../../modules/webserver"

  region                       = "eu-west-3"
  env                          = "dev"
  base_remote_state_bucket     = "${var.bucket}"
  base_remote_state_key        = "${var.dev_base_key}"
  database_remote_state_bucket = "${var.bucket}"
  database_remote_state_key    = "${var.dev_database_key}"
  instance_type                = "t2.micro"
  image_id                     = "ami-0dc12d28e8595864f"  //ubuntu 18.10
  database_pass                = "${var.dev_database_pass}"
}
