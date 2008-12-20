desc "Setup the application by creating the initial user"
task :setup => :environment do
  administrator = User.new(CONFIG["admin"])
  administrator.is_admin = true
  administrator.save!
end