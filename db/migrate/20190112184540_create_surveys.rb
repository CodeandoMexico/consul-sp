class CreateSurveys < ActiveRecord::Migration
  def change
    create_table :surveys do |t|
      t.references :user, index: true, foreign_key: true

      # Survey inputs
      t.date :birth_date
      t.integer :genre # enum genre: [:male, :female, :other]
      t.integer :school_grade # enum school_grade: [:none, :primary, :secundary, :high_school, :university, :postgraduate]
      t.integer :job # enum job: [:profesional, :technician, :teacher, :artist, :official, :farmer, :fixer, :driver, :manager, :administrative, :merchant, :personal_services, :domestic, :guard, :no_specific]
      t.integer :salary # enum salary: [:fourth_less, :fourth_to_nine, :nine_to_twenty, :twenty_to_thirtyfive, :thirtyfive_to_fifty, fifty_to_eighty, more_of_eighty]
      t.integer :recently_vote # enum recently_vote: [:yes, :no, :not_sure]
      t.integer :social_work # enum social_work: [:yes, :no, :not_sure]
      t.integer :attend_event # enum attend_event: [:yes, :no]
      t.integer :participate_last_year # enum participate_last_year: [:yes, :no, :not_sure]
      t.integer :how_discover # enum how_discover: [:news_paper, :promotion, :social_network, :recomendation, :other]
      t.string  :promotion_text
      t.string  :other_text
      t.timestamps null: false
    end

    # add_foreign_key :surveys, :users
  end
end
