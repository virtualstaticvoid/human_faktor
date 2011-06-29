module Paperclip
  module Interpolations

    def account(attachment, style_name)
      attachment.instance.account.id
    end

    def employee(attachment, style_name)
      attachment.instance.employee.id
    end

  end
end

