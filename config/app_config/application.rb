# Put your common configuration settings (for all environments) here.

# application settings
AppConfig.product_group = "Human Faktor"
AppConfig.title = "Human Faktor Online Leave Management"
AppConfig.meta_keywords = ""
AppConfig.meta_description = ""

AppConfig.company_name = "FaktorWorks Pty (Ltd)"
AppConfig.company_registration_number = "M2011/007679/07"

AppConfig.subdomain = ENV['SUB_DOMAIN'] || "www"
AppConfig.domain = "human-faktor.com"
AppConfig.scheme = "http"

# mail server settings
AppConfig.smtp_server = ENV['SMTP_SERVER']
AppConfig.smtp_domain = ENV['SMTP_DOMAIN'] || AppConfig.domain
AppConfig.smtp_port = ENV['SMTP_PORT'] || 25
AppConfig.smtp_user_name = ENV['SMTP_USERNAME']
AppConfig.smtp_password = ENV['SMTP_PASSWORD']

# email addresses
AppConfig.info_email = "info@#{AppConfig.domain}"
AppConfig.support_email = "support@#{AppConfig.domain}"
AppConfig.no_reply_email = "noreply@#{AppConfig.domain}"

# amazon S3 credentials
AppConfig.s3_bucket = ENV['S3_BUCKET'] || "#{AppConfig.subdomain}.#{AppConfig.domain}".gsub(/\./, '_')
AppConfig.s3_key = ENV['S3_KEY']
AppConfig.s3_secret = ENV['S3_SECRET']

# themes
AppConfig.default_theme = 'default'

# defaults
AppConfig.default_country_iso_code = ENV['DEFAULT_COUNTRY_ISO_CODE'] || 'za'

# hash secret for hashing filenames
AppConfig.hash_secret = 'e5a308a4c7a74480ef81ffd9aa7e288c1860e10b6dda45a5a92d45168bd211299fc88b066c35785b596b7420f4e6cb062ff6c9315f18f9bff872dda011500970'

