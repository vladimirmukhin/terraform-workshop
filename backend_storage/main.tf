resource "aws_s3_bucket" "backend_storage" {
  bucket = "terraform-remote-state-vladimir"
}

resource "aws_dynamodb_table" "terraform-lock-table" {
  name           = "terraform-lock-table"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
