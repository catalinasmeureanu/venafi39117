export VAULT_ADDR='http://127.0.0.1:8200'

vault operator init -recovery-shares=1 -recovery-threshold=1 > key.txt

sleep 10

RootToken=`grep 'Initial Root Token:' key.txt | awk '{print $NF}'`

echo "$RootToken"

vault status

vault login "$RootToken"

SHA256=$(sha256sum /etc/vault/plugins/venafi-pki-monitor |cut -d' ' -f1)

vault policy write admin admin.hcl

vault policy list

vault token create -policy="admin" \
    -format=json | jq -r ".auth.client_token" > token.txt

vault login $(cat token.txt)

# vault write sys/plugins/catalog/secret/venafi-pki-monitor \
  #  sha_256="${SHA256}" command="venafi-pki-monitor" 

vault plugin register -sha256=$SHA256 venafi-pki-monitor

vault secrets enable -path=pki -plugin-name=venafi-pki-monitor plugin

vault secrets disable venafi-pki-monitor

vault secrets list 
