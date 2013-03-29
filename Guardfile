# A sample Guardfile
# More info at https://github.com/guard/guard#readme

notification :growl, :sticky => true, :host => 'localhost', :password => 'secret'
# notification :growl_notify, :sticky => true, :priority => 0

guard 'spork',
      :cucumber_env => { 'RAILS_ENV' => 'test' },
      :rspec_env => { 'RAILS_ENV' => 'test' },
      :bundler => false do
  watch('config/application.rb')
  watch('config/environment.rb')
  watch('config/environments/test.rb')
  watch(%r{^config/initializers/.+\.rb$})
  watch('Gemfile')
  watch('Gemfile.lock')
  watch('spec/spec_helper.rb') { :rspec }
  watch(%r{features/support/}) { :cucumber }
end

guard 'rspec', :cli => "--drb", :wait => 60 do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^app/.+\.rb$})       { |m| "spec/#{m[1]}_spec.rb" }
  watch(%r{^lib/(.+)\.rb$})     { |m| "spec/lib/#{m[1]}_spec.rb" }
  # ...
end

guard 'cucumber', :cli => "--drb", :wait => 60 do
  watch(%r{^features/.+\.feature$})
  # ...
end