class FirmType < ActiveRecord::Base
  has_many :contact_positions

  def to_s
    self.name
  end

end
