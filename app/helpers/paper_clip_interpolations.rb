module Paperclip
  module Interpolations

    def rails_root(attachment, style_name)
      File.join(Rails.root, 'public', 'system')
    end

    def identifier(attachment, style_name)
      attachment.instance.identifier
    end

    def account(attachment, style_name)
      attachment.instance.account.to_param
    end

    def employee(attachment, style_name)
      attachment.instance.employee.to_param
    end

  end
end

