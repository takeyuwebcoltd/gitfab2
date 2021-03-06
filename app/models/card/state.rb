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

class Card::State < Card
  belongs_to :project, counter_cache: :states_count
  acts_as_list scope: [:project_id, type: Card::State.name]

  has_many :annotations, ->{ order(:position) },
                        class_name: 'Card::Annotation',
                        foreign_key: :state_id,
                        dependent: :destroy,
                        inverse_of: :state
  accepts_nested_attributes_for :annotations

  scope :ordered_by_position, -> { order(:position) }

  class << self
    def updatable_columns
      super + [:position, annotations_attributes: Card::Annotation.updatable_columns]
    end
  end

  def to_annotation!(parent_state)
    transaction do
      update!(type: Card::Annotation.name, state_id: parent_state.id)
      project.decrement!(:states_count)
    end
    Card::Annotation.find(id)
  end

  def dup_document
    super.tap do |doc|
      doc.annotations = annotations.map(&:dup_document)
    end
  end
end

