###########################################
###########################################
## Dockerfile to run GitHub Super-Linter ##
###########################################
###########################################

#########################################
# Get dependency images as build stages #
#########################################
FROM borkdude/clj-kondo:2020.06.21 as clj-kondo
FROM dotenvlinter/dotenv-linter:2.1.0 as dotenv-linter
FROM mstruebing/editorconfig-checker:2.1.0 as editorconfig-checker
FROM golangci/golangci-lint:v1.29.0 as golangci-lint
FROM yoheimuta/protolint:v0.25.1 as protolint
FROM koalaman/shellcheck:v0.7.1 as shellcheck
FROM wata727/tflint:0.18.0 as tflint

##################
# Get base image #
##################
FROM python:latest

#########################################
# Label the instance and set maintainer #
#########################################
LABEL com.github.actions.name="GitHub Super-Linter" \
      com.github.actions.description="Lint your code base with GitHub Actions" \
      com.github.actions.icon="code" \
      com.github.actions.color="red" \
      maintainer="GitHub DevOps <github_devops@github.com>"

####################
# Run installs #
####################
RUN apt-get update && apt-get install -y \
    bash \
    curl \
    build-essential \
    git \
    nodejs \
    python3-setuptools \
    jq \
    pylint

########################################
# Copy dependencies files to container #
########################################
COPY dependencies/* /

################################
# Installs python dependencies #
################################
RUN pip3 install --no-cache-dir pipenv
RUN pipenv install --system

######################
# Install shellcheck #
######################
COPY --from=shellcheck /bin/shellcheck /usr/bin/

###########################################
# Load GitHub Env Vars for GitHub Actions #
###########################################
ENV ACTIONS_RUNNER_DEBUG=${ACTIONS_RUNNER_DEBUG} \
    ANSIBLE_DIRECTORY=${ANSIBLE_DIRECTORY} \
    DEFAULT_BRANCH=${DEFAULT_BRANCH} \
    DISABLE_ERRORS=${DISABLE_ERRORS} \
    GITHUB_EVENT_PATH=${GITHUB_EVENT_PATH} \
    GITHUB_SHA=${GITHUB_SHA} \
    GITHUB_TOKEN=${GITHUB_TOKEN} \
    GITHUB_WORKSPACE=${GITHUB_WORKSPACE} \
    LINTER_RULES_PATH=${LINTER_RULES_PATH} \
    OUTPUT_DETAILS=${OUTPUT_DETAILS} \
    OUTPUT_FOLDER=${OUTPUT_FOLDER} \
    OUTPUT_FORMAT=${OUTPUT_FORMAT} \
    RUN_LOCAL=${RUN_LOCAL} \
    TEST_CASE_RUN=${TEST_CASE_RUN} \
    VALIDATE_ALL_CODEBASE=${VALIDATE_ALL_CODEBASE} \
    VALIDATE_ANSIBLE=${VALIDATE_ANSIBLE} \
    VALIDATE_ARM=${VALIDATE_ARM} \
    VALIDATE_BASH=${VALIDATE_BASH} \
    VALIDATE_CLOJURE=${VALIDATE_CLOJURE} \
    VALIDATE_COFFEE=${VALIDATE_COFFEE} \
    VALIDATE_CSS=${VALIDATE_CSS} \
    VALIDATE_DART=${VALIDATE_DART} \
    VALIDATE_DOCKER=${VALIDATE_DOCKER} \
    VALIDATE_EDITORCONFIG=${VALIDATE_EDITORCONFIG} \
    VALIDATE_ENV=${VALIDATE_ENV} \
    VALIDATE_GO=${VALIDATE_GO} \
    VALIDATE_HTML=${VALIDATE_HTML} \
    VALIDATE_JAVASCRIPT_ES=${VALIDATE_JAVASCRIPT_ES} \
    VALIDATE_JAVASCRIPT_STANDARD=${VALIDATE_JAVASCRIPT_STANDARD} \
    VALIDATE_JSON=${VALIDATE_JSON} \
    VALIDATE_KOTLIN=${VALIDATE_KOTLIN} \
    VALIDATE_MD=${VALIDATE_MD} \
    VALIDATE_OPENAPI=${VALIDATE_OPENAPI} \
    VALIDATE_PERL=${VALIDATE_PERL} \
    VALIDATE_PHP=${VALIDATE_PHP} \
    VALIDATE_POWERSHELL=${VALIDATE_POWERSHELL} \
    VALIDATE_PROTOBUF=${VALIDATE_PROTOBUF} \
    VALIDATE_PYTHON=${VALIDATE_PYTHON} \
    VALIDATE_RAKU=${VALIDATE_RAKU} \
    VALIDATE_RUBY=${VALIDATE_RUBY} \
    VALIDATE_STATES=${VALIDATE_STATES} \
    VALIDATE_TERRAFORM=${VALIDATE_TERRAFORM} \
    VALIDATE_TYPESCRIPT_ES=${VALIDATE_TYPESCRIPT_ES} \
    VALIDATE_TYPESCRIPT_STANDARD=${VALIDATE_TYPESCRIPT_STANDARD} \
    VALIDATE_XML=${VALIDATE_XML} \
    VALIDATE_YAML=${VALIDATE_YAML}

#############################
# Copy scripts to container #
#############################
COPY lib /action/lib

##################################
# Copy linter rules to container #
##################################
COPY TEMPLATES /action/lib/.automation

######################
# Set the entrypoint #
######################
ENTRYPOINT ["/action/lib/linter.sh"]
