class BackfillElectoralRolesWithoutLocation < ActiveRecord::Migration
  def up
    electoral_roles = ElectoralRoll.where(latitude: nil, longitude: nil)
    electoral_roles.update_all(latitude: 25.6573, longitude: -100.4018)
  end

  def down
  end
end
