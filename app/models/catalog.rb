class Catalog < ActiveRecord::Base
    attr_accessible :title
    validates_uniqueness_of :title
    validates_presence_of :title
    has_and_belongs_to_many :categories
end
