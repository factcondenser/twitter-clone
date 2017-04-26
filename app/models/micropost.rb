class Micropost < ApplicationRecord
  belongs_to :user
  # Uses 'stabby lambda' syntax for an object callef a Proc (procedure) or 'lambda' - an anonymous (literally unnamed) function.
  # 'stabby lambda' takes in a block and returns a Proc, which can then be evaluated with the .call method
  default_scope -> { order(created_at: :desc) }
  # Pre Rails 4.0 notation had to use SQL (which is case-insensitive, but still customarily capitalizes its keywords).
  # default_scope -> { order('created_at DESC') }
  validates :user_id, presence: true
  validates :content, presence: true, length: { maximum: 140 }
end
