variable "name" {
    default = "terraform-lab2"
}

variable "loc" {
    default = "westeurope"
}

variable "subscription" {
    description = "Azure secret subscription id"
}

variable "tenant" {
    description = "Azure secret tenant id"
}

variable "tags" {
    # type = map()
    default = {
        evironment = "training"
        source     = "citadel"
    }
}

variable "webapplocs" {
    default = []
}