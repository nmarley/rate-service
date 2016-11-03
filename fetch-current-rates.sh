#! /usr/local/bin/bash

curl https://poloniex.com/public?command=returnTicker | json_pp > polo.json
curl https://api.bitcoinaverage.com/ticker/global/all | json_pp > ba_global_all.json

# BA v2
curl https://apiv2.bitcoinaverage.com/constants/exchangerates/global | json_pp > ba2_global_all.json


