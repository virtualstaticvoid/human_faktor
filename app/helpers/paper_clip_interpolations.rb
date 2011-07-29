module Paperclip
  module Interpolations

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

