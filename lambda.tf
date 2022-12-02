data "aws_iam_policy_document" "iterator" {
  statement {
    actions = [
      "lambda:InvokeFunction",
      "lambda:InvokeAsync",
    ]
    resources = [
      var.lambda_arn,
    ]
  }
}

// The function that calls the function of interest
module "lambda_iterator" {
  source  = "Invicton-Labs/lambda-set/aws"
  version = "~> 0.5"
  edge    = false
  lambda_config = {
    function_name                  = "subminute-lambda-event-iterator-${random_id.id.hex}"
    filename                       = "${path.module}/iterator.zip"
    timeout                        = 2
    memory_size                    = 128
    handler                        = "main.lambda_handler"
    runtime                        = "python3.9"
    reserved_concurrent_executions = 1
    architectures                  = var.use_x86_64 ? ["x86_64"] : ["arm64"]
    environment = {
      variables = {
        LAMBDA_ARN = var.lambda_arn
        PAYLOAD    = jsonencode(var.payload)
      }
    }
  }
  role_policies = [
    data.aws_iam_policy_document.iterator.json
  ]
}
