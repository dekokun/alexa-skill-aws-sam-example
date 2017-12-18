ASK = node_modules/.bin/ask
YARN = node_modules/.bin/yarn

.PHONY: setup-node
setup-node:
	npm install

node_modules/%: package.json
	@$(MAKE) setup-node
	@touch $@

.PHONY: deploy
deploy: $(ASK) $(YARN)
	$(YARN) install --cwd lambda/custom/
	$(ASK) deploy
