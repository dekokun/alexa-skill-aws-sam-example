ASK = node_modules/.bin/ask

.PHONY: setup-node
setup-node:
	npm install

node_modules/%: package.json
	@$(MAKE) setup-node
	@touch $@

.PHONY: deploy
deploy: $(ASK)
	$(ASK) deploy
