module CustomMethods
  def get_sectors
    Catastral.where(longitude: nil).each do |catastral|
      catastral.update_column(:longitude, 0)
    end

    Catastral.where(latitude: nil).each do |catastral|
      catastral.update_column(:latitude, 0)
    end
    Catastral.all.each do |catastral|
      point = Geokit::LatLng.new(catastral.latitude, catastral.longitude)
      if SECTOR_K1.contains?(point)
        catastral.update_column(:district_code, "K1")
      elsif SECTOR_K2.contains?(point)
        catastral.update_column(:district_code, "K2")
      elsif SECTOR_K3.contains?(point)
        catastral.update_column(:district_code, "K3")
      elsif SECTOR_K4.contains?(point)
        catastral.update_column(:district_code, "K4")
      elsif SECTOR_K5.contains?(point)
        catastral.update_column(:district_code, "K5")
      elsif SECTOR_K6.contains?(point)
        catastral.update_column(:district_code, "K6")
      else
        catastral.update_column(:district_code, "MANUAL")
      end
    end
  end

  def get_polygon(latitude, longitude)
    point = Geokit::LatLng.new(latitude, longitude)

    if SECTOR_K1.contains?(point)
      return "K1"
    elsif SECTOR_K2.contains?(point)
      return "K2"
    elsif SECTOR_K3.contains?(point)
      return "K3"
    elsif SECTOR_K4.contains?(point)
      return "K4"
    elsif SECTOR_K5.contains?(point)
      return "K5"
    elsif SECTOR_K6.contains?(point)
      return "K6"
    else
      return "MANUAL"
    end
  end
end

# if SECTOR_K1.contains?(point)
#   return "K1"
# elsif SECTOR_K2.contains?(point)
#   return "K2"
# elsif SECTOR_K3.contains?(point)
#   return "K3"
# elsif SECTOR_K4.contains?(point)
#   return "K4"
# elsif SECTOR_K5.contains?(point)
#   return "K5"
# elsif SECTOR_K6.contains?(point)
#   return "K6"
# else
#   return "MANUAL"
# end
