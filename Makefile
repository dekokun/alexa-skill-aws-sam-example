CONFIG = config.mk
include $(CONFIG)

ASK = node_modules/.bin/ask
YARN = node_modules/.bin/yarn
AWS = aws
OUTPUT_TEMPLATE = ./serverless-output.yaml
INPUT_TEMPLATE = ./example.yaml
ASK_CONFIG = ./.ask/config

.PHONY: setup-s3
setup-s3:
	$(AWS) s3 mb s3://$(BUCKET_NAME)

.PHONY: setup-ask
setup-ask: $(ASK)
	$(ASK) init

.PHONY: setup-node
setup-node:
	npm install

node_modules/%: package.json
	@$(MAKE) setup-node
	@touch $@

$(OUTPUT_TEMPLATE): $(INPUT_TEMPLATE) $(CONFIG)
	$(AWS) cloudformation package --template-file $(INPUT_TEMPLATE) --output-template-file $(OUTPUT_TEMPLATE) --s3-bucket $(BUCKET_NAME)

.PHONY: deploy-sam $(CONFIG)
deploy-sam: $(OUTPUT_TEMPLATE) $(YARN)
	$(YARN) install --cwd lambda/custom/
	$(AWS) cloudformation deploy --template-file $(OUTPUT_TEMPLATE) --stack-name $(STACK_NAME) --capabilities CAPABILITY_IAM || true

.PHONY: deploy-ask
deploy-ask: $(ASK)
	$(ASK) deploy -t skill
	$(ASK) deploy -t model

.PHONY: first-deploy
first-deploy:
	$(MAKE) deploy-sam
	$(eval LAMBDA_ARN := $(shell $(AWS) cloudformation list-exports | jq -r '.Exports[] | select(.Name == "$(STACK_NAME):AlexaSampleFunction:Arn") | select(.ExportingStackId | test("/$(STACK_NAME)/")).Value'))
	$(warning $(LAMBDA_ARN))
	cat $(ASK_CONFIG) | jq '(.deploy_settings.default.merge.skillManifest.apis.custom.endpoint.uri) |= "$(LAMBDA_ARN)"' > $(ASK_CONFIG).generated
	diff $(ASK_CONFIG) $(ASK_CONFIG).generated || true
	mv $(ASK_CONFIG).generated $(ASK_CONFIG)
	$(MAKE) deploy-ask

.PHONY: deploy
deploy:
	$(MAKE) deploy-ask
	$(MAKE) deploy-sam
