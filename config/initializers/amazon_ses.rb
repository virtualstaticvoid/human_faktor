ActionMailer::Base.add_delivery_method(
  :ses, 
  AWS::SES::Base,
  :access_key_id => AppConfig.s3_key,
  :secret_access_key => AppConfig.s3_secret
)

