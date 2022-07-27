#!/usr/bin/env bash
set -euo pipefail

readonly GIT_ROOT=$(git rev-parse --show-toplevel)

# ACG doesn't support us-east-2
export AWS_REGION=us-east-1

# packer build "$GIT_ROOT/packer"

readonly hostedZones=$(aws route53 list-hosted-zones \
    | jq -r '.HostedZones | map("  " + .Name)[]')


echo "Route53 Hosted Zones:"
echo "$hostedZones"
