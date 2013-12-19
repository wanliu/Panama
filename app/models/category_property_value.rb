class CategoryPropertyValue < ActiveRecord::Base
  include Tire::Model::Search
  include Tire::Model::Callbacks
  include Tire::Model::UpdateByQuery

  attr_accessible :category_property_id, :value

  belongs_to :category_property,
  class_name: "CategoriesProperty", foreign_key: :category_property_id

  validates :value, :presence => true
  validates :category_property, :presence => true

  delegate :category, :to => :category_property
  delegate :property, :to => :category_property

  after_save do
    self.value.strip!
  end

  def to_indexed_json
    {
      :value        => value,
      :created_at  => created_at,
      :updated_at  => updated_at,
      :category    => {
        :id        => category.try(:id),
        :name      => category.try(:name)
      },
      :property => {
        :id => property.id,
        :name => property.name,
        :title => property.title
      }
    }.to_json
  end

end
