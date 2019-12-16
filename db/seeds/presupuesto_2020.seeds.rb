#rake db:seed:single SEED=presupuesto_2020


# Estos son los presupuestos para 2019,
# preguntar por los presupuetos para 2020
# K1: 3861861.19
#
# K2: 5309576.72
#
# K3: 4634594.71
#
# K4: 8599478.89
#
# K5: 4859933.36
#
# K6: 4234555.60

require 'csv'

# el elemento Budget con nombre Presupuesto Participativo 2020 debe
# existir en la base de datos, se puede crear desde
# el admin de la aplicacion
budget = Budget.where(name: "Presupuesto Participativo 2020").first
budget.groups.destroy_all

junta_vecinal =  budget.groups.new

# Budget::Group para Presupuesto Participativo 2020
# en el apartado de las colonias
junta_vecinal.name = 'Juntas Vecinales'
junta_vecinal.save!

# Budget::Group para Presupuesto Participativo 2020
# en el apartado de los sectores
# cada sector incluye varias colonias
sectores = budget.groups.new
sectores.name = 'Sectores'
sectores.save!

### Crear Sectores
puts "Adregar Sector K1"
sectores = Budget::Group.where(name: "Sectores", budget_id: budget.id).first
k1 = sectores.headings.new
k1.name = "K1"
k1.price = 3861861.19 # cambiar por cantidad para 2020
k1.allow_custom_content = true
k1.latitude = Catastral.where(district_code: "K1").first.latitude
k1.longitude = Catastral.where(district_code: "K1").first.longitude
k1.save!
puts "Sector K1 agregado"


puts "Adregar Sector K2"
sectores = Budget::Group.where(name: "Sectores",  budget_id: budget.id).first
k2 = sectores.headings.new
k2.name = "K2"
k2.price = 5309576.72  # cambiar por cantidad para 2020
k2.allow_custom_content = true
k2.latitude = Catastral.where(district_code: "K2").first.latitude
k2.longitude = Catastral.where(district_code: "K2").first.longitude
k2.save!
puts "Sector K2 agregado"

puts "Adregar Sector K3"
sectores = Budget::Group.where(name: "Sectores", budget_id: budget.id).first
k3 = sectores.headings.new
k3.name = "K3"
k3.price = 4634594.71 # cambiar por cantidad para 2020
k3.allow_custom_content = true
k3.latitude = Catastral.where(district_code: "K3").first.latitude
k3.longitude = Catastral.where(district_code: "K3").first.longitude
k3.save!
puts "Sector K3 agregado"

puts "Adregar Sector K4"
sectores = Budget::Group.where(name: "Sectores", budget_id: budget.id).first
k4 = sectores.headings.new
k4.name = "K4"
k4.price = 8599478.89 # cambiar por cantidad para 2020
k4.allow_custom_content = true
k4.latitude = Catastral.where(district_code: "K4").first.latitude
k4.longitude = Catastral.where(district_code: "K4").first.longitude
k4.save!
puts "Sector K4 agregado"

puts "Adregar Sector K5"
sectores = Budget::Group.where(name: "Sectores", budget_id: budget.id).first
k5 = sectores.headings.new
k5.name = "K5"
k5.price = 4859933.36 # cambiar por cantidad para 2020
k5.allow_custom_content = true
k5.latitude = Catastral.where(district_code: "K5").first.latitude
k5.longitude = Catastral.where(district_code: "K5").first.longitude
k5.save!
puts "Sector K5 agregado"

puts "Adregar Sector K6"
sectores = Budget::Group.where(name: "Sectores", budget_id: budget.id).first
k5 = sectores.headings.new
k5.name = "K6"
k5.price = 4234555.60 # cambiar por cantidad para 2020
k5.allow_custom_content = true
k5.latitude = Catastral.where(district_code: "K6").first.latitude
k5.longitude = Catastral.where(district_code: "K6").first.longitude
k5.save!
puts "Sector K6 agregado"





# Obtener sectores
# Optener Juntas Vecinales
# se necesita archivo `junta_vecinal_2020.csv` similar al
# que mandaron para el 2019
puts "================================================"
puts "Crear Juntas Vecinales"
juntas = Budget::Group.where(name: "Juntas Vecinales", budget_id: budget.id).first
CSV.foreach("db/junta_vecinal_2020.csv", headers: true) do |line|
  junta = juntas.headings.new
  junta.name = line["Junta__nom"]
  junta.price = line["Presupuesto"].to_i
  junta.allow_custom_content = true
  region = Colonium.where(junta_nom: line["Junta__nom"]).first
  result = ActiveRecord::Base.connection.execute "select ST_Y(ST_Centroid(the_geom)) AS lat, ST_X(ST_Centroid(the_geom)) AS lon from colonia where id=#{region.id}"
  junta.latitude = result.first["lat"]
  junta.longitude = result.first["lon"]
  junta.save!
end

puts "JUNTAS TERMINADAS!!"
