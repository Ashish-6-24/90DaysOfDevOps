resource "aws_key_pair" "terraweek_key" {
  key_name   = "terraweek-key"
  public_key = file("${pathexpand("~")}/.ssh/terraweek-key.pub")

  tags = {
    Name = "TerraWeek-KeyPair"
  }
}

