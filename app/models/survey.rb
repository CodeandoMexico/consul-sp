# frozen_string_literal: true

class Survey < ActiveRecord::Base
  belongs_to :user
  enum genre: %i[male female other]
  enum school_grade: %i[none_grade primary secundary high_school university postgraduate]
  enum job: %i[profesional technician teacher artist official
               farmer fixer driver manager administrative merchant
               personal_services domestic guard no_specific]
  enum salary: %i[fourth_less fourth_to_nine
                  nine_to_twenty twenty_to_thirtyfive thirtyfive_to_fifty fifty_to_eighty more_of_eighty]
  enum recently_vote: %i[yes_vote no_vote not_sure_vote]
  enum social_work: %i[yes_socialwork no_socialwork not_sure_socialwork]
  enum attend_event: %i[yes_attend no_attend]
  enum participate_last_year: %i[yes_participate no_participate not_sure_participate]
  enum how_discover: %i[news_paper promotion social_network recomendation other_medium]


end
