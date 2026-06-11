.PHONY: install plan test audit ui clean
install:        ## install sqlmesh + duckdb (dev)
	pip install -r requirements.txt
plan:           ## build/refresh all models in the dev (duckdb) gateway
	sqlmesh plan --auto-apply
test:           ## run unit tests
	sqlmesh test
audit:          ## run data audits
	sqlmesh audit
clean:          ## remove local duckdb build artifacts
	rm -rf db.db .cache logs
