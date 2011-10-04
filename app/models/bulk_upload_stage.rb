class BulkUploadStage < ActiveRecord::Base

  VALID_FIELDS = %w{      
    reference
    title
    first_name
    middle_name
    last_name
    gender
    email
    telephone
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
  
  belongs_to :employee
  belongs_to :location
  belongs_to :department
  belongs_to :approver, :class_name => 'Employee'
  
  default_values :line_number => 0,
                 :selected => false,
                 :load_sequence => 0

  validates :bulk_upload, :existence => true
  
  validates :line_number, 
            :presence => true, 
            :numericality => { :only_integer => true }

  validates :selected, :inclusion => { :in => [true, false] }
  validates :messages, :presence => true

  validates :load_sequence, 
            :presence => true, 
            :numericality => { :only_integer => true }
  
  def employee_name
    [self.first_name, self.last_name].reject {|n| n.blank? }.join(' ')
  end
  
  #
  # NB: no other fields need to be validated so that the row will *always save!
  #     * well almost always
  #
  
  def validate_for_import()
    model = BulkUploadValidationModel.new().tap do |r|
      r.reference = self.reference
      r.title = self.title
      r.first_name = self.first_name
      r.middle_name = self.middle_name
      r.last_name = self.last_name
      r.gender = self.gender
      r.email = self.email
      r.telephone = self.telephone
      r.telephone_extension = self.telephone_extension
      r.mobile = self.mobile
      r.designation = self.designation
      r.start_date = self.start_date
      r.location_name = self.location_name
      r.department_name = self.department_name
      r.approver_first_and_last_name = self.approver_first_and_last_name
      r.role = self.role.blank? ? 'Employee' : self.role
      r.take_on_balance_as_at = self.take_on_balance_as_at
      r.annual_leave_take_on = self.annual_leave_take_on || 0
      r.educational_leave_take_on = self.educational_leave_take_on || 0
      r.medical_leave_take_on = self.medical_leave_take_on || 0
      r.compassionate_leave_take_on = self.compassionate_leave_take_on || 0
      r.maternity_leave_take_on = self.maternity_leave_take_on || 0
    end
    [model.valid?, model.errors.full_messages]
  end
  
  def build_employee()
    # TODO: build / update the actual employee model
  end

  # Not a real model, but used for the validations!
  class BulkUploadValidationModel
    include Informal::Model
  
    #
    # NOTE: duplicates validation in Employee model
    #
  
    attr_accessor :reference
    validates :reference, :length => { :maximum => 255 }, :allow_nil => true
    
    attr_accessor :title
    validates :title, :allow_blank => true, :length => { :maximum => 20 }
    
    attr_accessor :first_name
    validates :first_name, :presence => true, :length => { :maximum => 100 }
    
    attr_accessor :middle_name
    validates :middle_name, :allow_blank => true, :length => { :maximum => 20 }
    
    attr_accessor :last_name
    validates :last_name, :presence => true, :length => { :maximum => 100 }
    
    attr_accessor :gender
    validates :gender, :presence => true, :inclusion => { :in => ['M', 'F', 'm', 'f'] }
    
    attr_accessor :email
    validates :email, :email => true
    
    attr_accessor :telephone
    validates :telephone, :length => { :maximum => 20 }, :allow_nil => true
    
    attr_accessor :telephone_extension
    validates :telephone_extension, :length => { :maximum => 10 }, :allow_nil => true
    
    attr_accessor :mobile
    validates :mobile, :length => { :maximum => 20 }, :allow_nil => true
    
    attr_accessor :designation
    validates :designation, :allow_blank => true, :length => { :maximum => 255 }
    
    attr_accessor :start_date
    validates :start_date, :timeliness => { :type => :date }

    attr_accessor :location_name
    validates :location_name, :allow_blank => true, :length => { :maximum => 255 }
    
    attr_accessor :department_name
    validates :department_name, :allow_blank => true, :length => { :maximum => 255 }
    
    attr_accessor :approver_first_and_last_name
    validates :approver_first_and_last_name, :allow_blank => true, :length => { :maximum => 220 }
    
    attr_accessor :role
    validates :role, :presence => true, :inclusion => { :in => %w{Employee Approver Manager Admin} }

    attr_accessor :take_on_balance_as_at
    validates :take_on_balance_as_at, :timeliness => { :type => :date }, :allow_nil => true
    
    attr_accessor :annual_leave_take_on
    validates :annual_leave_take_on, :numericality => true, :allow_nil => true
    
    attr_accessor :educational_leave_take_on
    validates :educational_leave_take_on, :numericality => true, :allow_nil => true
    
    attr_accessor :medical_leave_take_on
    validates :medical_leave_take_on, :numericality => true, :allow_nil => true
    
    attr_accessor :compassionate_leave_take_on
    validates :compassionate_leave_take_on, :numericality => true, :allow_nil => true
    
    attr_accessor :maternity_leave_take_on
    validates :maternity_leave_take_on, :numericality => true, :allow_nil => true
  
  end

end
