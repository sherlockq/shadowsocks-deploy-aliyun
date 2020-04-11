# On demand shadowsocks proxy

A fully terraform managed deploy script for Shadowsocks Server.
## Comment
This project is a migration from the original AWS based script to an Aliyun analogy. The syntax may be a bit different but overall
there's no significant change.

## Prerequisite
### AWS account

1. Sign up for a Aliyun account. There's no free service, and an identity verification is required due to government regulation. 
2. Install Aliyun CLI and configure with your Access Keys and Access Secrets.  

### Terraform installation

On OSX, the easiest way is simply:

```bash
$ brew install terraform
```

## Configuration

Add `terraform.tfvars` to specify customized information:
```properties
# expected region for the server
region = "cn-zhangjiajie" 
github_token = "d749883e4c75d08355a4b5cdc99604201924b4ed"
# Github handle(username in your github url), used to get github public key for server ssh access
gh_users_ssh = ["github handle(username)"]
profile = "profile for AWS CLI, remove to use default"
password = "password for shadowsocks"
host = "DNS host name, default is vpn"
domain = "Route53 managed domain if a dns record is expected to add"

# False if no dns record should be created
create_dns_record = true

# My DNS is in AWS, thus an AWS profile is used. Unnecessary if no dns is required.
aws_profile = "default"
```

Or find all configurable settings in `vars.tf`.

## Deployment
Once cloned and configurations filled in, 
```bash
$ terraform init
```

Then
```bash
$ terraform apply
```
You will have to confirm by typing `yes`. Deployment takes up to a couple of minutes. 
Once it is complete, your shadowsocks server is up and running.

Run `terraform output` to show the dns and ip address of the created server. 

Default shadowsocks configuration (which can be adjusted) is:

When you are done using your instance:

```bash
$ terraform destroy
```
You will have to confirm by typing `yes`. Destroys the server.
crying to me.  If my code kills your cat, same deal.  Have fun, stay safe, and be smart.


### Configuration
To change the encryption algorithm and listening port, check `scripts/provision.sh` and help yourself.

Current configuration is:
```shell script
/srv/shadowsocks2-linux -s ':443' -cipher AEAD_CHACHA20_POLY1305 -password ${password}
``` 

### SSH

Follow link https://help.github.com/en/github/authenticating-to-github/connecting-to-github-with-ssh
to create your own SSH key and bind it to your Github Account. The same key could be used for all ssh access 
because this section is added to `~/.ssh/config` during the process
```
Host *
  AddKeysToAgent yes
  UseKeychain yes
  IdentityFile ~/.ssh/id_rsa.github
``` 

Then run `./ssh_to.sh` to connect to your server.

### Thanks

Forked from the fundamental work of [jvsteiner](https://github.com/jvsteiner/shadowsocks-deploy)

To the awesome people at [shadowsocks-go](https://github.com/shadowsocks/shadowsocks-go)
