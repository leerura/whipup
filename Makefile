.PHONY: generate-api generate-api-flutter generate-api-backend pipeline-clean-ingredient

OPENAPI_GENERATOR_IMAGE := openapitools/openapi-generator-cli:v7.25.0
OPENAPI_SPEC := /local/docs/api/openapi.yaml
OPENAPI_DOCKER := docker run --rm -v "$(CURDIR):/local" $(OPENAPI_GENERATOR_IMAGE)
FLUTTER_API_CLIENT_DIR := app/packages/api_client
BACKEND_OPENAPI_DIR := $(CURDIR)/backend/generated/openapi

PIPELINE_DIR := tools/data-pipeline
INGREDIENT_DIR := $(PIPELINE_DIR)/ingredient

generate-api: generate-api-flutter generate-api-backend

generate-api-flutter:
	$(OPENAPI_DOCKER) generate \
		-i $(OPENAPI_SPEC) \
		-g dart-dio \
		-c /local/docs/api/codegen/flutter.yaml \
		-o /local/app/packages/api_client
	cd $(FLUTTER_API_CLIENT_DIR) && dart pub get
	cd $(FLUTTER_API_CLIENT_DIR) && dart run build_runner build --delete-conflicting-outputs

generate-api-backend:
	test "$(BACKEND_OPENAPI_DIR)" = "$(CURDIR)/backend/generated/openapi"
	rm -rf -- "$(BACKEND_OPENAPI_DIR)"
	$(OPENAPI_DOCKER) generate \
		-i $(OPENAPI_SPEC) \
		-g spring \
		-c /local/docs/api/codegen/backend.yaml \
		-o /local/backend/generated/openapi

pipeline-clean-ingredient:
	rm -f $(INGREDIENT_DIR)/raw/*.json
	rm -f $(INGREDIENT_DIR)/review/*.json
	printf '{\n  "videos": {}\n}\n' > $(INGREDIENT_DIR)/manifest.json
	rm -rf $(PIPELINE_DIR)/src/__pycache__
