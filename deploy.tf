provider "alicloud" {
  region = var.region
  profile = var.profile
}

provider "aws" {
  region = var.aws_region
  profile = var.aws_profile
}


provider "github" {
  token = var.github_token
  organization = ""
  version = "~> 2.1.0"
}

data "github_user" "ssh" {
  count = length(var.gh_users_ssh)
  username = var.gh_users_ssh[count.index]
}

locals {
  authorized_keys = flatten(data.github_user.ssh.*.ssh_keys)
}

data "template_file" "init_script" {
  template = file("./scripts/provision.sh")
  vars = {
    password = var.password
    ssh_authorized_keys = join("\n", local.authorized_keys)
    package_url = "http://${alicloud_oss_bucket.bucket-package.bucket}.oss-${var.region}-internal.aliyuncs.com/${alicloud_oss_bucket_object.ssocks-file.key}"
  }
}

resource "alicloud_vpc" "vpc" {
  name = "tf_test_foo"
  cidr_block = "172.16.0.0/12"
}

resource "alicloud_vswitch" "vsw" {
  vpc_id = alicloud_vpc.vpc.id
  cidr_block = "172.16.0.0/21"
  availability_zone = "${var.region}-a"
}

data "alicloud_instance_types" "types_ds" {
  cpu_core_count = 2
  memory_size = 0.5
  instance_type_family = "ecs.t6"
}

data "alicloud_images" "ubuntu" {
  name_regex = "^ubuntu_18_04"
  most_recent = true
}
resource "alicloud_instance" "ssocks" {
  instance_name = "vpn-back"
  count = 1
  //  image_id = "ubuntu_18_04_64_20G_alibase_20190624.vhd"
  image_id = data.alicloud_images.ubuntu.images.0.id
  instance_type = data.alicloud_instance_types.types_ds.instance_types.0.id
  //  user_data = data.template_cloudinit_config.config.rendered
  internet_max_bandwidth_out = 10
  vswitch_id = alicloud_vswitch.vsw.id

  security_groups = alicloud_security_group.default.*.id

  user_data = data.template_file.init_script.rendered
}

resource "alicloud_security_group" "default" {
  name = "default"
  vpc_id = alicloud_vpc.vpc.id
}

resource "alicloud_security_group_rule" "allow_all_tcp" {
  type = "ingress"
  ip_protocol = "tcp"
  nic_type = "intranet"
  policy = "accept"
  port_range = "1/65535"
  priority = 1
  security_group_id = alicloud_security_group.default.id
  cidr_ip = "0.0.0.0/0"
}

output "public_ip" {
  value = alicloud_instance.ssocks.*.public_ip
}

data "aws_route53_zone" "primary" {
  count = var.create_dns_record ? 1 : 0
  name = var.domain
}

resource "aws_route53_record" "vpn" {
  count = var.create_dns_record ? 1 : 0
  zone_id = data.aws_route53_zone.primary[0].zone_id
  name = var.host
  type = "A"
  ttl = 300
  records = alicloud_instance.ssocks.*.public_ip
}