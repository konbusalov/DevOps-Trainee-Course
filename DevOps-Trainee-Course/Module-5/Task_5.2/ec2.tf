resource "aws_instance" "ec2" {
  ami = "ami-07e075f00c26b085a"
  instance_type = "t3.micro"
}