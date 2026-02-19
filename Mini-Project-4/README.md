
# Serverless Image Processor (AWS + Terraform)

This project is a simple serverless image processing pipeline built using AWS and Terraform.

Whenever an image is uploaded to an S3 source bucket, a Lambda function is triggered automatically. The function processes the image using Pillow and saves multiple optimized versions into a destination bucket.

## What It Does

For every uploaded image, the system generates:

- Compressed JPEG (85%)
- Low-quality JPEG (60%)
- WebP version
- PNG version
- Thumbnail (300x300)

All processing happens automatically. No manual steps required after upload.

## Architecture Overview

1. Image uploaded to S3 source bucket  
2. S3 triggers Lambda function  
3. Lambda processes image  
4. Processed images saved to destination bucket  

## Tech Used

- AWS S3  
- AWS Lambda (Python 3.12)  
- IAM  
- Terraform  
- Docker  
- Pillow  

## Deployment

```bash
zip -r lambda.zip lambda.py
terraform init
terraform apply
```
### Upload an image:
```bash
aws s3 cp image.jpg s3://<source-bucket-name>/
```
Cleanup
```bash
terraform destroy
```
