require 'paper_clip_interpolations'

class BulkUpload < ActiveRecord::Base
  include AccountScopedModel

  # status values
  STATUS_PENDING = 0
  STATUS_PROCESSED = 10
  STATUS_FAILED = 20
  STATUSES = [STATUS_PENDING, STATUS_PROCESSED, STATUS_FAILED]

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
  has_attached_file :csv_file, 
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
                    :hash_secret => AppConfig.hash_secret

  def to_s
    "#{self.created_at.strftime('%Y-%m-%d %H:%M')} - #{self.csv_file_file_name}"
  end

end
