AWS Terraform Workspace Create
==============================

Action for the creation of Terraform Workspaces within AWS S3.

This action expects AWS credentials to have already been initialized.
See: https://github.com/aws-actions/configure-aws-credentials

Usage
-----

```yaml
  - name: Configure AWS Credentials
    uses: aws-actions/configure-aws-credentials@v1
    with:
      aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
      aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
      aws-region: us-east-2
  - name: Terraform Workspace
    uses: aplaceformom/aws-terraform-workspace-action@master
    with:
      tf-workspace-version: 0.11.14
      tf-workspace-list: dev stage prod
      tf-workspace-s3-bucket: my-s3-bucket
      tf-workspace-s3-key: my-app
      tf-workspace-dynamodb-table: my-terraform-locks
```

Inputs
------

### tf-workspace-version
Specify which version of Terraform to use.
- required: true

### tf-workspace-list:
List of workspaces to create
- required: true

### tf-workspace-s3-bucket:
Name of S3 bucket backend
- required: true

### tf-workspace-s3-key
S3 Bucket key for workspace
- required: true

### tf-workspace-dynamodb-table
DynamoDB table used for locking
- required: true

### tf-assume-role-arn
AWS IAM Role to assume (optional)
- required: false


### tf-external-id
External ID to use when assuming roles (optional)
- required false

### debug
Enable debugging
- required: false
- default: false
