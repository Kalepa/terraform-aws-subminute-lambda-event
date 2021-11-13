# Terraform AWS Sub-Minute Lambda Event

This module triggers a Lambda function on a schedule more frequent than once per minute (which is the current limitation of EventBridge rules). It utilizes a step function and an "iterator" Lambda to accomplish this.

### Usage
```
module "location_updater_schedule" {
  source           = "Invicton-Labs/subminute-lambda-event/aws"

  // The ARN of the Lambda you want to invoke on a sub-minute schedule
  lambda_arn       = aws_lambda_function.my_lambda.arn
  
  // The interval between Lambda start times (not the time between the completion of one invocation and the start of the next)
  interval_seconds = 5

  // The value of the `event` variable in your Lambda handler (optional, defaults to `{}`)
  payload = {
      field1 = "value1"
      field2 = 2
  }
}
```
