resource "aws_sqs_queue" "favorites" {
    name = "${var.project}-FavoritesQueue"
    visibility_timeout_seconds = 600
}