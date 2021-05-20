VERSION="2.0.0"

NETWORK_PASSPHRASE="LiveNet Global DigitalBits Network ; February 2021"
FRONTIER_URL="https://frontier.livenet.digitalbits.io/"
ACCOUNTS=${accounts}

[DOCUMENTATION]
ORG_NAME="${org_name}"
ORG_URL="https://${domain_name}"

%{ for iso, key in keys }
[[VALIDATORS]]
ALIAS="${org_name_lc}-${iso}"
DISPLAY_NAME="${key.display_name}"
HOST="${iso}-1.${domain_name}:11625"
PUBLIC_KEY="${key.public}"
HISTORY="${key.history}"
%{ endfor ~}