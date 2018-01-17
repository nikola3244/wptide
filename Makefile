# @TODO: Perhaps move some of these to another Makefile.
EXECNAME=lh-server
BINARY=bin/${EXECNAME}
GOOS=linux
LOCAL=local
LOCALBIN=bin/${LOCAL}/${EXECNAME}
GO=`which go`
GOBUILD=CGO_ENABLED=0 GOOS=${GOOS} ${GO} build
GOBUILDLOCAL=${GO} build
PACKAGEPATH=./cmd/lh-server/...
TAG=0.0.1

# @TODO: Add a <example>.properties Makefile to include additional variables.
#        See: https://github.com/tpryan/whack_a_pod Sample.properties

# Binary version.
VERSION=0.0.1
BUILD=`git rev-parse HEAD`

# Setup -ldflags for go build.
# Allows setting some global vars before compilation.
LDFLAGS=-ldflags "-X main.Version=${VERSION} -X main.Build=${BUILD}"

default:
	@echo "Please supply one of:\n\tclean\n\tbuild\n\tpackage\n\tall"
	@echo "Variables: EXECNAME, BINARY, GOOS, LOCAL, LOCALBIN, GO, GOBUILD, GOBUILDLOCAL, PACKAGEPATH, TAG"

clean:
	@echo "Cleaning up ..."
	@if [ -f ${BINARY} ]; then rm ${BINARY} ; fi
	@if [ -f ${LOCAL}/${BINARY} ]; then rm ${LOCAL}/${BINARY} ; fi
	@rm certs/cacert.pem

cert:
	@echo "Getting root certs for SSL/TLS ..."
	@curl --output certs/cacert.pem https://curl.haxx.se/ca/cacert.pem -s

build:
	@echo "Building ${BINARY} ..."
	@${GOBUILD} ${LDFLAGS} -o ${BINARY} ${PACKAGEPATH}

local:
	@echo "Building ${LOCALBIN} ..."
	@${GOBUILDLOCAL} ${LDFLAGS} -o ${LOCALBIN} ${PACKAGEPATH}

package: clean cert build
	@echo "Building Docker image [${TAG}] ..."
	@docker build -t ${TAG} --no-cache .

all: clean cert build local package