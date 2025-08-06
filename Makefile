# Makefile for generating a SealedSecret for Cloudflare tunnel credentials

# Set these variables as needed
NAMESPACE ?= ops
SECRET_NAME ?= tunnel-credentials
CREDENTIALS_FILE ?= credentials.json
SECRET_FILE ?= secret.yaml
SEALED_SECRET_FILE ?= sealed-secret.yaml

.PHONY: all clean secret sealed-secret

all: sealed-secret

# Generate a Kubernetes Secret manifest (do NOT commit secret.yaml)
secret:
	@echo "Generating Kubernetes Secret manifest..."
	kubectl create secret generic $(SECRET_NAME) \
	  --from-file=credentials.json=$(CREDENTIALS_FILE) \
	  --namespace=$(NAMESPACE) \
	  --dry-run=client -o yaml > $(SECRET_FILE)
	@echo "Secret manifest written to $(SECRET_FILE)"

# Generate a SealedSecret from the Secret manifest
sealed-secret: secret
	@echo "Generating SealedSecret..."
	kubeseal --format yaml < $(SECRET_FILE) > $(SEALED_SECRET_FILE)
	@echo "SealedSecret written to $(SEALED_SECRET_FILE)"

# Clean up generated files
clean:
	rm -f $(SECRET_FILE) $(SEALED_SECRET_FILE)
	@echo "Cleaned up generated files."
