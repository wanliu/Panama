require 'spec_helper'

describe City do

  it { have_one :address }
end
