resource "aws_sns_topic" "alarms" {
  name = "${var.project}-alarms"
}