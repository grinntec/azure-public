#these are the default variables for all resources
variable "appName" {
    description     = "Name of the application"
    type            = string

    validation {
        condition = (
                length(var.appName) >=3 &&
                length(var.appName) <=24 &&
                can(regex("[a-z.*]|[0-9]", var.appName))
        )
        error_message = "STOP! The appName value must be between 3 and 24 characters, be lower case and only contain characters or numbers."
    }
}

variable "location" {
  description       = "Name of the location"
  type              = string

    validation {
        condition = anytrue([
            var.location == "west europe",
            var.location == "north europe",
            var.location == "east us"
        ])
        error_message = "STOP! The location must be either 'west europe', 'north europe', or 'east us' and lower case."
    }
}

variable "environment" {
    description     = "Type of environment; 'prod', 'test', 'dev'"
    type            = string

    validation {
        condition = anytrue([
            var.environment == "prod",
            var.environment == "test",
            var.environment == "dev"
        ])
        error_message = "STOP! The environment must be either 'prod', 'test', or 'dev' and lower case."
    }
}

variable "createdby" {
    description     = "Name of who created the resource"
    type            = string
}
