#!/usr/bin/env bash
set -euo pipefail

# ACG doesn't support us-east-2
export AWS_REGION=us-east-1


readonly hostedZones=$(aws route53 list-hosted-zones \
    | jq -r '.HostedZones | map("  " + .Name)[]')


echo "Route53 Hosted Zones:"
echo "$hostedZones"
