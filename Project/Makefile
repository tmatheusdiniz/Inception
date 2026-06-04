#                                    COLORS                                    #
# ============================================================================ #
#

RED     = \033[0;31m
GREEN   = \033[0;32m
YELLOW  = \033[0;33m
BLUE    = \033[0;34m
CYAN    = \033[0;36m
RESET   = \033[0m

#                                  VARIABLES                                   #
# ============================================================================ #
#

NAME        = inception
LOGIN       = mreinald
DATA_PATH   = /home/$(LOGIN)/data
COMPOSE     = docker compose -f ./srcs/docker-compose.yml --env-file ./srcs/.env

#                                   RULES                                      #
# ============================================================================ #
#

.PHONY: all setup data up uplog down stop start restart clean fclean re status logs

all: setup up

## Setup: create data dirs and configure /etc/hosts
setup: data
	@echo "$(BLUE)Setting up environment...$(RESET)"
	@if ! grep -q "$(LOGIN).42.fr" /etc/hosts; then \
		echo "127.0.0.1 $(LOGIN).42.fr" | sudo tee -a /etc/hosts > /dev/null; \
		echo "$(GREEN)Domain $(LOGIN).42.fr added to /etc/hosts$(RESET)"; \
	else \
		echo "$(YELLOW)Domain $(LOGIN).42.fr already in /etc/hosts$(RESET)"; \
	fi

## Create host volume directories
data:
	@echo "$(BLUE)Creating data directories...$(RESET)"
	@mkdir -p $(DATA_PATH)/wordpress
	@mkdir -p $(DATA_PATH)/mariadb
	@echo "$(GREEN)Volume directories ready$(RESET)"

## Build and start all containers (detached)
up:
	@echo "$(GREEN)Building and starting containers...$(RESET)"
	@$(COMPOSE) up -d --build
	@echo "$(GREEN)All containers are up!$(RESET)"

## Build and start with live logs (foreground)
uplog:
	@echo "$(GREEN)Building and starting containers (with logs)...$(RESET)"
	@$(COMPOSE) up --build

## Stop and remove containers, networks
down:
	@echo "$(YELLOW)Bringing down containers...$(RESET)"
	@$(COMPOSE) down
	@echo "$(YELLOW)Containers removed$(RESET)"

## Stop containers without removing them
stop:
	@echo "$(YELLOW)Stopping containers...$(RESET)"
	@$(COMPOSE) stop
	@echo "$(YELLOW)Containers stopped$(RESET)"

## Start already-built containers
start:
	@echo "$(GREEN)Starting existing containers...$(RESET)"
	@$(COMPOSE) start
	@echo "$(GREEN)Containers started$(RESET)"

## Restart containers
restart:
	@echo "$(YELLOW)Restarting containers...$(RESET)"
	@$(COMPOSE) restart
	@echo "$(GREEN)Containers restarted$(RESET)"

## Show container status
status:
	@echo "$(BLUE)Container status:$(RESET)"
	@docker ps -a

## Tail logs for all services
logs:
	@$(COMPOSE) logs -f

## Remove containers, images, and volumes (keep host data)
clean:
	@echo "$(RED)Removing containers, images and volumes...$(RESET)"
	@$(COMPOSE) down --rmi all --volumes --remove-orphans
	@echo "$(RED)Docker artefacts removed$(RESET)"

## Full clean: also wipe host data directories
fclean: clean
	@echo "$(RED)Wiping host data directories...$(RESET)"
	@sudo rm -rf $(DATA_PATH)/wordpress $(DATA_PATH)/mariadb
	@echo "$(RED)Host data wiped$(RESET)"

## Rebuild everything from scratch
re: fclean all
