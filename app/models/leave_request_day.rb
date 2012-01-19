class LeaveRequestDay < ActiveRecord::Base
  include AccountScopedModel

  #
  # each record represents one day of the associated leave request
  #  NOTE: calendars must be intersected so that holidays are dynamically removed
  #

  #scope :current, joins(:leave_request).where(:leave_requests => { :status => LeaveRequest::CURRENT_STATUSES })
  #scope :pending, joins(:leave_request).where(:leave_requests => { :status => LeaveRequest::STATUS_PENDING })

  scope :active, lambda { |country|
    joins(:leave_request)
      .joins(" LEFT JOIN calendar_entries " + 
             "  ON calendar_entries.country_id = #{country.id} AND " + 
             "   leave_request_days.leave_date = calendar_entries.entry_date ")
      .where(:leave_requests => { :status => LeaveRequest::ACTIVE_STATUSES } )
      .where(" calendar_entries.entry_date IS NULL ")
  } 

  #scope :approved, joins(:leave_request).where(:leave_requests => { :status => LeaveRequest::APPROVED_STATUSES })

  belongs_to :leave_request

  validates :leave_request, :existence => true
  validates :leave_date, :timeliness => { :type => :date }, :allow_nil => false
  validates :duration, :numericality => { :greater_than_or_equal => 0 }

  def self.create_for(leave_request)

    # cache variables
    account_id = leave_request.account_id
    leave_request_id = leave_request.id
    date_from = leave_request.date_from
    date_to = leave_request.date_to
    half_day_from = leave_request.half_day_from?
    half_day_to = leave_request.half_day_to?

    # create an entry per half_day
    (date_from..date_to).each do |date|
      LeaveRequestDay.new(
        :account_id => account_id,
        :leave_request_id => leave_request_id,
        :leave_date => date,
        :duration => ((date == date_from) && half_day_from) ||
                     ((date == date_to) && half_day_to) ? 0.5 : 1.0
      ).save!
    end

  end

  def self.update_for(leave_request)
    destroy_for(leave_request)
    create_for(leave_request)
  end

  def self.destroy_for(leave_request)
    LeaveRequestDay.where(:leave_request_id => leave_request.id).destroy_all
  end

end
