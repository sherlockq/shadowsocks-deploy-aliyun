# Registered to own on Github, a Personal Access Token with no scopes.
variable "github_token" {
  default = "#any-token-without-scope#"
}

variable "gh_users_ssh" {
  type = list(string)
  default = []
}

variable "profile" {
  default = "default"
}

variable "region" {
  default = "cn-beijing"
}

variable "password" {
  default = "changethispasswordinaseparatefile"
}

variable "create_dns_record" {
  type = bool
  default = false
}

variable "domain" {
  default = "example.com"
}

variable "host" {
  default = "vpn"
}


variable "aws_profile" {
  default = "default"
}

variable "aws_region" {
  default = "us-west-2"
}