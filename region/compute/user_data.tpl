#!/bin/bash
sudo hostnamectl set-hostname ${hostname}
sudo apt-get update && sudo apt-get install ncat unzip libpq-dev libc++1 python3-venv python3-pip -y
sudo pip3 install prometheus-client
sudo curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
sudo unzip awscliv2.zip
sudo ./aws/install
sudo DEBIAN_FRONTEND=noninteractive apt-get install iptables-persistent -y 
sudo iptables --new-chain RATE-LIMIT
sudo iptables --append RATE-LIMIT --match hashlimit --hashlimit-mode srcip --hashlimit-upto 50/sec --hashlimit-burst 20 --hashlimit-name conn_rate_limit --jump ACCEPT
sudo iptables --append RATE-LIMIT --match limit --limit 1/sec --jump LOG --log-prefix "IPTables-Rejected: "
sudo iptables --append RATE-LIMIT --jump REJECT
sudo chmod a+rwx /etc/iptables/rules.v4
sudo iptables-save > /etc/iptables/rules.v4
#DD_AGENT_MAJOR_VERSION=7 DD_API_KEY=${dd_api_key} DD_SITE="${dd_site}" bash -c "$(curl -L https://s3.amazonaws.com/dd-agent/scripts/install_script.sh)"
DIGITALBITS_CORE_VERSION=$(curl -s "https://api.github.com/repos/xdbfoundation/DigitalBits/releases?per_page=50" | jq -r '[.[] | select(.name | contains("beta") | not) | .name][0]')
DIGITALBITS_PROMETHEUS_VERSION=$(curl -s "https://api.github.com/repos/xdbfoundation/digitalbits-core-prometheus-exporter/releases?per_page=50" | jq -r '[.[] | select(.name | contains("beta") | not) | .name][0]')
curl -Lo digitalbits-core.deb "https://github.com/xdbfoundation/DigitalBits/releases/download/${DIGITALBITS_CORE_VERSION}/digitalbits-core_${DIGITALBITS_CORE_VERSION}_amd64.deb"
curl -Lo digitalbits-core-prometheus-exporter.deb "https://github.com/xdbfoundation/digitalbits-core-prometheus-exporter/releases/download/${DIGITALBITS_PROMETHEUS_VERSION}/digitalbits-core-prometheus-exporter_${DIGITALBITS_PROMETHEUS_VERSION}_amd64.deb"
sudo dpkg -i digitalbits-core.deb
sudo dpkg -i digitalbits-core-prometheus-exporter.deb
sudo sed -i 's/testnet/livenet/g' /etc/datadog-agent/conf.d/prometheus.d/conf.yaml
cat << EOF > /etc/digitalbits.cfg
LOG_FILE_PATH="/var/log/digitalbits-core.log"
BUCKET_DIR_PATH="/var/history/buckets"
RUN_STANDALONE=false
UNSAFE_QUORUM=false
FAILURE_SAFETY=1
CATCHUP_COMPLETE=true
NODE_HOME_DOMAIN="${domain_name}"
NODE_SEED="${node.secret_seed} self"
NODE_IS_VALIDATOR=true
DATABASE="postgresql://dbname=${db_name} user=${db_username} password=${db_password} host=${db_address}"
HTTP_PORT=11626
PUBLIC_HTTP_PORT=true
NETWORK_PASSPHRASE="${network_passphare}"
FEE_PASSPHRASE="${fee_passphrase}"
PEER_PORT=11625
KNOWN_CURSORS=["FRONTIER"]

[[HOME_DOMAINS]]
HOME_DOMAIN="${domain_name}"
QUALITY="MEDIUM"

%{ for viso, values in validators }
#[[VALIDATORS]]
#NAME="${viso}"
#HOME_DOMAIN="${domain_name}"
#PUBLIC_KEY="${values.public}"
#ADDRESS="${viso}-1.${domain_name}"
#HISTORY="${values.history_get}"
%{ endfor ~}

[HISTORY.local]
get="${node.history_get}"
put="${node.history_put}"

[[HOME_DOMAINS]]
HOME_DOMAIN = "livenet.digitalbits.io"
QUALITY = "HIGH"

[[VALIDATORS]]
NAME = "DigitalBits Germany"
PUBLIC_KEY = "GDKMIZ6AJQVGYIKFNXLL6DR3J2V252ZVNIKMX5R4MCN4A567ESURCRZJ"
ADDRESS = "3.64.96.173:11625"
HISTORY = "curl -sf https://history.livenet.digitalbits.io/deu-1/{0} -o {1}"
HOME_DOMAIN = "livenet.digitalbits.io"

[[VALIDATORS]]
NAME = "DigitalBits Great Britain"
PUBLIC_KEY = "GDS25FEPPK5LK5BVWGEPLFCQQV7DQOXS6ERYWHDQIKZU3YGO5NRODIAT"
ADDRESS = "35.177.74.117:11625"
HISTORY = "curl -sf https://history.livenet.digitalbits.io/gbr-1/{0} -o {1}"
HOME_DOMAIN = "livenet.digitalbits.io"

[[VALIDATORS]]
NAME = "DigitalBits France"
PUBLIC_KEY = "GBDWWMQKFO3WBTSZ74F64LNXETXBD7VYQT6MIXFVIBHLM57HIR7LYKI2"
ADDRESS = "35.181.0.80:11625"
HISTORY = "curl -sf https://history.livenet.digitalbits.io/fra-1/{0} -o {1}"
HOME_DOMAIN = "livenet.digitalbits.io"

[[VALIDATORS]]
NAME="sgp-1"
HOME_DOMAIN="livenet.digitalbits.io"
PUBLIC_KEY="GAH63EU4HJANIP3W6UNCJ2YKOYRZQJHYWQBKZGXVZK6UFNQ4SULCKWLC"
ADDRESS="sgp-1.livenet.digitalbits.io"
HISTORY="curl -sf https://history.livenet.digitalbits.io/sgp-1/{0} -o {1}"

[[VALIDATORS]]
NAME="irl-1"
HOME_DOMAIN="livenet.digitalbits.io"
PUBLIC_KEY="GAD3IYRUDJN7AVE4VUUQQO74AWFKLEFKB5BFUNOFM6KA4WH5G23GUQ7W"
ADDRESS="irl-1.livenet.digitalbits.io"
HISTORY="curl -sf https://history.livenet.digitalbits.io/irl-1/{0} -o {1}"

[[HOME_DOMAINS]]
HOME_DOMAIN = "livenet.zytara.com"
QUALITY = "HIGH"

[[VALIDATORS]]
NAME = "Zytara Ireland"
PUBLIC_KEY = "GDNJGMQCWXN2DAPIR5NBJS775LIKYSSY35S2CSRHLDFE7NCSQNWZ2KIZ"
ADDRESS = "54.195.58.142:11625"
HISTORY = "curl -sf https://history.livenet.zytara.com/livenet/irl/{0} -o {1}"
HOME_DOMAIN = "livenet.zytara.com"

[[VALIDATORS]]
NAME = "Zytara Australia"
PUBLIC_KEY = "GB6IPEJ2NV3AKWK6OXZWPOJQ4HGRSB2ULMWBESZ5MUY6OSBUDGJOSPKD"
ADDRESS = "52.63.51.186:11625"
HISTORY = "curl -sf https://history.livenet.zytara.com/livenet/aus/{0} -o {1}"
HOME_DOMAIN = "livenet.zytara.com"

[[VALIDATORS]]
NAME = "Zytara Singapore"
PUBLIC_KEY = "GB4UPA2VRNJGE7EWPKCE4EQRXVOFPCVBERMXCA3ZOFJU3JU7COA7HIWG"
ADDRESS = "13.251.98.56:11625"
HISTORY = "curl -sf https://history.livenet.zytara.com/livenet/sgp/{0} -o {1}"
HOME_DOMAIN = "livenet.zytara.com"

[[VALIDATORS]]
NAME = "Zytara Brazil"
PUBLIC_KEY = "GBKW3R3APTMYSCZDRYNG6CCAEHDW4UNLEQQHTHL7UEFFJAWTSJOWH5Q7"
ADDRESS = "54.232.68.234:11625"
HISTORY = "curl -sf https://history.livenet.zytara.com/livenet/bra/{0} -o {1}"
HOME_DOMAIN = "livenet.zytara.com"

[[VALIDATORS]]
NAME = "Zytara Sweden"
PUBLIC_KEY = "GBF7CE3PPXKAWVZ255FDO5ZKEHZDBRW7SBDKBHSQZDQ3E5TRSKUSBKGT"
ADDRESS = "13.49.180.62:11625"
HISTORY = "curl -sf https://history.livenet.zytara.com/livenet/swe/{0} -o {1}"
HOME_DOMAIN = "livenet.zytara.com"

[[VALIDATORS]]
NAME = "Zytara Canada"
PUBLIC_KEY = "GAWKRGXGM7PPZMQGUH2ATXUKMKZ5DTJHDV7UK7P4OHHA2BKSF3ZUEVWT"
ADDRESS = "3.97.5.252:11625"
HISTORY = "curl -sf https://history.livenet.zytara.com/livenet/can/{0} -o {1}"
HOME_DOMAIN = "livenet.zytara.com"

[[VALIDATORS]]
NAME = "Zytara Germany"
PUBLIC_KEY = "GAKPT7BFXX224DJ7KB7V22LTJ6WH4SRQSJ3VLW324FIVFB2P6VW2OF76"
ADDRESS = "35.157.33.78:11625"
HISTORY = "curl -sf https://history.livenet.zytara.com/livenet/deu/{0} -o {1}"
HOME_DOMAIN = "livenet.zytara.com"


[[HOME_DOMAINS]]
HOME_DOMAIN="digitalbits.stably.io"
QUALITY="HIGH"

[[VALIDATORS]]
NAME="stably-use1"
HOME_DOMAIN="digitalbits.stably.io"
ADDRESS="use1-1.digitalbits.stably.io"
PUBLIC_KEY="GDF2PZ6TQON6V6BBV5QUQ77LNQU6EZNG7XDJ6BZQFANMVEI7KUKFQJCI"
HISTORY="curl -sf https://history.digitalbits.stably.io/livenet/us-east-1/{0} -o {1}"

[[VALIDATORS]]
NAME="stably-use2"
HOME_DOMAIN="digitalbits.stably.io"
PUBLIC_KEY="GAJAEHVWS2VVXHJEV5JLJMVUER3UKCOOCM6FQE3AU7P7W5QFIH5RQUHV"
ADDRESS="use2-1.digitalbits.stably.io"
HISTORY="curl -sf https://history.digitalbits.stably.io/livenet/us-east-2/{0} -o {1}"

[[VALIDATORS]]
NAME="stably-usw1"
HOME_DOMAIN="digitalbits.stably.io"
ADDRESS="usw1-1.digitalbits.stably.io"
PUBLIC_KEY="GCKGIKHN3ABZBSA3HVVBLO7DBWHD6UYZ3CRY4SAGQVGWEZ5E6VP6OT2U"
HISTORY="curl -sf https://history.digitalbits.stably.io/livenet/us-west-1/{0} -o {1}"

[[VALIDATORS]]
NAME="stably-usw2"
HOME_DOMAIN="digitalbits.stably.io"
ADDRESS="usw2-1.digitalbits.stably.io"
PUBLIC_KEY="GD5M33AQCGCFCVQCJAIZQFGUHBBUQQVD52HX3ISBPWQSMTAMKRJ2CTX3"
HISTORY="curl -sf https://history.digitalbits.stably.io/livenet/us-west-2/{0} -o {1}"

EOF

# --- commands to start new digitalbits node
sudo digitalbits-core --conf /etc/digitalbits.cfg new-db
sudo digitalbits-core --conf /etc/digitalbits.cfg new-hist local
sudo systemctl enable --now digitalbits-core

#sudo systemctl enable --now digitalbits-core-prometheus-exporter
#sudo systemctl enable --now datadog-agent