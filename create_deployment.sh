#!/bin/bash
# create_deployment.sh

echo "Creating deployment package"
rsync -ax /lambda/* /deployment/python
rsync -ax /lambda_root/* /deployment/python
rsync -ax /usr/local/share/eccodes/definitions /deployment/python
cd /deployment/python
chmod 644 $(find /deployment/python -type f)
chmod 755 $(find /deployment/python -type d)
echo "Zipping..."
ls /export
zip -r9 /export/lambda.zip .