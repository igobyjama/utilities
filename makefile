ENV_DIR := env

.PHONY: setup

setup:
	@bash -c '\
		set -o allexport; \
		# build the path to your env file: \
		ENV_FILE="$(ENV_DIR)/$@.env"; \
		# proper test syntax (spaces around the ]): \
		[ -f "$$ENV_FILE" ] || { \
		  echo "Env file not found: $$ENV_FILE"; \
		  exit 1; \
		}; \
		# load and export variables \
		source "$$ENV_FILE"; \
		set +o allexport; \
		\
		# install PACKAGES \
		echo "Installing: $$PACKAGES"; \
		sudo dnf install $$PACKAGES -y; \
		# example extra tool \
		pip install ansible; \
		\
		# configure git user \
		git config --global user.email "$$UEMAIL"; \
		git config --global user.name  "$$UNAME" \
	'
