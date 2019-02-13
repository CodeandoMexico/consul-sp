class AddAttachmentIfeToUsers < ActiveRecord::Migration
  def self.up
    change_table :users do |t|
      t.attachment :ife
    end
  end

  def self.down
    remove_attachment :users, :ife
  end
end
