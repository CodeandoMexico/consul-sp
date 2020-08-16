file = File.open("db/election_roll_san_pedro.txt")
coordinates = File.read("db/centroides_manzanas_converted.geojson")
data = JSON.parse(coordinates)["features"]["features"]

ElectoralRoll.all.each(&:destroy)
file.readlines.map(&:chomp).each do |line|
  begin
    attr_hash = line.scrub.split("|")
    ElectoralRoll.create(
      entity: attr_hash[0],
      constituency_id: attr_hash[1],
      municipality_id: attr_hash[2],
      electoral_section_id: attr_hash[3],
      locality_id: attr_hash[4],
      block_id: attr_hash[5],
      ocr_number: attr_hash[6],
      cic_number: attr_hash[7],
      credential_issuance_number: attr_hash[8],
      municipality_name: attr_hash[9],
      sex: attr_hash[10],
      year_of_registry: attr_hash[11],
      paternal_last_name_initial: attr_hash[12],
      maternal_last_name_initial: attr_hash[13],
      name_initial: attr_hash[14],
    )
  rescue StandardError
    puts "Something went wrong creating electoral Rolls"
  end
end

ElectoralRoll.all.each do |record|
  begin
    location_entry = data.find do |entry| 
      entry["properties"]["MANZANA"] == record.block_id &&
        entry["properties"]["SECCION"] == record.electoral_section_id
    end

    record.update(
      latitude: location_entry["geometry"]["coordinates"].first,
      longitude: location_entry["geometry"]["coordinates"].last
    )
  rescue StandardError => e
    puts record.cic_number
  end
end

puts "Electoral Rolls created!"
