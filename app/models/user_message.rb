class UserMessage < ActiveRecord::Base
  belongs_to :user
  has_many :device_messages
  has_many :media_items

  belongs_to :user_location
  belongs_to :watcher_report

  after_save :process

  private
    def process
      Delayed::Job.enqueue AnalyzeUserMessageJob.new(self.id)
    end

end
