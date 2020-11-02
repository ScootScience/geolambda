#!/bin/bash
# create_deployment.sh
# from here: https://github.com/difu/eccodes-lambda

echo "Creating deployment package"
rsync -ax /lambda/* /deployment
rsync -ax /lambda_root/* /deployment
rsync -ax /usr/local/share/eccodes/definitions /deployment
cd /deployment
chmod 644 $(find /deployment -type f)
chmod 755 $(find /deployment -type d)
echo "Zipping..."
ls /export
zip -r9 /export/lambda.zip .

'''
# =================
# method from here: https://stackoverflow.com/questions/55695187/import-libraries-in-lambda-layers/55696651#55696651

#!/usr/bin/env bash

LAYER_NAME=$1 # input layer, retrived as arg
ZIP_ARTIFACT=${LAYER_NAME}.zip
LAYER_BUILD_DIR="python"

# note: put the libraries in a folder supported by the runtime, means that should by python

rm -rf ${LAYER_BUILD_DIR} && mkdir -p ${LAYER_BUILD_DIR}

docker run --rm -v `pwd`:/var/task:z lambci/lambda:build-python3.6 python3.6 -m pip --isolated install -t ${LAYER_BUILD_DIR} -r requirements.txt

zip -r ${ZIP_ARTIFACT} .

echo "Publishing layer to AWS..."
aws lambda publish-layer-version --layer-name ${LAYER_NAME} --zip-file fileb://${ZIP_ARTIFACT} --compatible-runtimes python3.6

# clean up
rm -rf ${LAYER_BUILD_DIR}
rm -r ${ZIP_ARTIFACT}
'''