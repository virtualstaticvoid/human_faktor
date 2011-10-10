class BulkUploadStage < ActiveRecord::Base

  default_scope order(:bulk_upload_id, :line_number)
  
  scope :selected, where(:selected => true)
  scope :with_errors, where(:selected => false)

  VALID_FIELDS = %w{      
    reference
    title
    first_name
    middle_name
    last_name
    gender
    email
    telephone
    telephone_extension
    mobile
    designation
    start_date
    location_name
    department_name
    approver_first_and_last_name
    role
    take_on_balance_as_at
    annual_leave_take_on
    educational_leave_take_on
    medical_leave_take_on
    compassionate_leave_take_on
    maternity_leave_take_on
  }.freeze
    
  belongs_to :bulk_upload

  # resolved references  
  belongs_to :location
  belongs_to :department
  
  belongs_to :approver, :class_name => 'Employee'               # existing approver
  belongs_to :new_approver, :class_name => 'BulkUploadStage'    # references a bulk upload record
  
  belongs_to :employee
  
  default_values :line_number => 0,
                 :selected => false,
                 :load_sequence => 0

  validates :bulk_upload, :existence => true
  
  validates :line_number, 
            :presence => true, 
            :numericality => { :only_integer => true }

  validates :selected, :inclusion => { :in => [true, false] }

  validates :load_sequence, 
            :presence => true, 
            :numericality => { :only_integer => true }

  # validations not run when saved... used for validation during staging

  validates :reference, :length => { :maximum => 255 }, :allow_nil => true
  validates :title, :allow_blank => true, :length => { :maximum => 20 }

  validates :first_name, 
            :presence => true, 
            :length => { :maximum => 100 }, 
            :uniqueness => { :scope => [:bulk_upload_id, :last_name] }
  
  validates :middle_name, :allow_blank => true, :length => { :maximum => 20 }

  validates :last_name, 
            :presence => true, 
            :length => { :maximum => 100 }, 
            :uniqueness => { :scope => [:bulk_upload_id, :first_name] }

  def user_name
    @user_name ||= [self.first_name, self.last_name].reject {|n| n.blank? }.join('.').downcase
  end

  validates :user_name, :unique_user_name_for_bulk_upload => true
  
  validates :email, 
            :allow_blank => true, 
            :email => true,
            :uniqueness => { :scope => [:bulk_upload_id, :email] },
            :unique_email_for_bulk_upload => true
  
  validates :gender, :presence => true, :inclusion => { :in => ['M', 'F', 'm', 'f'] }

  validates :telephone, :length => { :maximum => 20 }, :allow_nil => true
  validates :telephone_extension, :length => { :maximum => 10 }, :allow_nil => true
  validates :mobile, :length => { :maximum => 20 }, :allow_nil => true

  validates :designation, :allow_blank => true, :length => { :maximum => 255 }
  validates :start_date, :timeliness => { :type => :date }
  validates :location_name, :allow_blank => true, :length => { :maximum => 255 }
  validates :department_name, :allow_blank => true, :length => { :maximum => 255 }
  validates :approver_first_and_last_name, :allow_blank => true, :length => { :maximum => 220 }
  validates :role, :presence => true, :inclusion => { :in => %w{employee approver manager admin} }

  validates :take_on_balance_as_at, :allow_blank => true, :timeliness => { :type => :date }
  validate :validate_take_on_balance_as_at
   
  validates :annual_leave_take_on, :allow_blank => true, :numericality => true
  validates :educational_leave_take_on, :allow_blank => true, :numericality => true
  validates :medical_leave_take_on, :allow_blank => true, :numericality => true
  validates :compassionate_leave_take_on, :allow_blank => true, :numericality => true
  validates :maternity_leave_take_on, :allow_blank => true, :numericality => true
  
  def employee_name
    @employee_name ||= [self.first_name, self.last_name].reject {|n| n.blank? }.join(' ')
  end
  
  def approver_name
    @approver_name ||= self.approver.nil? ? self.new_approver.employee_name : self.approver.full_name
  end
  
  def location_name_downcased
    self.location_name.downcase unless self.location_name.blank?
  end

  def department_name_downcased
    self.department_name.downcase unless self.department_name.blank?
  end
  
  def approver_first_and_last_name_downcased
    self.approver_first_and_last_name.downcase unless self.approver_first_and_last_name.blank?
  end
  
  def increment_load_sequence
    self.update_attributes(:load_sequence => self.load_sequence + 1)
  end

  private 
  
  def validate_take_on_balance_as_at
    # take_on_balance_as_at is required if there are take on balance amounts
    self.errors[:take_on_balance_as_at] << 'is required' if take_on_balances? && self.take_on_balance_as_at.nil?
  end 
  
  def take_on_balances?
    [
      :annual_leave_take_on, 
      :educational_leave_take_on, 
      :medical_leave_take_on, 
      :compassionate_leave_take_on, 
      :maternity_leave_take_on
    ].reject {|take_on_for|
      self.send(take_on_for).nil? || self.send(take_on_for) == 0
    }.length > 0
  end
  
end
