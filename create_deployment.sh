#!/bin/bash
# create_deployment.sh

echo "Creating deployment package"
rsync -ax /lambda/* /deployment/python
rsync -ax /lambda_root/* /deployment/python
rsync -ax /usr/local/share/eccodes/definitions /deployment
cd /deployment
chmod 644 $(find /deployment -type f)
chmod 755 $(find /deployment -type d)
echo "Zipping..."
ls /export
zip -r9 /export/lambda.zip .