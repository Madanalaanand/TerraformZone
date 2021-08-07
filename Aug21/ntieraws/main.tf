resource "aws_vpc" "ntiervpc" {
    cidr_block = var.ntier_cidr

    tags = {
      "Name" = "ntier"
    }
  
}
# aws_vpc.ntiervpc.id

# depending on subnet cidr variables
resource "aws_subnet" "subnets" {
   
   count = length(var.ntier_subnet_azs)

   cidr_block = cidrsubnet(var.ntier_cidr, 8, count.index)
   availability_zone = var.ntier_subnet_azs[count.index]
   tags = {
      "Name" = var.ntier_subnet_tags[count.index]
    }
    vpc_id = aws_vpc.ntiervpc.id
  
}

# Create an internet gateway and attach to vpc

resource "aws_internet_gateway" "ntierigw" {
  vpc_id = aws_vpc.ntiervpc.id

  tags = {
    "Name" = "ntier-igw"
  }
  
}

# create a public route table

resource "aws_route_table" "publicrt" {
  vpc_id = aws_vpc.ntiervpc.id
  route = [ ]
  
  tags = {
    "Name" = "ntier-publicrt"
  }
}

resource "aws_route" "publicroute" {
  route_table_id = aws_route_table.publicrt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.ntierigw.id
}

resource "aws_route_table_association" "publicrtassociations" {
  count = length(var.web_subnet_indexes)
  subnet_id = aws_subnet.subnets[var.web_subnet_indexes[count.index]].id
  route_table_id = aws_route_table.publicrt.id
}
