require 'aws/s3'
require 'paper_clip_interpolations'

class BulkUpload < ActiveRecord::Base
  include AccountScopedModel

  # status values
  STATUS_PENDING = 0
  STATUS_CHECKED = 10
  STATUS_ACCEPTED = 20
  STATUS_PROCESSING = 30
  STATUS_PROCESSED = 40
  STATUS_FAILED = 50
  STATUSES = [STATUS_PENDING, STATUS_CHECKED, STATUS_ACCEPTED, STATUS_PROCESSING, STATUS_PROCESSED, STATUS_FAILED]

  @@statuses = []
  @@status_names = {}

  self.constants.each do |constant|
    next unless constant =~ /^STATUS_/
    
    constant_value = self.const_get(constant)
    @@statuses << constant_value
    @@status_names[constant_value] = constant.to_s.gsub(/STATUS_/, '').capitalize
    
    define_method "#{constant.downcase}?" do
      self.status == constant_value
    end
    
  end

  belongs_to :uploaded_by, :class_name => 'Employee'
  has_many :records, :class_name => 'BulkUploadStage', :dependent => :destroy
    
  default_values :status => STATUS_PENDING
  
  accepts_nested_attributes_for :records

  validates :uploaded_by, :existence => true

  validates :status, 
            :presence => true, 
            :numericality => { :only_integer => true, :in => @@statuses }

  def status_text
    @@status_names[self.status]
  end

  validates :comment, :length => { :maximum => 255 }, :allow_nil => true

  # avatar for employee
  # NOTE: uses the ":account" interpolation
  # TODO: add validations for mime-type and file size
  has_attached_file :csv, 
                    :url => Rails.env.production? ? 
                              "accounts/:account/bulk_uploads/:hash.:extension" :
                              "/system/accounts/:account/bulk_uploads/:hash.:extension",
                    :path => Rails.env.production? ? 
                              "accounts/:account/bulk_uploads/:hash.:extension" :
                              ":rails_root/accounts/:account/bulk_uploads/:hash.:extension",
                    :storage => Rails.env.production? ? :s3 : :filesystem,
                    :bucket => AppConfig.s3_bucket,
                    :s3_credentials => {
                      :access_key_id => AppConfig.s3_key,
                      :secret_access_key => AppConfig.s3_secret
                    },
                    :s3_permissions => :private,    # NB!
                    :hash_secret => AppConfig.hash_secret

  validates_attachment_presence :csv
  
  validates_attachment_content_type :csv,
    :content_type => [
      'text/csv',
      'text/comma-separated-values',
      'text/csv',
      'application/csv',
      'text/anytext',
      'text/plain'
    ]

  def authenticated_url(expires_in = 90.minutes)
    Rails.env.production? ?
      AWS::S3::S3Object.url_for(
        self.csv.path, 
        self.csv.bucket_name, 
        :expires_in => expires_in, 
        :use_ssl => self.csv.s3_protocol == 'https'
      ) :
      self.csv.path
  end

  def to_s
    "#{self.created_at.strftime('%Y-%m-%d %H:%M')} - #{self.csv.original_filename}"
  end
  
  def set_as_checked()
    self.update_attributes(:status => STATUS_CHECKED, :messages => 'Successfully staged bulk upload.')
  end

  def set_as_accepted(attributes)
    self.update_attributes(
      attributes.merge({
        'status' => STATUS_CHECKED, 
        'messages' => 'Ready for import.'
      })
    )
  end

  def set_as_processing()
    self.update_attributes(:status => STATUS_PROCESSING, :messages => nil)
  end

  def set_as_processed(messages = nil)
    self.update_attributes(:status => STATUS_PROCESSED, :messages => messages)
  end

  def set_as_failed(messages)
    self.update_attributes(:status => STATUS_FAILED, :messages => messages)
  end

end
