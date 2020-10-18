variable "DEST" {
	default = "./bin"
}

variable "CACHE" {
	default = "/tmp/grpc-cross-cache"
}

target "default" {
	dockerfile = "Dockerfile"
  cache-from = ["type=local,src=${CACHE}"]
	cache-to = ["type=local,mode=max,dest=${CACHE}"]
	output = ["${DEST}"]
}
