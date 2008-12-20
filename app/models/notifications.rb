class Notifications < ActionMailer::Base
  
  def pick(user, picked_user, sent_at = Time.now)
    subject    'Secret Santa Pick Notice'
    recipients user.email
    from       "Secret Santa Mailer #{CONFIG['admin']['email']}"
    sent_on    sent_at
    
    body       :picked_user => picked_user
  end

  def badround(last_user, sent_at = Time.now)
    subject    'Secret Santa Bad Round Notice! Please pick again'
    recipients User.all.collect{|user| user.email if user.email}.compact
    from       "Secret Santa Mailer #{CONFIG['admin']['email']}"
    sent_on    sent_at
    
    body       :last_user => last_user
  end
  
  def goodround(last_user, sent_at = Time.now)
    subject 'Secret Santa Good Round Notice!'
    recipients User.all.collect{|user| user.email if user.email}.compact
    from       "Secret Santa Mailer #{CONFIG['admin']['email']}"
    sent_on    sent_at
    
    body       :last_user => last_user
  end

end
