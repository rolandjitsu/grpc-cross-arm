variable "DEST" {
  default = "./bin"
}

variable "CACHE" {
  default = "./tmp/cache"
}

group "default" {
  targets = ["default"]
}

group "all" {
  targets = ["armhf", "aarch64"]
}

target "_base" {
  dockerfile = "Dockerfile"
  context    = "."
}

target "default" {
  inherits   = ["_base"]
  cache-from = ["type=local,src=${CACHE}"]
  cache-to   = ["type=local,mode=max,dest=${CACHE}"]
  output     = ["${DEST}"]
  args = {
    GNU_HOST = "arm-linux-gnueabihf"
  }
}

target "armhf" {
  inherits   = ["_base"]
  cache-from = ["type=local,src=${CACHE}-armhf"]
  cache-to   = ["type=local,mode=max,dest=${CACHE}-armhf"]
  output     = ["${DEST}/armhf"]
  args = {
    GNU_HOST = "arm-linux-gnueabihf"
  }
}

target "aarch64" {
  inherits   = ["_base"]
  cache-from = ["type=local,src=${CACHE}-aarch64"]
  cache-to   = ["type=local,mode=max,dest=${CACHE}-aarch64"]
  output     = ["${DEST}/aarch64"]
  args = {
    GNU_HOST = "aarch64-linux-gnu"
  }
}
