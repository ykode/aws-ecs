resource "aws_key_pair" "main" {
  key_name   = "${var.name}-${var.environment}"
  public_key = "${file(var.key_file)}"
}

provider "aws" {
  region  = "${var.region}"
  profile = "${var.profile}"
}
