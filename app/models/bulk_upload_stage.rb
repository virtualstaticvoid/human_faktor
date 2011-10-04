class BulkUploadStage < ActiveRecord::Base

  belongs_to :bulk_upload
  
  default_values :line_number => 0,
                 :selected => false

  validates :bulk_upload, :existence => true
  
  validates :line_number, 
            :presence => true, 
            :numericality => { :only_integer => true }

  validates :selected, :inclusion => { :in => [true, false] }
  validates :messages, :presence => true
  
  #
  # NB: no other fields need to be validated
  #
  
  #  validates :reference
  #  validates :title
  #  validates :first_name
  #  validates :middle_name
  #  validates :last_name
  #  validates :gender
  #  validates :email
  #  validates :telephone
  #  validates :mobile
  #  validates :designation
  #  validates :start_date
  #  validates :location_name
  #  validates :department_name
  #  validates :approver_first_and_last_name
  #  validates :role
  #  validates :take_on_balance_as_at
  #  validates :annual_leave_take_on
  #  validates :educational_leave_take_on
  #  validates :medical_leave_take_on
  #  validates :compassionate_leave_take_on
  #  validates :maternity_leave_take_on
  
  def validated?
    # TODO: validate the row
    true
  end

end
