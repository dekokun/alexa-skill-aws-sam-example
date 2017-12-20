CONFIG = config.mk
include $(CONFIG)

ASK = node_modules/.bin/ask
YARN = node_modules/.bin/yarn
AWS = aws
OUTPUT_TEMPLATE = ./serverless-output.yaml
INPUT_TEMPLATE = ./example.yaml

.PHONY: setup-s3
setup-s3:
	$(aws) s3 mb $(BUCKET_NAME)

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
deploy-sam: $(OUTPUT_TEMPLATE)
	$(YARN) install --cwd lambda/custom/
	$(AWS) cloudformation deploy --template-file $(OUTPUT_TEMPLATE) --stack-name $(STACK_NAME) --capabilities CAPABILITY_IAM

.PHONY: deploy-ask
deploy-ask:
	$(ASK) deploy -t skill
	$(ASK) deploy -t model

.PHONY: deploy
deploy: $(ASK) $(YARN)
	$(MAKE) deploy-ask
	$(MAKE) deploy-sam
