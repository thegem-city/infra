resource "aws_s3_bucket" "files" {
  bucket = "thegem-city-assets"
}

resource "aws_s3_bucket" "backups" {
  bucket = "thegem-city-backups"
}

resource "aws_s3_bucket_acl" "backups" {
  bucket = aws_s3_bucket.backups.id
  acl    = "private"
}

resource "aws_s3_bucket_lifecycle_configuration" "clear_old_backups" {
  bucket = aws_s3_bucket.backups.bucket

  rule {
    id = "database_dumps"

    expiration {
      days = 90
    }

    filter {
      and {
        prefix = "mastodon_production/"
        tags = {
          autoclean = "true"
        }
      }
    }

    status = "Enabled"

  }
}
