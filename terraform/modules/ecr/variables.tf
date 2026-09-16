variable "name" {
  description = "The name of the repository"
  type        = string
}

variable "image_tag_mutability" {
  description = "The tag mutability setting for the repository. Valid values are 'MUTABLE' or 'IMMUTABLE'."
  type        = string
  default     = "MUTABLE"
}

variable "scan_on_push" {
  description = "Whether to scan images on push. Valid values are true or false."
  type        = bool
  default     = false
}

variable "tags" {
  description = "A map of tags to assign to the resource."
  type        = map(string)
  default     = {}
}