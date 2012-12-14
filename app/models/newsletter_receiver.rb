class NewsletterReceiver
  include Mongoid::Document
  field :email, type: String

end
