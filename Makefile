.PHONY: install plan test audit ui clean
install:        ## install deps (uv)
	uv sync
plan:           ## build/refresh all models against the mysql gateway
	sqlmesh plan --auto-apply
test:           ## run unit tests (against test_connection)
	sqlmesh test
audit:          ## run data audits
	sqlmesh audit
ui:             ## launch the SQLMesh web UI
	sqlmesh ui
clean:          ## remove local build artifacts
	rm -rf .cache logs
