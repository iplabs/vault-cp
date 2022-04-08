export VAULT_SKIP_VERIFY=true
vault_addr_source=https://vaultyyyyyyy:8200
vault_token_source=yyyyyyyyyyy

vault_addr_target=https://vaultxxxxxxx:8200
vault_token_target=xxxxxxxxxxxx

vault_ns_source=yyyyyyyy
vault_ns_target=xxxxxxxx

kv_list=$(VAULT_ADDR=$vault_addr_source VAULT_TOKEN=$vault_token_source vault secrets list -namespace=$vault_ns_source | grep kv | cut -d " " -f 1)

for kv_eng in $kv_list
do
    secret_path_list=$(VAULT_ADDR=$vault_addr_source VAULT_TOKEN=$vault_token_source vault kv list -namespace=$vault_ns_source $kv_eng | tail -n +3)
    VAULT_ADDR=$vault_addr_target VAULT_TOKEN=$vault_token_target VAULT_NAMESPACE=$vault_ns_target vault secrets enable -path=$kv_eng kv-v2
    for sec_path in $secret_path_list
    do
        VAULT_ADDR=$vault_addr_source VAULT_TOKEN=$vault_token_source vault kv get -format=json -namespace=$vault_ns_source $kv_eng$sec_path | jq -r '.data.data' > tmp
        VAULT_ADDR=$vault_addr_target VAULT_TOKEN=$vault_token_target vault kv put -namespace=$vault_ns_target $kv_eng$sec_path @tmp
    done
done
rm tmp
