require 'rake/testtask'
# TODO: make a Rakefile that does this for tests:
#
# bundle exec ruby -I./lib -I./test -Iapp/workers ./test/helpers/test_rate_helpers.rb

Rake::TestTask.new do |t|
  t.test_files = FileList['test/**/test_*.rb']
end
desc "Run tests"

task default: :test
