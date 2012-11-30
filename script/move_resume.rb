#encoding: utf-8
contacts = Contact.where("resume_file is not null")
unless contacts.blank?
  contacts.each do |contact|
    h = {:contact_id => contact.id, :load_path => contact.resume_file}
    unless ContactResume.exists?(h)
      ContactResume.create(h)
    end
  end
end