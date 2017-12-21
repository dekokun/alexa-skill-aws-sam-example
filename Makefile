CONFIG = config.mk
include $(CONFIG)

ASK := node_modules/.bin/ask
YARN := node_modules/.bin/yarn
AWS := $(shell command -v aws 2> /dev/null)
JQ := $(shell command -v jq 2> /dev/null)
NODE := $(shell command -v jq 2> /dev/null)
OUTPUT_TEMPLATE := ./serverless-output.yaml
INPUT_TEMPLATE := ./template.yml
ASK_CONFIG := ./.ask/config
ASK_CONFIG_SAMPLE := ./.ask/config.sample

.PHONY: check-commands
check-commands:
ifndef JQ
	$(error "jq is not available please install jq.")
endif
ifndef AWS
	$(error "AWS CLI is not available please install AWS CLI.")
endif
ifndef NODE
	$(error "Node.js is not available please install Node.js.")
endif

.PHONY: setup-s3
setup-s3: check-commands
	$(AWS) s3 mb s3://$(BUCKET_NAME)

.PHONY: setup-ask
setup-ask: $(ASK)
	$(ASK) init

.PHONY: setup-node check-commands
setup-node:
	npm install

node_modules/%: package.json
	@$(MAKE) setup-node
	@touch $@

$(OUTPUT_TEMPLATE): $(INPUT_TEMPLATE) $(CONFIG) check-commands
	$(AWS) cloudformation package --template-file $(INPUT_TEMPLATE) --output-template-file $(OUTPUT_TEMPLATE) --s3-bucket $(BUCKET_NAME)

.PHONY: deploy-sam $(CONFIG)
deploy-sam: $(OUTPUT_TEMPLATE) $(YARN) check-commands
	$(YARN) install --cwd lambda/custom/
	$(AWS) cloudformation deploy --template-file $(OUTPUT_TEMPLATE) --stack-name $(STACK_NAME) --capabilities CAPABILITY_IAM || true

.PHONY: deploy-ask
deploy-ask: $(ASK) $(ASK_CONFIG)
	$(ASK) deploy -t skill
	$(ASK) deploy -t model

$(ASK_CONFIG): $(ASK_CONFIG_SAMPLE) $(CONFIG) check-commands
	$(eval LAMBDA_ARN := $(shell $(AWS) cloudformation list-exports | $(JQ) -r '.Exports[] | select(.Name == "$(STACK_NAME):AlexaSampleFunction:Arn") | select(.ExportingStackId | test("/$(STACK_NAME)/")).Value'))
	$(warning $(LAMBDA_ARN))
	cat $(ASK_CONFIG_SAMPLE) | $(JQ) '(.deploy_settings.default.merge.skillManifest.apis.custom.endpoint.uri) |= "$(LAMBDA_ARN)"' > $(ASK_CONFIG)

.PHONY: deploy
deploy:
	$(MAKE) deploy-sam
	$(MAKE) deploy-ask
	@echo deploy finished !!!
