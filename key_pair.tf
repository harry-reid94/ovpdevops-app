#SSH key to access instances
resource "aws_key_pair" "ovpDevOpsKey" {
  key_name   = "ovpDevOpsKey"
  public_key = file(var.public_key)
}