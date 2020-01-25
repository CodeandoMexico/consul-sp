file = File.open("db/election_roll_san_pedro.txt")

file.readlines.map(&:chomp).each do |line|
  attr_hash = line.split("|")

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
end

puts "Electoral Rolls created!"
