resource "null_resource" "managed-ad-security-group" {
 provisioner "local-exec" {
    
    command = "/bin/bash ${path.module}/src/ip-change.sh"
    environment = {
      securityGroup_id = data.aws_security_group.ad_security_group.id
      new_source_ip    = var.new_source_ip
    }
  }
}