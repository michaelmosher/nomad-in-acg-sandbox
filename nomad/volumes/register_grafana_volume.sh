#!/usr/bin/env bash
set -euo pipefail

export AWS_PROFILE=acg
readonly GIT_ROOT=$(git rev-parse --show-toplevel)
readonly grafanaWorkspace="$GIT_ROOT/terraform/us-east-1/app-grafana"

# get Volume info from Terraform output, the pipe it to Nomad
terraform -chdir="$grafanaWorkspace" output -raw nomad_volume_registration_info \
| nomad volume register -
