resource "alicloud_oss_bucket" "bucket-package" {
  acl = "public-read"
  bucket = "wkz-temp-package"

  lifecycle_rule {
    id = "rule-days"
    prefix = "/"
    enabled = true

    expiration {
      days = 7
    }
  }

  provisioner "local-exec" {
    command = "wget https://github.com/shadowsocks/go-shadowsocks2/releases/download/v0.1.0/shadowsocks2-linux.gz"
  }
}

resource "alicloud_oss_bucket_object" "ssocks-file" {
  acl = "public-read"

  bucket = alicloud_oss_bucket.bucket-package.bucket
  key = "shadowsocks2-linux.0.1.0.gz"
  source = "shadowsocks2-linux.gz"
}