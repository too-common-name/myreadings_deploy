# MyReadings - Deployment and Infrastructure

This repository contains all the necessary configurations for the infrastructure and deployment of the **MyReadings** application. Its purpose is to define the entire local development environment as **Infrastructure as Code (IaC)**, ensuring it is reproducible, versioned, and easy to launch.

This repository is one of the four main components of the project:

- `myreadings`: The modular backend built with Quarkus.
- `myreadings_user_service`: The extracted user microservice (standalone Quarkus app).
- `myreadings_ui`: The frontend built with Vue.js.
- `myreadings_deploy` (this repo): The infrastructure and provisioning configuration.

## Technology Stack

- **Docker Compose**: To orchestrate the infrastructure services in a local development environment.
- **PostgreSQL**: As the main database.
- **Keycloak**: For Identity and Access Management (IAM).
- **RabbitMQ**: As the message broker for asynchronous communication.
- **Ansible**: For provisioning and "Day 1" configuration of services (Keycloak realms/clients, RabbitMQ vhosts/users).

## Repository Structure

- `docker-compose.yaml`: The base file that defines all infrastructure services and the monolith application.
- `docker-compose.monolith-local.yaml`: Overlay for running the monolith with a pre-built fast-jar (faster than the multi-stage Docker build).
- `docker-compose.extracted.yaml`: Overlay that adds the `user-service`, configures the REST client URL, and mounts the extracted nginx routing config.
- `nginx-extracted.conf`: Nginx config that routes `/api/v1/users/` to the user-service and everything else to the monolith.
- `.env`: Environment variables for all services.
- `ansible/`: Ansible playbooks and roles for automatic provisioning (Keycloak, RabbitMQ).
- `pg-init/`: SQL scripts for PostgreSQL database initialization.
- `pgadmin/`: Auto-registration config for pgAdmin.
- `keycloak-jars/`: Custom Keycloak provider JARs (theme, RabbitMQ event listener).

## Architecture Modes

### Mode 1: Monolith (all-in-one)

The backend runs as a single Quarkus application containing all modules (user, catalog, readinglist, review). Uses the `main` branch of `myreadings`.

```
UI (nginx) → Monolith (port 8081) → PostgreSQL
                ↑
          Keycloak → RabbitMQ
```

### Mode 2: Extracted (monolith + user-service)

The user module is extracted into a standalone microservice. The monolith delegates user operations to the user-service via REST. Uses the `refactored` branch of `myreadings`.

```
UI (nginx) ─┬→ /api/v1/users/  → User-Service (port 8083) → PostgreSQL (users_db)
             └→ /api/*          → Monolith (port 8081)     → PostgreSQL (books/readinglist/review_db)
                                        ↑ REST client
                                        └── User-Service

Keycloak → RabbitMQ → User-Service → (user-profile-created) → RabbitMQ → Monolith
```

## Quick Start

All commands must be run from this directory (`myreadings_deploy`).

### Prerequisites

- Docker / Podman with Docker Compose
- Java 21 + Maven (for pre-building)

### Infrastructure Only (for local development)

Starts Keycloak, PostgreSQL, RabbitMQ, and PgAdmin:

```bash
docker compose up -d
```

### Monolith Mode

**Option A — Multi-stage Docker build (slow, no pre-build needed):**

Make sure `myreadings` is on the `main` branch, then:

```bash
docker compose --profile app up -d --build
```

**Option B — Pre-built fast-jar (fast, recommended):**

```bash
# 1. Build the monolith (main branch)
cd ../myreadings && git checkout main && ./mvnw clean package -DskipTests && cd -

# 2. Start with the local overlay
docker compose -f docker-compose.yaml -f docker-compose.monolith-local.yaml --profile app up -d --build
```

### Extracted Mode (monolith + user-service)

```bash
# 1. Build the monolith (refactored branch)
cd ../myreadings && git checkout refactored && ./mvnw clean package -DskipTests && cd -

# 2. Build the user-service
cd ../myreadings_user_service && mvn clean package -DskipTests && cd -

# 3. Start with the extracted overlay
docker compose -f docker-compose.yaml -f docker-compose.extracted.yaml --profile app up -d --build
```

### Access Points

| Service     | URL                     | Credentials            |
|-------------|-------------------------|------------------------|
| UI          | http://localhost:3000    | Register a new account |
| Keycloak    | http://localhost:8080    | admin / admin          |
| RabbitMQ    | http://localhost:15672   | admin / admin          |
| PgAdmin     | http://localhost:8082    | user@example.com / admin |

### Stopping

```bash
# Stop containers (keep data)
docker compose --profile app down

# Stop and wipe all data
docker compose --profile app down -v
```

## Ansible Provisioning

The `ansible-provisioner` container runs automatically on startup and configures:

**Keycloak:**
- Realm `my-readings` with self-registration enabled
- Client `myreadings-client` (public, PKCE)
- Roles: `user`, `admin`
- Event listener: `keycloak-to-rabbitmq` (fires RabbitMQ events on user registration)
- Custom login theme

**RabbitMQ:**
- Vhost `my-readings`
- Application user `myreadings-user` with full permissions
- Queue `myreadings-queue` bound to `amq.topic` for Keycloak registration events

In **Extracted mode**, the `user-events` RabbitMQ exchange and `monolith-user-created-queue` are auto-declared by the applications via SmallRye Reactive Messaging (`declare=true`).
