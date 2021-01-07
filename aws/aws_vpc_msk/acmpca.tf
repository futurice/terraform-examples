/*
resource "aws_acmpca_certificate_authority" "pca" {
  certificate_authority_configuration {
    key_algorithm     = "RSA_4096"
    signing_algorithm = "SHA512WITHRSA"

    subject {
      common_name = "pca.${lower(var.environment)}.example.com"
    }
  }
}
*/

/*
resource "aws_iam_role_policy_attachment" "Kafka-Client-IAM-role-att3" {
  policy_arn = "arn:aws:iam::aws:policy/AWSCertificateManagerPrivateCAPrivilegedUser"
  role       = "${aws_iam_role.KafkaClientIAM_Role.name}"
}
*/
