# frozen-desserts

## Instructions
Deploy this small rails app, using AWS (You can use the free tier to test this)

## Acceptance Criteria
Acceptance criteria are listed in descending order of importance. Things closer to the bottom should be considered “stretch goals”. For example, you could deploy a version of this that uses sqlite and loses data when it is redeployed until you are able to persist data in a database.

1. it should fork the repo at https://github.com/strongmind/frozen-desserts
1. it should deploy automatically from github using github actions every time the main branch is updated
1. it should run the specs and fail to deploy if the specs fail
1. it should be available from the internet via http or https
1. it should recreate AWS resources if they are destroyed
1. it should persist data in a database

---

## Notes

The deployment architecture chosen here is leveraging Elastic Beanstalk for a simplified production ready deployment of the Rails application.
We are provisioning a separate RDS postgresql database through the elastic beanstalk provider which accomplishes a lot for us in addition to providing some useful environment variables that we will access in `config/database.yml`
This RDS instance is configured to retain a snapshot in the case the environment is terminated.  The snapshot can be restored to a new environment manually.

t3.medium is used in place of t3.micro.  The t3.micro instance type does not have enough Memory to perform initialization and upgrade tasks

### Repository Variables

`AWS_ACCESS_KEY`
`AWS_SECRET_ACCESS_KEY`
`TF_VAR_DB_PASSWORD_PROD`
`TF_VAR_DB_USER_PROD`
`TF_VAR_SECRET_KEY_BASE`


### Deployment

Deploying this repository is achieved by running the `Initialize` workflow manually to configure an s3 bucket for the Terraform state backend.
Once that is complete the Deployment can be made by running the `Deploy` workflow.

The Deploy workflow will run rspec and terraform validation of the repository which the the Deploy job is dependant on.  If any of these checks fail, Deployment will fail.

Additionally there is a validation workflow that runs exclusively on PR's to ensure that unit testing and validation is passing prior to merge.

### Upgrading

Upgrading is achieved by bumping the version variable in Terraform.  This will cause the Terraform resource to refresh and upload a source bundle derived from the current state of the repo to S3.