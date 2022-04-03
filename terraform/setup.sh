#!/usr/bin/env bash
set -euo pipefail

# ACG doesn't support us-east-2
export AWS_REGION=us-east-1

readonly accountID=$(aws sts get-caller-identity \
    | jq -r '.Account')

readonly s3BucketName="${accountID}-terraform-state"

aws s3api create-bucket --acl private --bucket "$s3BucketName"

readonly sseConfig=$(jq -n '{
    "Rules": [
        {
            "ApplyServerSideEncryptionByDefault": {
                "SSEAlgorithm": "aws:kms"
            }
        }
    ]
}')
aws s3api put-bucket-versioning --bucket "$s3BucketName" \
    --versioning-configuration "Status=Enabled"

aws s3api put-bucket-encryption --bucket "$s3BucketName" \
    --server-side-encryption-configuration "$sseConfig"

echo "$s3BucketName"

readonly hostedZones=$(aws route53 list-hosted-zones \
    | jq -r '.HostedZones | map("  " + .Name)[]')


echo "Route53 Hosted Zones:"
echo "$hostedZones"
