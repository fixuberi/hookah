require 'rake/testtask'

desc 'Run all test'
task :run_all_test do
  sh %{ rails test test/integration/*.rb }
end

desc 'Clear generated tobacco'
task :clear_generated_tobacco do
  sh %{ rails test test/integration/clear_generated_tobacco }
end

Rake::TestTask.new do |t|
  t.name = 'test_suite'
  t.libs << 'test'
  t.deps = FileList['test/helpers/*.rb']
  t.test_files = FileList['test/integration/*.rb']
  t.verbose = true
end