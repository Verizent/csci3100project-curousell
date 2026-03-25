class CleanupUnverifiedUserJob < ApplicationJob
  queue_as :default

  def perform(user_id)
    user = User.find_by(id: user_id)
    return unless user
    return if user.verified?

    user.destroy
  end
end
