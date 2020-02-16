# vault-cp - Copy data from HashiCorp Vault KV stores

The Bash script located in this repository can be used to copy data from one
[HashiCorp Vault](https://vaultproject.io/) KV store.

It can be used to copy a given path inside a KV store to a new path or to put
data into an entirely different store. It can also be used to copy data from
one Vault instance to another.

## Prerequisites

- Bash shell
- [Vault CLI](oncourse.iplabs.de)
- [jq](https://stedolan.github.io/jq/)

## Examples

### Copy recursively from one KV store to another

Copy all data under `some_path` recursively from `secret1` to `secret2` using
the default Vault instance as specified by the environment variable `VAULT_ADDR`.

```bash
./vault-cp secret1 secret2 some_path
```

### Copy recursively from one Vault instance to another

Copy all data under `some_path` recursively from `secret` to `secret`.
The source Vault instance will be specified by the environment variable `VAULT_SOURCE_ADDR`,
whereas the target instance will be specified by the environment variable `VAULT_TARGET_ADDR`.

```bash
VAULT_SOURCE_ADDR="https://my-vault1.example.com/" \
VAULT_TARGET_ADDR="https://my-vault2.example.com/" \
./vault-cp secret secret some_path
```
