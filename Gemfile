# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.6.3'

gem 'awesome_print'
gem 'babel-transpiler'
gem 'bootsnap', '>= 1.1.0', require: false
gem 'bootstrap-sass'
gem 'coffee-rails', '~> 4.2'
gem 'devise'
gem 'jbuilder', '~> 2.5'
gem 'jquery-rails'
gem 'money-rails'
gem "paypal-sdk-rest"
gem 'pg', '>= 0.18', '< 2.0'
gem 'puma', '~> 3.11'
gem 'pundit'
gem 'rails', '~> 5.2.3'
gem 'sass-rails', '~> 5.0'
gem 'simple_form'
gem 'stripe'
gem 'slim-rails', github: 'slim-template/slim-rails'
gem 'sprockets', github: 'rails/sprockets'
gem 'turbolinks', '~> 5'
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
gem 'uglifier'

group :development do
  gem 'foreman'
  gem 'listen'
  gem 'rails_layout'
  gem 'slim_lint'
  gem 'spring'
  gem 'spring-commands-rspec'
  gem 'spring-watcher-listen'
  gem 'web-console'
end

group :development, :test do
  gem 'byebug', platform: :mri
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'pry-byebug'
  gem 'rspec-rails'
  gem 'rubocop'
end

group :test do
  gem 'capybara'
  gem 'capybara-screenshot'
  gem 'database_cleaner'
  gem 'fake_stripe'
  gem 'launchy'
  gem 'poltergeist'
  gem 'selenium-webdriver'
  gem 'sinatra', github: 'sinatra/sinatra'
  gem 'vcr'
  gem 'webmock'
end
