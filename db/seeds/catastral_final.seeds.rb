#rake db:seed:single SEED=my_custom_seed

require 'csv'

Catastral.destroy_all

CSV.foreach("db/catastral.csv", headers: true) do |line|
  Catastral.create! line.to_hash
end
