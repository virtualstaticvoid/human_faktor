class HomeController < ApplicationController

  skip_before_filter :ensure_account

  def index
  end

  def contact
  end

  def terms
  end
  
  def privacy
  end

  def features
  end

  def subscriptions
    @subscriptions = Subscription.active.where('price > 0')
  end

  def partner
  end

  def sign_in
  end
  
end
