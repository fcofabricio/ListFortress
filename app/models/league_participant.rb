class LeagueParticipant < ApplicationRecord
  belongs_to :user, optional: true
  
end
