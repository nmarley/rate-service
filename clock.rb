require 'clockwork'

module Clockwork
  every 1.minute do
    BitcoinAverageWorker.perform_async
    PoloniexWorker.perform_async
  end
end
