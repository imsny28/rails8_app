require "sidekiq-pro"
require "sidekiq/pro/web"

# Define Redis instances
REDIS_INSTANCES = {
  app:    "redis://redis_app:6379/0",
  cloud:  "redis://redis_cloud:6379/0",
  cloud1: "redis://redis_cloud1:6379/0"
}.transform_values { |url| Sidekiq::RedisConnection.create(url: url) }

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"

  # Dynamically mount Sidekiq Web UI for each Redis instance
  REDIS_INSTANCES.each do |name, pool|
    mount Sidekiq::Pro::Web.with(redis_pool: pool), at: "/sidekiq/#{name}", as: "sidekiq_#{name}"
  end
end
