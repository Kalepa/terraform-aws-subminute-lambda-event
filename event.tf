// The policy that allows EventBridge to assume the role
data "aws_iam_policy_document" "event_assume" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      type = "Service"
      identifiers = [
        "events.amazonaws.com"
      ]
    }
  }
}
// The role policy that allows EventBridge to start the step function
data "aws_iam_policy_document" "event" {
  statement {
    actions = [
      "states:StartExecution",
    ]
    resources = [
      aws_sfn_state_machine.step.arn
    ]
  }
}
resource "aws_iam_role" "event" {
  name               = "subminute-lambda-event-eventbridge-${random_id.id.hex}"
  path               = "/subminute-lambda/"
  assume_role_policy = data.aws_iam_policy_document.event_assume.json
}
resource "aws_iam_role_policy" "event" {
  role   = aws_iam_role.event.name
  policy = data.aws_iam_policy_document.event.json
}

// Create the rule that triggers on a schedule
resource "aws_cloudwatch_event_rule" "start_step_function" {
  depends_on = [
    aws_iam_role_policy.event
  ]
  name                = "subminute-lambda-event-${random_id.id.hex}"
  schedule_expression = "rate(1 minute)"
}

// Create a target for the rule (the Lambda function)
resource "aws_cloudwatch_event_target" "step" {
  rule     = aws_cloudwatch_event_rule.start_step_function.name
  arn      = aws_sfn_state_machine.step.arn
  role_arn = aws_iam_role.event.arn
}
