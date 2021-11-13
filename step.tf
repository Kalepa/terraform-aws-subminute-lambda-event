// The policy that allows the step function to assume the role
data "aws_iam_policy_document" "step_assume" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      type = "Service"
      identifiers = [
        "states.amazonaws.com"
      ]
    }
  }
}
// The policy that allows the step function to invoke the iterator Lambda
data "aws_iam_policy_document" "step" {
  statement {
    actions = [
      "lambda:InvokeFunction",
      "lambda:InvokeAsync",
    ]
    resources = [
      module.lambda_iterator.lambda.arn
    ]
  }
}
resource "aws_iam_role" "step_function" {
  name               = "subminute-lambda-event-step-${random_id.id.hex}"
  path               = "/subminute-lambda/"
  assume_role_policy = data.aws_iam_policy_document.step_assume.json
}
resource "aws_iam_role_policy" "step_function" {
  role   = aws_iam_role.step_function.name
  policy = data.aws_iam_policy_document.step.json
}


locals {
  interval_seconds = floor(var.interval_seconds)
}

resource "aws_sfn_state_machine" "step" {
  name     = "subminute-lambda-event-${random_id.id.hex}"
  role_arn = aws_iam_role.step_function.arn
  type     = "EXPRESS"
  definition = jsonencode({
    Comment = "Sub-minute Lambda event"
    StartAt = "ConfigureCount"
    States = {
      ConfigureCount = {
        Type = "Pass"
        Result = {
          index = 0
          count = floor(60 / local.interval_seconds + 0.5)
        }
        ResultPath = "$.iterator"
        Next       = "Iterator"
      }
      Iterator = {
        Type       = "Task"
        Resource   = module.lambda_iterator.lambda.arn
        ResultPath = "$.iterator"
        Next       = "IsCountReached"
      }
      IsCountReached = {
        Type = "Choice"
        Choices = [
          {
            Variable      = "$.iterator.continue"
            BooleanEquals = true
            Next          = "Wait"
          }
        ]
        Default = "Done"
      }
      Wait = {
        Type    = "Wait"
        Seconds = local.interval_seconds
        Next    = "Iterator"
      }
      Done = {
        Type = "Pass"
        End  = true
      }
    }
  })
}
