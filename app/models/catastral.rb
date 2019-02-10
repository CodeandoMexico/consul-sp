class Catastral < ActiveRecord::Base
  geocoded_by :full_address
  after_validation :geocode

  validate :registers_exceded

  def full_address
    "#{ubic} #{numextubi}, #{colubi}, San Pedro Garza García"
  end

  def registers_exceded
    if self.registers > 4
      self.errors.add(:registers, "No pueden existir mas de 4 registros con este numero")
    end
  end
end
