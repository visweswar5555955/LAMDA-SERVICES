output "dynamodbStreamArn" {
  value = "${aws_lambda_function.dynamodbStream.qualified_arn}"
}

output "dynamoIngestionArn" {
  value = "${aws_lambda_function.DynamoIngestion.qualified_arn}"
}