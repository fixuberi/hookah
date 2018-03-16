desc 'Run all test'
task :run_all_test do

  sh %{ rails test test/integration/*.rb }

end

desc 'Clear generated tobacco'
task :clear_generated_tobacco do

  sh %{ rails test test/integration/clear_generated_tobacco }

end