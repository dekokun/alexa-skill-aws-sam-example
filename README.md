# alexa-skill-aws-sam-example

[Alexa Skill](https://www.amazon.com/b?node=13727921011) deploy example with [AWS SAM](https://github.com/awslabs/serverless-application-model)

## Setup w/ AWS CLI

### Pre-requisites

- Register for an [AWS ACCOUNT](https://aws.amazon.com/)
- Install and Setup [AWS CLI](https://aws.amazon.com/cli/)
  - Setup: [AWS account and credentials](http://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html).
- Install [Node.js](https://nodejs.org/en/download/)
- Install [jq](https://stedolan.github.io/jq/download/)
- [Amazon developer account](https://developer.amazon.com/) to manage your Alexa skills.

### Installation

1. Clone the repository

```
$ git clone https://github.com/dekokun/alexa-skill-aws-sam-example.git
```

2. Change config file

```bash
$ cd alexa-skill-aws-sam-example
$ vi config.mk
```

3. ASK CLI setting

```bash
$ make setup-ask
```

4. Make S3 bucket for lambda deploy

If you already have the bucket, please skip this step.

```bash
$ make setup-s3
```

5. AWS SAM and ASK setting

```bash
$ make first-deploy
```

6. deploy

```bash
$ make deploy
```

