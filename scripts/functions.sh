PROJECT_PATH=$(git rev-parse --show-toplevel)
PROJECT="${PROJECT_PATH##*/}"

# Done to prevent silly line length after adding the aws credentials
read -r -d '' BASIC_CMD <<EOT
docker run -v ${HOME}/.aws:/root/.aws -v ${PROJECT_PATH}:/work
$(if [ ${AWS_ACCESS_KEY_ID} ]; then echo '-e AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID}"'; fi)
$(if [ ${AWS_SECRET_ACCESS_KEY} ]; then echo '-e AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY}"'; fi)
$(if [ ${AWS_SESSION_TOKEN} ]; then echo '-e AWS_SESSION_TOKEN="${AWS_SESSION_TOKEN}"'; fi)
-it ${PROJECT}-dev
EOT

function dev-docs {
  $BASIC_CMD -c 'terraform-docs markdown document --output-file README.md ./'
}

function dev-fmt {
  $BASIC_CMD -c 'terraform fmt'
}

function dev-lint {
  $BASIC_CMD -c 'tflint'
}

function dev-start {
  $BASIC_CMD
}

function dev-test {
  $BASIC_CMD -c 'terraform init; terraform test'
}
