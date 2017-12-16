# alexa-skill-aws-sam-example

[Alexa Skill](https://www.amazon.com/b?node=13727921011) deploy example with [AWS SAM](https://github.com/awslabs/serverless-application-model)

## Setup w/ AWS CLI

### Pre-requisites

- Register for an [AWS ACCOUNT](https://aws.amazon.com/)
- Install and Setup [AWS CLI](https://aws.amazon.com/cli/)

### Installation

1. Clone the repository

```
$ git clone https://github.com/dekokun/alexa-skill-aws-sam-example.git
```

2. Install npm dependencies by running the npm command: `npm install`

```bash
$ cd alexa-skill-aws-sam-example
$ npm install
```

3. Make S3 bucket for lambda deploy

```bash
$ BUCKET_NAME=__YOUR_OWN_S3_BUCKET_NAME__
$ aws s3 mb s3://$BUCKET_NAME # Anything is ok if the bucket is not exists in the world.
```

4. Package lambda function and transform yaml and deploy

```bash
$ aws cloudformation package --template-file example.yaml --output-template-file serverless-output.yaml --s3-bucket $BUCKET_NAME
$ STACK_NAME=__YOUR_OWN_CLOUDFORMATION_STACK_NAME__ # Anything is ok if the stack is not exists in your account.
$ aws cloudformation deploy --template-file serverless-output.yaml --stack-name $STACK_NAME --capabilities CAPABILITY_IAM
```


