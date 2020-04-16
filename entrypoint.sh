#!/bin/sh
set -e

error() { echo "error: $*" >&2; }
die() { error "$*"; exit 1; }

! test -z "${INPUT_TF_WORKSPACE_VERSION}" || die "no workspace version specified"
! test -z "${INPUT_TF_WORKSPACE_LIST}" || die "no workspace version specified"
! test -z "${INPUT_TF_WORKSPACE_S3_BUCKET}" || die "no workspace version specified"
! test -z "${INPUT_TF_WORKSPACE_S3_KEY}" || die "no workspace version specified"
! test -z "${INPUT_TF_WORKSPACE_DYNAMODB_TABLE}" || die "no workspace version specified"

if ! test -z "${INPUT_AWS_ROLE_ARN}"; then
	set --
	if ! test -z "${INPUT_AWS_EXTERNAL_ID}"; then
		set -- --external-id "${INPUT_AWS_EXTERNAL_ID}"
	fi
	AWS_ACCESS_JSON="$(aws sts assume-role "${@}" \
		--role-arn "${INPUT_AWS_ROLE_ARN}" \
		--role-session-name 'aws-ecs-exec-action')"

	export AWS_ACCESS_KEY_ID="$(echo "${AWS_ACCESS_JSON}"|jq -r '.Credentials.AccessKeyId')"
	export AWS_SECRET_ACCESS_KEY="$(echo "${AWS_ACCESS_JSON}"|jq -r '.Credentials.SecretAccessKey')"
	export AWS_SESSION_TOKEN="$(echo "${AWS_ACCESS_JSON}"|jq -r '.Credentials.SessionToken')"
fi

DEBUG=
if test "${INPUT_DEBUG}" = 'true'; then
	DEBUG='--debug'
       	set -x
fi

! test -z "${INPUT_TF_WORKSPACE_VERSION}" || die "no workspace version specified"
! test -z "${INPUT_TF_WORKSPACE_LIST}" || die "no workspace version specified"
! test -z "${INPUT_TF_WORKSPACE_S3_BUCKET}" || die "no workspace version specified"
! test -z "${INPUT_TF_WORKSPACE_S3_KEY}" || die "no workspace version specified"
! test -z "${INPUT_TF_WORKSPACE_DYNAMODB_TABLE}" || die "no workspace version specified"

curl "https://releases.hashicorp.com/terraform/${INPUT_TF_WORKSPACE_VERSION}/terraform_${INPUT_TF_WORKSPACE_VERSION}_linux_amd64.zip"

unzip "terraform_${INPUT_TF_WORKSPACE_VERSION}_linux_amd64.zip"
chmod a+rx terraform

cat<<EOF>terraform.tf
terraform {
  required_version = "${INPUT_TF_WORKSPACE_VERSION}"
  backend "s3" {
    encrypt = true
    bucket  = "${INPUT_TF_WORKSPACE_S3_BUCKET}"
    key     = "${INPUT_TF_WORKSPACE_S3_KEY}"
    dynamodb_table = "${INPUT_TF_WORKSPACE_DYNAMODB_TABLE}"
  }
}
EOF

./terraform init
set -- ${INPUT_TERRAFORM_WORKSPACE_LIST}
for workspace; do
	! ./terraform workspace select "${workspace}" > /dev/null 2>&1 || continue
	./terraform workspace new "${workspace}"
done
