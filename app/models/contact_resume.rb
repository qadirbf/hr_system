class ContactResume < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :contact
  belongs_to :employee, :foreign_key => 'upload_by'
end
