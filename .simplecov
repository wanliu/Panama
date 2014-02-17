# .simplecov
SimpleCov.start 'rails' do
  add_filter "/app/models/mongodb/"
  # any custom configs like groups and filters can be here at a central place
end