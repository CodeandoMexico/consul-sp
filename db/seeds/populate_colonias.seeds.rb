#rake db:seed:single SEED=populate_colonias
require 'rgeo/shapefile'
require 'rgeo/geo_json'

puts "Borrando las juntas previas"

Colonium.delete_all
file = File.open("./db/shapefiles/juntax.geojson")
data = JSON.parse(file.read)
features = data['features']
features.each do |colonia|
  meta_geo = RGeo::GeoJSON.decode(colonia)
  junta = Colonium.new
  junta.the_geom = meta_geo.geometry
  junta.junta_nom = colonia['properties']['junta__nom']
  junta.nombre_12 = colonia['properties']['nombre_12']
  junta.sector = colonia['properties']['sector']
  junta.telefono = colonia['properties']['telefono']
  junta.tipo_1 = colonia['properties']['tipo_1']
  junta.forma_de_c = colonia['properties']['forma_de_c']
  junta.distrito = colonia['properties']['distrito']
  junta.direccion = colonia['properties']['direccion']
  junta.correo_ele = colonia['properties']['correo_ele']
  junta.clave = colonia['properties']['clave']
  junta.celular = colonia['properties']['celular']
  junta.apellidos = colonia['properties']['apellidos']
  junta.save!
  puts "SE GUARDO ESTA MADRE"
  # meta_geo.geometry
  #meta_geo.properties['CLAVE']
end

#query bueno
# Colonium.where("ST_DWithin(the_geom, 'POINT(-100.355096 25.664440)',0.0000621371)").first.junta_nom
