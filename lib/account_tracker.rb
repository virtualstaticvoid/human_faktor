module AccountTracker

  def self.current
    Thread.current[:current_account]
  end

  def self.current=(account)
    Thread.current[:current_account] = account
  end

end
