
guard :livereload do
  watch(%r{^app/.+\.(erb|haml)})
  watch(%r{^app/helpers/.+\.rb})
  watch(%r{^public/.+\.(css|js|html)})
  watch(%r{^config/locales/.+\.yml})
end

guard :test do

  # configuration files
  watch('.rvmrc')                                    { "test" }
  watch('Gemfile')                                   { "test" }
  watch('Gemfile.lock')                              { "test" }
  watch('config.yml')                                { "test" }
  watch('environment.yml')                           { "test" }

  # lib files
  watch(%r{^lib/(.+)\.rb$})                          { |m| "test/#{m[1]}_test.rb" }
  watch(%r{^test/.+_test\.rb$})
  watch('test/test_helper.rb')                       { "test" }

  # rails files
  watch(%r{^app/models/(.+)\.rb$})                   { |m| "test/unit/#{m[1]}_test.rb" }
  #watch(%r{^app/helpers/(.+)\.rb$})                 { |m| "test/unit/helpers/#{m[1]}_test.rb" }
  #watch(%r{^app/validators/(.+)\.rb$})              { |m| "test/unit/#{m[1]}_test.rb" }
  watch(%r{^app/controllers/(.+)\.rb$})              { |m| "test/functional/#{m[1]}_test.rb" }
  watch(%r{^app/views/.+\.rb$})                      { "test/integration" }
  watch(%r{^app/workers/.+\.rb$})                    { "test/integration" }
  watch('app/controllers/application_controller.rb') { ["test/functional", "test/integration"] }
  
end

