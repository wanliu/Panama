# coding: utf-8

ActiveAdmin.register Unit do
 index do
    column :id
    column :name
    column :code
    column :child_id
    column :percentage
    default_actions
  end 
end