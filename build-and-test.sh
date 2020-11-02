#!/bin/bash

VERSION=$(cat VERSION)

# docker build . -t developmentseed/geolambda:${VERSION}
# docker run --rm -v $PWD:/home/geolambda -it developmentseed/geolambda:${VERSION} package.sh
# connor dev version:
sudo docker build . -t scootscience/geolambda:${VERSION}
sudo docker run --rm -v $PWD:/home/geolambda -it scootscience/geolambda:${VERSION} package.sh


# test below
# cd python
# docker build . --build-arg VERSION=${VERSION} -t developmentseed/geolambda:${VERSION}-python
# docker run -v ${PWD}:/home/geolambda -t developmentseed/geolambda:${VERSION}-python package-python.sh

# docker run --rm -v ${PWD}/lambda:/var/task -v ${PWD}/../lambda:/opt lambci/lambda:python3.7 lambda_function.lambda_handler '{}'

# publish
aws lambda publish-layer-version \
	--layer-name cfgribGeolambda \
	--license-info "Proprietary" \
	--description "EECodes C library (libeccodes0) for cfGrib driver (adds GRIB file backend for xarray)" \
	--zip-file fileb://lambda-deploy.zip
    # --compatible-runtimes python3.6 python3.7

# aws lambda publish-layer-version \
# 	--layer-name cfgribGeolambda \
# 	--license-info "Proprietary" \
# 	--description "EECodes C library (libeccodes0) for cfGrib driver (adds GRIB file backend for xarray)" \
# 	--zip-file fileb://lambda.zip

# aws lambda publish-layer-version \
# 	--layer-name cfgribGeolambda \
# 	--license-info "Proprietary" \
# 	--description "EECodes C library (libeccodes0) for cfGrib driver (adds GRIB file backend for xarray)" \
# 	--zip-file fileb://docker_layer.zip

# attach to lambda
