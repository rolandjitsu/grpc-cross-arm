variable "DEST" {
	default = "./bin"
}

target "default" {
	dockerfile = "Dockerfile"
	output = ["${DEST}"]
}
