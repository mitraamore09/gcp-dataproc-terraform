module "custom_vpc" {
  source     = "./modules/vpc"
  project_id = var.project_id
  prefix     = var.prefix
  region     = var.region
}

module "cluster" {
  source      = "./modules/dataproc-cluster"
  prefix      = var.prefix
  region      = var.region
  subnet_id   = module.custom_vpc.subnet_id
  project_id  = var.project_id
}
module "cloudsql" {
  source     = "./modules/cloudsql"
  project_id = var.project_id
  region     = var.region
  prefix     = var.prefix
  network_id = module.custom_vpc.vpc_id
  network_self_link = module.custom_vpc.vpc_self_link
}

