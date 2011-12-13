
guard :livereload do
  watch(%r{^app/.+\.(erb|haml)})
  watch(%r{^app/helpers/.+\.rb})
  watch(%r{^public/.+\.(css|js|html)})
  watch(%r{^config/locales/.+\.yml})
end

guard :test do

  watch('.rvmrc')                     { "test" }
  watch('Gemfile')                    { "test" }
  watch('Gemfile.lock')               { "test" }
  
  # configuration files
  watch('config/config.yml')          { "test" }
  watch('config/secrets.yml')         { "test" }
  watch('config/environment.yml')     { "test" }

  # lib files
  watch(%r{^lib/(.+)\.rb$})                          { |m| "test/#{m[1]}_test.rb" }
  watch(%r{^test/.+_test\.rb$})
  watch('test/test_helper.rb')                       { "test" }

  # rails files
  watch(%r{^app/models/(.+)\.rb$})                   { |m| "test/unit/#{m[1]}_test.rb" }
  watch(%r{^app/helpers/(.+)\.rb$})                  { |m| "test/unit/helpers/#{m[1]}_test.rb" }
  watch(%r{^app/validators/(.+)\.rb$})               { |m| "test/unit/#{m[1]}_test.rb" }
  watch(%r{^app/controllers/(.+)\.rb$})              { |m| "test/functional/#{m[1]}_test.rb" }
  watch(%r{^app/views/.+\.rb$})                      { "test/integration" }
  watch(%r{^app/workers/.+\.rb$})                    { "test/integration" }
  watch('app/controllers/application_controller.rb') { ["test/functional", "test/integration"] }
  
end

guard :rspec, :version => 2 do

  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^lib/(.+)\.rb$})     { |m| "spec/lib/#{m[1]}_spec.rb" }
  watch('spec/spec_helper.rb')  { "spec" }

  # Rails example
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^app/(.+)\.rb$})                           { |m| "spec/#{m[1]}_spec.rb" }
  watch(%r{^app/(.*)(\.erb|\.haml)$})                 { |m| "spec/#{m[1]}#{m[2]}_spec.rb" }
  watch(%r{^lib/(.+)\.rb$})                           { |m| "spec/lib/#{m[1]}_spec.rb" }
  watch(%r{^app/controllers/(.+)_(controller)\.rb$})  { |m| ["spec/routing/#{m[1]}_routing_spec.rb", "spec/#{m[2]}s/#{m[1]}_#{m[2]}_spec.rb", "spec/acceptance/#{m[1]}_spec.rb"] }
  watch(%r{^spec/support/(.+)\.rb$})                  { "spec" }
  watch('spec/spec_helper.rb')                        { "spec" }
  watch('config/routes.rb')                           { "spec/routing" }
  watch('app/controllers/application_controller.rb')  { "spec/controllers" }

  # Capybara request specs
  watch(%r{^app/views/(.+)/.*\.(erb|haml)$})          { |m| "spec/requests/#{m[1]}_spec.rb" }

end