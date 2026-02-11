resource "aws_s3_bucket" "Source_bucket" {
  bucket = "srigana-source-bucket-675"

  tags = {
    Name        = "My Source bucket"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_public_access_block" "Source_public_access" {
  bucket = aws_s3_bucket.Source_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "Source_versioning" {
  bucket = aws_s3_bucket.Source_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "source_bucket" {
  bucket = aws_s3_bucket.Source_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket" "Dest_bucket" {
  bucket = "srigana-dest-bucket-675"

  tags = {
    Name        = "My Dest bucket"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_public_access_block" "Dest_public_access" {
  bucket = aws_s3_bucket.Dest_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "Dest_versioning" {
  bucket = aws_s3_bucket.Dest_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "dest_bucket" {
  bucket = aws_s3_bucket.Dest_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_lambda_layer_version" "pillow_layer" {
  filename         = "${path.module}/pillow_layer.zip"
  layer_name       = "pillow_layer"
  description      = "Shared utilities for Lambda functions"

  compatible_runtimes = [
    "python3.12"
  ]

  compatible_architectures = ["x86_64"]
}

resource "aws_lambda_function" "image_processor" {
  function_name = "image-processor"

  filename         = "${path.module}/lambda.zip"
  source_code_hash = filebase64sha256("${path.module}/lambda.zip")

  handler = "lambda.lambda_handler"
  runtime = "python3.12"
  role    = aws_iam_role.image_processor_role.arn

  architectures = ["x86_64"]

  timeout     = 60
  memory_size = 1024

  environment {
    variables = {
      PROCESSED_BUCKET = aws_s3_bucket.Dest_bucket.bucket
      LOG_LEVEL        = "INFO"
    }
  }
  layers = [aws_lambda_layer_version.pillow_layer.arn]
}

resource "aws_iam_role" "image_processor_role" {
  name = "image_processor_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic_logs" {
  role       = aws_iam_role.image_processor_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "image_processor_test_policy" {
  name = "image_processor_test_policy"
  role = aws_iam_role.image_processor_role.id

  policy = jsonencode({
	Version = "2012-10-17",
	Statement = [
		{
			Sid = "ReadFromSourceBucket",
			Effect = "Allow",
			Action = [
				"s3:GetObject"
			],
			Resource = "arn:aws:s3:::${aws_s3_bucket.Source_bucket.bucket}/*"
		},
		{
			Sid = "WriteToDestBucket",
			Effect = "Allow",
			Action = [
				"s3:PutObject"
			],
			Resource = "arn:aws:s3:::${aws_s3_bucket.Dest_bucket.bucket}/*"
		}
	]
  })
}

resource "aws_lambda_permission" "allow_s3" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.image_processor.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.Source_bucket.arn
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.Source_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.image_processor.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_permission.allow_s3]
}


