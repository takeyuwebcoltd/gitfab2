# == Schema Information
#
# Table name: memberships
#
#  id         :integer          not null, primary key
#  role       :string(255)      default("editor")
#  created_at :datetime
#  updated_at :datetime
#  group_id   :integer
#  user_id    :integer
#
# Indexes
#
#  index_users_on_group_id_user_id  (group_id,user_id) UNIQUE
#

class Membership < ApplicationRecord
  ROLE = { admin: 'admin', editor: 'editor' }

  belongs_to :user
  belongs_to :group

  after_destroy -> { group.soft_destroy! }, if: -> { group.members.none? }
  validates :role, presence: true, inclusion: { in: ROLE.values }

  Membership::ROLE.keys.each do |role|
    define_method "#{role}?" do
      Membership::ROLE[role] == self.role
    end
  end

  def deletable?
    (admin? && group.admins.count > 1) || editor?
  end
end
