
vpc_cidr            = "10.0.0.0/16"
public_subnetcidr   = ["10.0.0.0/24", "10.0.2.0/24"]
private_subnetcidr  = ["10.0.1.0/24", "10.0.3.0/24"]
database_subnetcidr = ["10.0.51.0/24", "10.0.53.0/24"]
instance_type       = "t2.micro"
instance_class      = "db.t2.micro"
username            = "kojitechs"

dns_name                  = "kelderanyi.com"
subject_alternative_names = ["*.kelderanyi.com"]
