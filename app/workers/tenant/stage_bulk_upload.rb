require 'open-uri'
require 'aws/s3'
require 'csv'
require 'action_view/helpers/text_helper'

module Tenant
  class StageBulkUpload < Struct.new(:upload_id)
    include ActionView::Helpers::TextHelper
  
    def perform()
      log "Staging bulk upload"
      
      @bulk_upload = BulkUpload.find(self.upload_id)
      @account = @bulk_upload.account

      start_staging() && 
          stage_upload() && 
            validate_upload() && 
              complete_staging()
      
      log "Staged #{pluralize(@bulk_upload.records.count(), 'employee')}."
      true
        
    rescue Exception => error
    
      # any errors will be raised here which fail the bulk upload
      # reload to clear any validation errors
      @bulk_upload.reload
    
      # log out the full error message
      log error.message
      log error.backtrace.join("\n")

      # store the failure message
      fail_upload(error)

      false
    end
    
    private
    
    def start_staging()
      log "Started staging bulk upload."
      @bulk_upload.set_as_staging
    end

    def stage_upload()
      log "Staging bulk upload."
    
      # import the file as is into the bulk upload stage model

      line_number = 1
      options = { 
        :headers => :first_row, 
        :return_headers => true,
        :skip_blanks => true
      }
      
      # copy the file locally
      temp_file = Tempfile.new('bulk_upload.csv')
      
      File.open(temp_file.path, 'w') do |file|        
        open(@bulk_upload.authenticated_url(90.minutes, :server_side => true)) {|data| 
          log "Reading data from file storage"
          bytes = file.write(data.read)
          log "Done reading file (#{bytes} bytes)"
        }
      end

      ActiveRecord::Base.transaction do
      
        # ensure initial state (when retrying)
        @bulk_upload.records.clear
        
        # open as CSV and process each row
        CSV.foreach(temp_file.path, options) do |row|
        
          # skip if the row is empty or nil
          next unless row || row.fields.reject {|v| v.nil? || v.blank? }.empty?
                  
          if row.header_row?

            # verify header
            unless (row.fields - BulkUploadStage::VALID_FIELDS).empty?
              raise Exception.new("Invalid file header. The following unknown columns found:\n#{(row.fields - BulkUploadStage::VALID_FIELDS)}.\nAborting bulk upload!")
            end
          
          else
          
            bulk_upload_row = @bulk_upload.records.build(row.to_hash).tap {|row|
              row.line_number = line_number
              row.role = row.role.blank? ? 'employee' : row.role.downcase
            }
            
            # save without validation, so it *always* suceeds
            bulk_upload_row.save(:validate => false)
          
          end
          
          line_number += 1
                  
        end
        
        @bulk_upload.save(:validate => false)
      end

    ensure
      # close the temp file, this automatically deletes it
      temp_file.close!
    end

    def validate_upload()
      log "Validating bulk upload."
    
      # load defaults
      default_location = @account.location
      default_department = @account.department
      default_approver = @bulk_upload.uploaded_by
      
      # load lookups
      employees = load_employees_lookup
      locations = load_locations_lookup
      departments = load_departments_lookup
      approvers = load_approvers_lookup
      new_approvers = to_lookup(@bulk_upload.records) {|item| item.employee_name }

      # check each row
      for record in @bulk_upload.records
        
        # working variables
        existing_employee = nil
        location = nil
        department = nil
        approver = nil
        new_approver = nil

        # validate the current record
        record_valid = record.valid?
        validation_messages = record_valid ? nil : record.errors.full_messages
    
        # resolve for foreign key values (location, department, approver)
  
        existing_employee = employees[record.user_name]
        location = locations[record.location_name_downcased] || default_location
        department = departments[record.department_name_downcased] || default_department
        
        # resolve for approver, first in existing employees, 
        #  then in the bulk upload, otherwise use the default
        approver = approvers[record.approver_first_and_last_name_downcased]
        new_approver = approver.nil? ? new_approvers[record.approver_first_and_last_name_downcased] : nil
        approver = new_approver.nil? ? default_approver : nil
        
        record.update_attributes(
          :location => location,
          :department => department,
          :employee => existing_employee,            
          :approver => approver,
          :new_approver => new_approver,
          :selected => record_valid,
          :messages => validation_messages
        )

        # NB: save without validation
        record.save!(:validate => false)
        
        # push this employee up the load order
        new_approver.increment_load_sequence() unless new_approver.nil?
        
      end
      
    end
    
    def load_employees_lookup
      to_lookup(@account.employees) {|item| item.full_name }
    end
    
    def load_locations_lookup
      to_lookup(@account.locations) {|item| item.title }
    end

    def load_departments_lookup
      to_lookup(@account.departments) {|item| item.title }
    end
    
    def load_approvers_lookup
      to_lookup(@account.employees.active_approvers) {|item| item.full_name }
    end
    
    def to_lookup(items, &block)
      items.inject({}) {|list, item| 
        list[yield(item).downcase] = item
        list 
      }
    end

    def complete_staging()
      log "Completed staging bulk upload."
      @bulk_upload.set_as_staged()
    end

    def fail_upload(error)
      log "Failed to stage bulk upload."
      @bulk_upload.set_as_failed(
        Rails.env.production? ? 
          error.message :
          "#{error.message}\n#{error.backtrace.join("\n")}"
      )
    end

    private

    def log(message)
      puts "#{self.upload_id}: #{message}" if Rails.env.development?
      logger.info "#{self.upload_id}: #{message}"
    end

    def logger
      @logger ||= if defined?(Rails)
        Rails.logger
      elsif defined?(RAILS_DEFAULT_LOGGER)
        RAILS_DEFAULT_LOGGER
      else
        Logger.new(STDOUT)
      end
    end

  end
end

