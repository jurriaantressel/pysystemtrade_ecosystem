#!/bin/bash

vault login $VAULT_TOKEN

export BARCHART_USER_ID=$(vault kv get -field=USER_ID altakleos/data-providers/barchart/makutaku)
export BARCHART_PASSWORD=$(vault kv get -field=PASSWORD altakleos/data-providers/barchart/makutaku)
export TWS_USER_ID=$(vault kv get -field=USER_ID altakleos/brokers/ibkr/paper)

export TWS_PASSWORD=$(vault kv get -field=PASSWORD altakleos/brokers/ibkr/paper)
echo $TWS_PASSWORD

