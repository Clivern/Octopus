terraform {
  required_providers {
    time = {
      source  = "hashicorp/time"
      version = "0.13.0"
    }
  }
  required_version = ">= 1.3.7"
}

provider "local" {}

resource "local_file" "hello_world" {
  content  = "Hello, World!"
  filename = "${path.module}/hello.txt"
}

provider "time" {}

resource "null_resource" "previous" {}

resource "time_sleep" "wait_30_seconds" {
  depends_on      = [null_resource.previous]
  create_duration = "30s"
}
