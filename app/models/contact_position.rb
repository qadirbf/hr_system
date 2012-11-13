class ContactPosition < ActiveRecord::Base
  belongs_to :firm_type

  def self.get_positions(firm_type_id)
    self.all(:conditions=>["firm_type_id=?",firm_type_id],:order=>"id")
  end

  def to_s
    self.name
  end

end
