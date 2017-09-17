resource "aws_vpc" "main" {
  cidr_block = "${var.vpc_cidr}"

  tags = {
    Name        = "${var.name}-${var.environment}"
    Environment = "${var.environment}"
  }
}

resource "aws_subnet" "external" {
  count                   = 2
  vpc_id                  = "${aws_vpc.main.id}"
  cidr_block              = "${element(var.external_subnets, count.index)}"
  availability_zone       = "${element(var.zones, count.index)}"
  map_public_ip_on_launch = true

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name        = "${var.name}-${format("external-%03d-%s", count.index, var.environment)}"
    Environment = "${var.environment}"
  }
}

resource "aws_subnet" "internal" {
  count                   = 2
  vpc_id                  = "${aws_vpc.main.id}"
  cidr_block              = "${element(var.internal_subnets, count.index)}"
  availability_zone       = "${element(var.zones, count.index)}"
  map_public_ip_on_launch = false

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name        = "${var.name}-${format("internal-%03d-%s", count.index, var.environment)}"
    Environment = "${var.environment}"
  }
}

resource "aws_eip" "nat" {
  count = 2
  vpc   = true
}

resource "aws_internet_gateway" "main" {
  vpc_id = "${aws_vpc.main.id}"

  tags = {
    Name        = "${var.name}-${var.environment}"
    Environment = "${var.environment}"
  }
}

resource "aws_nat_gateway" "main" {
  count         = 2
  allocation_id = "${element(aws_eip.nat.*.id, count.index)}"
  subnet_id     = "${element(aws_subnet.external.*.id, count.index)}"

  depends_on = [
    "aws_internet_gateway.main",
  ]
}

resource "aws_route_table" "internal" {
  count  = 2
  vpc_id = "${aws_vpc.main.id}"

  tags = {
    Name        = "${var.name}-${format("rtb-%03d-%s", count.index, var.environment)}"
    Environment = "${var.environment}"
  }
}

resource "aws_route" "internal" {
  count                  = 2
  route_table_id         = "${element(aws_route_table.internal.*.id, count.index)}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${element(aws_nat_gateway.main.*.id, count.index)}"
}

resource "aws_route_table_association" "internal" {
  count          = 2
  subnet_id      = "${element(aws_subnet.internal.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.internal.*.id, count.index)}"
}

resource "aws_route_table" "external" {
  vpc_id = "${aws_vpc.main.id}"

  tags {
    Name        = "${var.name}-${var.environment}-external"
    Environment = "${var.environment}"
  }
}

resource "aws_route" "external" {
  route_table_id         = "${aws_route_table.external.id}"
  gateway_id             = "${aws_internet_gateway.main.id}"
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table_association" "external" {
  count          = 2
  subnet_id      = "${element(aws_subnet.external.*.id, count.index)}"
  route_table_id = "${aws_route_table.external.id}"
}

output "nat_external_ips" {
  value = "${aws_nat_gateway.main.*.public_ip}"
}
