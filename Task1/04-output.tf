# https://storage.googleapis.com/peak-radius-416401/index.html
output "bucket_url" {
  value = "${var.google_bucket_url}${google_storage_bucket.dont-save-her.name}/index.html"
}