#!/bin/bash

tmpfile=$(mktemp /tmp/vault-json-data.XXXXXXXXXX) || { echo "Failed to create temp file"; exit 1; }

FOLDER_RE='^.*/$'

VAULT_SOURCE_ADDR="${VAULT_SOURCE_ADDR:-${VAULT_ADDR:-""}}"
VAULT_TARGET_ADDR="${VAULT_TARGET_ADDR:-${VAULT_ADDR:-""}}"

# Arguments:
# $1: source_store
# $2: target_store
# $3: path
function copy_recursive() {
	local source_store="${1}"
	local target_store="${2}"
	local source_base_path="${source_store}${3}"
	local target_base_path="${target_store}${3}"

	local entries=($(vault kv list -format=json "${source_base_path}" | jq -r '.[]'))
	for entry in "${entries[@]}"; do
		local source_full_path="${source_base_path}${entry}"
		echo -n "Processing entry ${source_full_path} ... "
		if [[ "${entry}" =~ ${FOLDER_RE} ]]; then
			copy_recursive "${1}" "${2}" "${3}${entry}"
		else
			local target_full_path="${target_base_path}${entry}"
			echo "${source_store}${source_full_path} -> ${target_store}${source_full_path}"
			VAULT_ADDR="${VAULT_SOURCE_ADDR}" vault kv get -format=json "${source_full_path}" | jq -r '.data.data' > "${tmpfile}"
			VAULT_ADDR="${VAULT_TARGET_ADDR}" vault kv put "${target_full_path}" @"${tmpfile}"
		fi
	done
}

copy_recursive $@

if [[ -f "${tmpfile}" ]]; then
	rm -f "${tmpfile}" || echo "Unable to delete tmpfile (${tmpfile}). Manual clean up necessary."
fi
