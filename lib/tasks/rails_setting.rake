# coding: utf-8
namespace :setting do
  desc "load global settings data"
  task :load => :environment do
    Setting.delete_all
    settings = [ 
      { var: 'Focus', value: '{ start_time: 1, end_time: 8 }' },
      { var: 'Auction', value: '{ start_time: 1, end_time: 8 }' }
    ]

    settings.each do |setting| 
      Setting.create(setting) 
    end
  end
end