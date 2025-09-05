# MyReadings - Deployment and Infrastructure

This repository contains all the necessary configurations for the infrastructure and deployment of the **MyReadings** application. Its purpose is to define the entire local development environment as **Infrastructure as Code (IaC)**, ensuring it is reproducible, versioned, and easy to launch.

This repository is one of the three main components of the project:

- `myreadings`: The modular backend built with Quarkus.
- `myreadings_ui`: The frontend built with Vue.js.
- `myreadings_deploy` (this repo): The infrastructure and provisioning configuration.

## Technology Stack

- **Docker Compose**: To orchestrate the infrastructure services in a local development environment.
- **PostgreSQL**: As the main database.
- **Keycloak**: For Identity and Access Management (IAM).
- **RabbitMQ**: As the message broker for asynchronous communication between modules.
- **Ansible**: For provisioning and "Day 1" configuration of services (e.g., creating realms and clients in Keycloak, vhosts and users in RabbitMQ).

## Repository Structure

- `docker-compose.yaml`: The main file that defines all services, networks, and volumes.
- `.env/.env.local`: Environment files to separate configurations for Docker execution and local development.
- `ansible/`: Contains the Ansible playbooks and roles for automatic provisioning.
- `pg-init/`: Contains the SQL scripts for "Day 1" initialization of the PostgreSQL databases.
- `pgadmin/`: Configuration for automatically registering servers in pgAdmin on startup.
- `keycloak-jars/`: Contains custom provider JARs for Keycloak (e.g., theme, event listener).

## How to Launch the Environment

All commands must be run from the project's root directory (the meta-repository that contains this and the other two repositories).

**Launch Only the Infrastructure (for Local Development)**
This command starts Keycloak, PostgreSQL, RabbitMQ, and PgAdmin.

```bash
docker-compose -f myreadings_deploy/docker-compose.yaml --profile dev up
```

**Launch the Full Application Stack (Full Demo)**
This command starts the infrastructure, backend, and frontend.

```bash
docker-compose -f myreadings_deploy/docker-compose.yaml --profile dev --profile app up --build
```

After startup, the application will be accessible at the URL defined by the FRONTEND_URL variable (defaults to http://localhost:3000).
