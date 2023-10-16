 # Specify the provider and access details
provider "aws" {
  region = "${var.aws_region}"
}

provider "archive" {}

data "archive_file" "zip" {
  type        = "zip"
  source_file = "newfunction.py"
  output_path = "output/newfunction_lambda.zip"
}


data "archive_file" "secondfunction_zip" {
  type        = "zip"
  source_file = "handler.py"
  output_path = "output/_lambda.zip"
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

resource "aws_lambda_function" "lambda" {
  function_name = "hello"

  filename         = "${data.archive_file.zip.output_path}"
  source_code_hash = "${data.archive_file.zip.output_base64sha256}"

  role    = "${aws_iam_role.iam_for_lambda.arn}"
  handler = "function1.handler"
  runtime = "python3.9"

  environment {
    variables = {
      greeting = "Hello thadduuu"
    }
  }
}

resource "aws_lambda_function" "newfunction" {
  function_name = "newfunction"

  filename         = "${data.archive_file.secondfunction_zip.output_path}"
  source_code_hash = "${data.archive_file.secondfunction_zip.output_base64sha256}"

  role    = "${aws_iam_role.iam_for_lambda.arn}"
  handler = "function1.newfunction"
  runtime = "python3.9"

  environment {
    variables = {
      greeting = "Hello new function"
    }
  }
}

 