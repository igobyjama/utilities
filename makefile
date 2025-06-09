ENV_DIR := env

.PHONY: setup go

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
## Remove old go instalallations and re install latest version
go:
	@bash -e -c '\
	  # 1) Remove any old /usr/local/go \
	  echo "→ purging old Go…"; \
	  sudo rm -rf /usr/local/go; \
	  \
	  # 2) Detect OS & ARCH in lowercase form \
	  OS=$$(uname | tr "[:upper:]" "[:lower:]"); \
	  ARCH=$$(uname -m); \
	  case "$$ARCH" in \
	    x86_64) ARCH=amd64 ;; \
	    aarch64) ARCH=arm64 ;; \
	    *) echo "Unsupported ARCH: $$ARCH"; exit 1 ;; \
	  esac; \
	  \
	  # 3) Fetch the latest Go version string, e.g. "go1.21.5" \
	  VERSION=$$(curl -fsSL https://go.dev/VERSION?m=text | head -n1); \
	  \
	  # 4) Build the download URL and extract it \
	  TAR_URL="https://go.dev/dl/$$VERSION.$$OS-$$ARCH.tar.gz"; \
	  echo "Downloading $$TAR_URL"; \
	  curl -fsSL "$$TAR_URL" \
	    | sudo tar -C /usr/local -xz; \
	  \
	  # 5) Ensure your shell’s profile adds /usr/local/go/bin \
	  SHELL_NAME=$$(basename "$$SHELL"); \
	  SHELL_RC="$${HOME}/.$$SHELL_NAME"rc; \
	  grep -qxF 'export PATH=$$PATH:/usr/local/go/bin' "$$SHELL_RC" \
	    || echo 'export PATH=$$PATH:/usr/local/go/bin' >> "$$SHELL_RC"; \
	  \
	  # 6) Show the result \
	  echo "→ Go installed!"; \
	  exec $$SHELL -lc "go version"; \
	'