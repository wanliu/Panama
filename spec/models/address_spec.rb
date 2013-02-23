require 'spec_helper'

describe Address do

  it { should belong_to :transaction }

  it { should belong_to :user }
  it { should belong_to :province }
  it { should belong_to :city }
  it { should belong_to :area }
  it { should belong_to :addressable }


  def location
    "#{country}#{province}#{city}#{area}#{road}"
  end




  it { validate_presence_of :province_id }


  # FEATURES: please make a validate_superior_of match
  # it { validate_superior_of :city }
  # it { validate_superior_of :area }
end
