#!/usr/bin/env bash
[[ ! ${WARDEN_DIR} ]] && >&2 echo -e "\033[31mThis script is not intended to be run directly!\033[0m" && exit 1
set -euo pipefail

function :: {
  echo
  echo "==> [$(date +%H:%M:%S)] $@"
}

## load configuration needed for setup
WARDEN_ENV_PATH="$(locateEnvPath)" || exit $?
loadEnvConfig "${WARDEN_ENV_PATH}" || exit $?
assertDockerRunning

## load version from as it won't be loaded by loadEnvConfig
eval "$(grep "^MAGENTO_VERSION" "${WARDEN_ENV_PATH}/.env")"

## change into the project directory
cd "${WARDEN_ENV_PATH}"

## configure command defaults
AUTO_PULL=1

## increase the docker-compose timeout since it can take some time to create the
## container volume due to the size of sample data copied into the volume on start
export COMPOSE_HTTP_TIMEOUT=180

## argument parsing
## parse arguments
while (( "$#" )); do
    case "$1" in
        --no-pull)
            AUTO_PULL=
            shift
            ;;
        *)
            error "Unrecognized argument '$1'"
            exit -1
            ;;
    esac
done

:: Verifying configuration
INIT_ERROR=

## verify warden version constraint
WARDEN_VERSION=$(warden version 2>/dev/null) || true
WARDEN_REQUIRE=0.6.0
if ! test $(version ${WARDEN_VERSION}) -ge $(version ${WARDEN_REQUIRE}); then
  error "Warden ${WARDEN_REQUIRE} or greater is required (version ${WARDEN_VERSION} is installed)"
  INIT_ERROR=1
fi

## exit script if there are any missing dependencies or configuration files
[[ ${INIT_ERROR} ]] && exit 1

:: Starting Warden
warden svc up
if [[ ! -f ~/.warden/ssl/certs/${TRAEFIK_DOMAIN}.crt.pem ]]; then
    warden sign-certificate ${TRAEFIK_DOMAIN}
fi

:: Initializing environment
if [[ $AUTO_PULL ]]; then
  warden env pull --ignore-pull-failures || true
  warden env build --pull
else
  warden env build
fi
warden env up -d

## wait for postgres to start listening for connections
warden shell -c "while ! nc -z db 5432 </dev/null; do sleep 2; done"
