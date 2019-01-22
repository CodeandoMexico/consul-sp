class Catastral < ActiveRecord::Base
  geocoded_by :full_address
  after_validation :geocode

  def full_address
    "#{ubic} #{numextubi}, #{colubi}, San Pedro Garza García"
  end
end
