.PHONY: build deploy test scan clean infra

build:
	@echo "🏗️  Building Sentinel Guard..."
	docker build -t bit-hub/sentinel-guard:local -f docker/sentinel-guard/Dockerfile .

deploy-local:
	@echo "🐳 Deploying locally via Docker Compose..."
	docker-compose up -d

deploy-k8s:
	@echo "☸️  Deploying to Kubernetes..."
	helm upgrade --install sentinel-ironveil deploy/helm/sentinel-ironveil/ --namespace sentinel --create-namespace

test-attack:
	@echo "🧪 Simulating attack..."
	cd tests/integration/attack-sim && ./simulate-brute-force.sh

scan:
	@echo "🔍 Scanning images..."
	trivy image bit-hub/sentinel-guard:local

freeze-container:
	@echo "🧊 Freezing suspicious container..."
	./scripts/freeze-container.sh $(CONTAINER_ID)

generate-secrets:
	@echo "🔐 Generating SealedSecrets..."
	./scripts/generate-sealed-secrets.sh

clean:
	docker-compose down -v
