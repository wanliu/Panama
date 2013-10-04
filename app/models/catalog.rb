class Catalog < ActiveRecord::Base
    attr_accessible :title
    validates_uniqueness_of :title
    validates_presence_of :title
    has_and_belongs_to_many :categories

    def category_ids
    	ids = []
    	categories.each do |c|
    		ids |= c.subtree_ids
    	end
    	ids
    end
end
