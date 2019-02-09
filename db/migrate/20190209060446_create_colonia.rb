class CreateColonia < ActiveRecord::Migration
  def change
    create_table :colonia do |t|
      t.string :junta_nom
      t.string :nombre_12
      t.string :sector
      t.string :telefono
      t.string :tipo_1
      t.string :forma_de_c
      t.string :distrito
      t.string :direccion
      t.string :correo_ele
      t.string :clave
      t.string :celular
      t.string :apellidos
      t.multi_polygon :the_geom, :srid => 0

      t.timestamps null: false
    end

    add_index :colonia, :the_geom,  using: :gist
  end
end
