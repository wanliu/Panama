class AppFile
  include ActiveModel::Validations
  include ActiveModel::Conversion

  attr_accessor :name, :data

  def persisted?
    false
  end
end