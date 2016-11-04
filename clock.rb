require 'clockwork'
# /Users/nmarley/Dash/code/rate-service/app/workers
$:.push('lib')
$:.push('app/workers')
require 'bitcoin_average_worker'
require 'poloniex_worker'

module Clockwork
  every 1.minute, 'workers' do
    BitcoinAverageWorker.perform_async
    PoloniexWorker.perform_async
  end
end
