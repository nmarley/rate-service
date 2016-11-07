#! /usr/local/bin/bash

# to fetch new/updated test data:
curl https://poloniex.com/public?command=returnTicker | json_pp > polo.json
curl https://apiv2.bitcoinaverage.com/constants/exchangerates/global | json_pp > ba2_global_all.json


