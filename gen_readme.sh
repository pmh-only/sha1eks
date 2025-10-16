#!/bin/bash
REGION=(
  us-east-1
  us-east-2
  us-west-1
  us-west-2
  ap-south-1
  ap-northeast-1
  ap-northeast-2
  ap-northeast-3
  ap-southeast-1
  ap-southeast-2
  ca-central-1
  eu-central-1
  eu-west-1
  eu-west-2
  eu-west-3
  eu-north-1
  sa-east-1
)

RESULT='
| `region` | `SHA1SUM_OF_TLS_CERTIFICATE` |
|:--------:|:-----------------------------|'

for region in "${REGION[@]}"; do
  OIDC_HOST="oidc.eks.$region.amazonaws.com"

  SHA1=$(echo \
    | openssl s_client -servername $OIDC_HOST -showcerts -connect $OIDC_HOST:443 2>/dev/null \
    | awk '/BEGIN CERTIFICATE/,/END CERTIFICATE/{print}' \
    | openssl x509 -fingerprint -sha1 -noout \
    | awk -F= '{gsub(":",""); print tolower($2)}')

  RESULT="$RESULT
| \`${region}\` | \`${SHA1}\` |"
done

OUTPUT="$(awk '/<!-- REPLACE HERE -->/{print;print content;f=1;next}
/<!-- REPLACE HERE END -->/{f=0} !f' content="$RESULT" README.md)"

echo "$OUTPUT" > README.md
