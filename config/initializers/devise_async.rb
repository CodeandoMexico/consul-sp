Devise::Async.setup do |config|
  if Rails.env.test? || Rails.env.development?
    config.enabled = false
  else
    config.enabled = false
  end
  config.backend = :delayed_job
end
