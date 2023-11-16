class RegenerateBackgroundWorker
  include Sidekiq::Worker

  def perform(list_id)
    list = List.find(list_id)
    list.regenerate_background if list
  end
end
