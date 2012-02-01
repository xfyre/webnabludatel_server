class WatcherLog < ActiveRecord::Base
  belongs_to :user
  belongs_to :comission
  belongs_to :device_message

  attr_accessible :key, :value, :recorted_at
end