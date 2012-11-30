class ContactResume < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :contact
end
