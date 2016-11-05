require 'clockwork'
require File.expand_path('config/application', __dir__)

module Clockwork
  every 1.minute, 'workers' do
    BitcoinAverageWorker.perform_async
    PoloniexWorker.perform_async
  end
end
