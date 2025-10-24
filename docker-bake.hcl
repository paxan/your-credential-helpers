variable "GO_VERSION" {
  default = null
}

# Defines the output folder
variable "DESTDIR" {
  default = ""
}
function "bindir" {
  params = [defaultdir]
  result = DESTDIR != "" ? DESTDIR : "./bin/${defaultdir}"
}

target "_common" {
  args = {
    GO_VERSION = GO_VERSION
  }
}

group "default" {
  targets = ["binaries"]
}

group "validate" {
  targets = ["lint"]
}

target "lint" {
  inherits = ["_common"]
  target = "lint"
  output = ["type=cacheonly"]
}

target "test" {
  inherits = ["_common"]
  target = "test-coverage"
  output = [bindir("coverage")]
}

target "binaries" {
  inherits = ["_common"]
  target = "binaries"
  output = [bindir("build")]
  platforms = [
    "darwin/amd64",
    "darwin/arm64",
    "linux/amd64",
    "linux/arm64",
    "linux/arm/v7",
    "linux/arm/v6",
    "linux/ppc64le",
    "linux/s390x",
    "windows/amd64",
    "windows/arm64"
  ]
}

target "release" {
  inherits = ["binaries"]
  target = "release"
  output = [bindir("release")]
}
