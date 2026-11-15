variable "DEST" {
  default = "./bin"
}

variable "CACHE" {
  default = "./tmp/cache"
}

variable "GNU_HOST" {
  default = "arm-linux-gnueabihf"
}

variable "DEBIAN_VERSION" {
  default = "bookworm-slim"
}

variable "GRPC_VERSION" {
  default = "v1.66.2"
}

group "default" {
  targets = ["default"]
}

group "all" {
  targets = ["armhf", "aarch64"]
}

group "legacy" {
  targets = ["legacy-armhf", "legacy-aarch64"]
}

target "default" {
  dockerfile = "Dockerfile"
  cache-from = ["type=local,src=${CACHE}"]
  cache-to   = ["type=local,mode=max,dest=${CACHE}"]
  output     = ["${DEST}"]
  args = {
    GNU_HOST       = "${GNU_HOST}"
    DEBIAN_VERSION = "${DEBIAN_VERSION}"
    GRPC_VERSION   = "${GRPC_VERSION}"
  }
}

target "armhf" {
  dockerfile = "Dockerfile"
  cache-from = ["type=local,src=${CACHE}-armhf"]
  cache-to   = ["type=local,mode=max,dest=${CACHE}-armhf"]
  output     = ["${DEST}/armhf"]
  args = {
    GNU_HOST       = "arm-linux-gnueabihf"
    DEBIAN_VERSION = "${DEBIAN_VERSION}"
    GRPC_VERSION   = "${GRPC_VERSION}"
  }
}

target "aarch64" {
  dockerfile = "Dockerfile"
  cache-from = ["type=local,src=${CACHE}-aarch64"]
  cache-to   = ["type=local,mode=max,dest=${CACHE}-aarch64"]
  output     = ["${DEST}/aarch64"]
  args = {
    GNU_HOST       = "aarch64-linux-gnu"
    DEBIAN_VERSION = "${DEBIAN_VERSION}"
    GRPC_VERSION   = "${GRPC_VERSION}"
  }
}

target "legacy-armhf" {
  dockerfile = "Dockerfile"
  cache-from = ["type=local,src=${CACHE}-legacy-armhf"]
  cache-to   = ["type=local,mode=max,dest=${CACHE}-legacy-armhf"]
  output     = ["${DEST}/legacy/armhf"]
  args = {
    GNU_HOST       = "arm-linux-gnueabihf"
    DEBIAN_VERSION = "bullseye-slim"
    GRPC_VERSION   = "v1.37.1"
  }
}

target "legacy-aarch64" {
  dockerfile = "Dockerfile"
  cache-from = ["type=local,src=${CACHE}-legacy-aarch64"]
  cache-to   = ["type=local,mode=max,dest=${CACHE}-legacy-aarch64"]
  output     = ["${DEST}/legacy/aarch64"]
  args = {
    GNU_HOST       = "aarch64-linux-gnu"
    DEBIAN_VERSION = "bullseye-slim"
    GRPC_VERSION   = "v1.37.1"
  }
}
