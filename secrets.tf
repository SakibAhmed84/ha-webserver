# This File is for keeping the Secrets locally as variables away from the other TF Files. 
# This File must be updated with the appropriate Access Key and Secret Key locally
# Pulling the Repository will overwrite the local file therefore in that case it will need to be updated again

variable "access_key" {
  description = "AWS Access Key"
  type        = string
  default     = "<INSERT AWS ACCESS KEY HERE>"

}
variable "secret_key" {
  description = "AWS Secret Key"
  type        = string
  default     = "<INSERT AWS SECRET KEY HERE>"
}
