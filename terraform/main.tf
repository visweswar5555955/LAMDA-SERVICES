 # Specify the provider and access details
provider "aws" {
  region = "${var.aws_region}"
}

provider "archive" {}

data "archive_file" "dynamodbStream_zip" {
  type        = "zip"
  source_file = "dynamodbStream.py"
  output_path = "output/dynamodbStream.zip"
}


data "archive_file" "DynamoIngestion_zip" {
  type        = "zip"
  source_file = "DynamoIngestion.py"
  output_path = "output/DynamoIngestion.zip"
}

data "aws_iam_policy_document" "policy" {
  statement {
    sid    = ""
    effect = "Allow"

    principals {
      identifiers = ["lambda.amazonaws.com"]
      type        = "Service"
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_lambda"
  assume_role_policy = "${data.aws_iam_policy_document.policy.json}"
}


resource "aws_lambda_function" "dynamodbStream" {
  function_name = "dynamodbStream"

  filename         = "${data.archive_file.dynamodbStream_zip.output_path}"
  source_code_hash = "${data.archive_file.dynamodbStream_zip.output_base64sha256}"

  role    = "${aws_iam_role.iam_for_lambda.arn}"
  handler = "dynamodbStream.handler"
  runtime = "python3.9"

  environment {
    variables = {
      greeting = "dynamodbStream - function"
    }
  }
}

resource "aws_lambda_function" "DynamoIngestion" {
  function_name = "dynamoIngestion"

  filename         = "${data.archive_file.DynamoIngestion_zip.output_path}"
  source_code_hash = "${data.archive_file.DynamoIngestion_zip.output_base64sha256}"

  role    = "${aws_iam_role.iam_for_lambda.arn}"
  handler = "DynamoIngestion.handler"
  runtime = "python3.9"

  environment {
    variables = {
      greeting = "DynamoIngestion - function"
    }
  }
}
