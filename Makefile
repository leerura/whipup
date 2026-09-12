.PHONY: pipeline-clean-ingredient

PIPELINE_DIR := tools/data-pipeline
INGREDIENT_DIR := $(PIPELINE_DIR)/ingredient

pipeline-clean-ingredient:
	rm -f $(INGREDIENT_DIR)/raw/*.json
	rm -f $(INGREDIENT_DIR)/review/*.json
	printf '{\n  "videos": {}\n}\n' > $(INGREDIENT_DIR)/manifest.json
	rm -rf $(PIPELINE_DIR)/src/__pycache__
