namespace :db do
  namespace :session do

    desc "Removes expired sessions"
    task :clear => :environment do
      ActiveRecord::SessionStore::Session.delete_all(["updated_at < ?", Devise.remember_for.ago])
    end

  end
end
