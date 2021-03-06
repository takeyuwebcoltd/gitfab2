# == Schema Information
#
# Table name: cards
#
#  id             :integer          not null, primary key
#  comments_count :integer          default(0), not null
#  description    :text(4294967295)
#  position       :integer          default(0), not null
#  title          :string(255)
#  type           :string(255)      not null
#  created_at     :datetime
#  updated_at     :datetime
#  project_id     :integer
#  state_id       :integer
#
# Indexes
#
#  index_cards_on_state_id  (state_id)
#  index_cards_project_id   (project_id)
#
# Foreign Keys
#
#  fk_cards_project_id  (project_id => projects.id)
#

class Card::NoteCard < Card
  belongs_to :project, counter_cache: :note_cards_count
end
