# docker.sh
#
# Docker Compose helper functions for the ComputerLine development stack.
# Provides shared checks for service image availability, running container
# status, and starting/rebuilding individual Compose services.
#
# Requires DOCKER_COMPOSE_YML to be initialized by project validation before use.

load_defined_services() {
  local compose_output=""

  # Reset the global list
  DEFINED_SERVICES=()

  if ! compose_output="$(docker compose -f "$DOCKER_COMPOSE_YML" config --services 2>&1)"; then
    log_error "Unable to load services from $(highlight "docker-compose.yml")"
    log_error "  $compose_output"
    SUMMARY+=("$(error "Unable to read Docker Compose services.")")
    return 1
  fi

  # Create array of services defined in YML; store to global variable DEFINED_SERVICES
  mapfile -t DEFINED_SERVICES <<< "$compose_output"
}

service_image_built() {
  local service="$1"

  # Determine if the service already has a cached image available
  if [[ -n "$(docker compose -f "$DOCKER_COMPOSE_YML" images -q "$service" 2>/dev/null)"  ]]; then
    return 0
  else
    return 1
  fi
}

service_running() {
  local service="$1"
  local container_id

  # Extract the container ID for this service from the Compose config
  container_id="$(docker compose -f "$DOCKER_COMPOSE_YML" ps -q "$service")"

  if [[ -n "$container_id" ]] && [[ "$(docker inspect -f '{{.State.Running}}' "$container_id" 2>/dev/null)" == true ]]; then
    return 0
  else
    return 1
  fi
}

start_service() {
  local service="$1"
  local build="$2"
  local exit_code=0
  local output=""

  # Start the Docker services in detached (-d) mode. Terminate if an error occurred
  if output="$(docker compose -f "$DOCKER_COMPOSE_YML" up "$service" -d ${build:+ --build} 2>&1)"; then
    log_success "OK"
    return 0
  else
    exit_code=$?
    log_error "Unable to start service: $output"

    return "$exit_code"
  fi
}

open_service_shell() {
  local service_name="$1"

  local exit_code

  docker compose -f "$DOCKER_COMPOSE_YML" exec -it "$service_name" bash
  exit_code="$?"

  if [[ "$exit_code" -ne 0 ]]; then
    log_error "Failed to launch shell! (Exit Code: $exit_code)"
    wait_continue
    return 1
  fi

}