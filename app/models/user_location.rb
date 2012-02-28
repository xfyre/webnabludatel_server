# encoding: utf-8

class UserLocation < ActiveRecord::Base
  belongs_to :user
  belongs_to :commission

  has_many :photos, class_name: "UserLocationPhoto", dependent: :destroy, order: :timestamp
  has_many :sos_messages, dependent: :nullify
  has_many :watcher_reports, dependent: :destroy, order: :timestamp

  STATUSES = %W(pending approved rejected suspicious waiting_for_data)

  validates :status, inclusion: { in: STATUSES }
  validates :user, presence: true
  validates :commission, presence: true

  STATUSES.each do |status|
    class_eval <<-EOF
    scope :#{status}, where(status: :#{status})

    EOF
  end

  after_initialize :set_default_status
  after_save :update_watcher_reports

  attr_accessible :latitude, :longitude

  def status
    ActiveSupport::StringInquirer.new("#{read_attribute(:status)}")
  end

  def watcher_reports
    @watcher_reports ||= self.user.watcher_reports.where(comission_id: self.comission)
  end

  private
    def set_default_status
      self.status = "pending" if self.status.blank?
    end

    def update_watcher_reports
      return unless self.status_changed?

      if self.status == "approved"
        self.watcher_reports.each{|r| r.save! }
      elsif self.status == "rejected"
        self.watcher_reports.update_all(status: "rejected")
      elsif self.status == "suspicious"
        self.watcher_reports.update_all(status: "location_suspicious")
      end
    end
end
