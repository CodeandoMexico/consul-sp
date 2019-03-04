class AdditionalImage < ActiveRecord::Base
  belongs_to :budget_investment
  has_attached_file :photo, :styles => { :large => "800x800>", :medium => "500x500>"}, :default_url => "/images/:style/missing.png"
  validates_attachment_content_type :photo, content_type: /\Aimage\/.*\Z/
end
