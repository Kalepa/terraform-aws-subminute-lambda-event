variable "use_x86_64" {
  description = "Use the x86_64 environment for the Lambda trigger function instead of ARM. By default, this module uses ARM as it has a lower cost. Set this to `true` if you're deploying this module in a region that does not yet support ARM for Lambda functions."
  type        = bool
  default     = false
}

variable "lambda_arn" {
  description = "The ARN of the Lambda function that you would like to invoke on a sub-minute schedule."
  type        = string
}

variable "interval_seconds" {
  description = "The number of seconds between invocations. This is the interval between the start of one invocation and the start of the next, not between the end of one invocation and the start of the next."
  type        = number
  validation {
    condition     = var.interval_seconds >= 1 && var.interval_seconds <= 30 && floor(var.interval_seconds) == var.interval_seconds
    error_message = "The `interval_seconds` variable must be an integer from 1 to 30 (inclusive)."
  }
  validation {
    condition     = floor(60 / var.interval_seconds) == 60 / var.interval_seconds
    error_message = "The `interval_seconds` variable must be an integer factor of 60 (i.e. 60 divided by `interval_seconds` must be a whole number)."
  }
}

variable "payload" {
  description = "The payload that you want to deliver to the Lambda. This will be the value of the `event` in your Lambda handler."
  type        = any
  default     = {}
}
