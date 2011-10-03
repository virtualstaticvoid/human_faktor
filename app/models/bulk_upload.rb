require 'aws/s3'
require 'paper_clip_interpolations'

class BulkUpload < ActiveRecord::Base
  include AccountScopedModel

  after_create :process_upload

  # status values
  STATUS_PENDING = 0
  STATUS_PROCESSING = 20
  STATUS_PROCESSED = 20
  STATUS_FAILED = 30
  STATUSES = [STATUS_PENDING, STATUS_PROCESSING, STATUS_PROCESSED, STATUS_FAILED]

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
    
  scope :pending, where(:status => STATUS_PENDING)
  scope :processed, where(:status => STATUS_PROCESSED)
  scope :failed, where(:status => STATUS_FAILED)

  default_values :status => STATUS_PENDING
  
  has_many :records, :class_name => 'BulkUploadStage', :dependent => :destroy

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
      #'application/excel',
      #'application/vnd.ms-excel',
      #'application/vnd.msexcel',
      'text/anytext',
      'text/plain'
    ]

  def authenticated_url(expires_in = 90.minutes)
    Rails.env.production? ?
      AWS::S3::S3Object.url_for(
        self.csv_file.path, 
        self.csv_file.bucket_name, 
        :expires_in => expires_in, 
        :use_ssl => self.csv_file.s3_protocol == 'https'
      ) :
      self.csv_file.path
  end

  def to_s
    "#{self.created_at.strftime('%Y-%m-%d %H:%M')} - #{self.csv_file.original_filename}"
  end
  
  def set_as_processing()
    self.update_attributes(:status => STATUS_PROCESSING, :error_messages => nil)
  end

  def set_as_processed()
    self.update_attributes(:status => STATUS_PROCESSED, :error_messages => nil)
  end

  def set_as_failed(error_message)
    self.update_attributes(:status => STATUS_FAILED, :error_messages => error_message)
  end
  
  private
  
  def process_upload
    WorkQueue.enqueue(Tenant::ProcessBulkUpload, self.id)
  end

end
