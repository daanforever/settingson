[![Gem Version](https://badge.fury.io/rb/settingson.svg)](http://badge.fury.io/rb/settingson)
[![Build Status](https://travis-ci.org/daanforever/settingson.svg?branch=master)](https://travis-ci.org/daanforever/settingson)

# Settingson

Simple settings management for applications (Ruby on Rails 4 with ActiveRecord)

## Example

shell commands:
```console
rails g settingson Settings
rake db:migrate
```

code:
```ruby
Settings.server.host = '127.0.0.1'        # => '127.0.0.1'
Settings.server.port = '8888'             # => '8888'

Settings.server.host                      # => '127.0.0.1'
Settings.server.port                      # => '8888'

Settings.server.smtp.host = '127.0.0.1'   # => '127.0.0.1'
Settings.server.smtp.port = 25            # => 25

Settings.server.smtp.host                 # => "127.0.0.1"
Settings.server.smtp.port                 # => 25

Settings.from_hash({hello: :world})
Settings.hello                            # => :world

Settings.not_found                        # => ""
Settings.not_found.nil?                   # => true
Settings.not_found.empty?                 # => true
Settings.not_found.blank?                 # => true
Settings.not_found.present?               # => false

# but
Settings.not_found.class    # => Settings(id: integer, key: string, value: text, created_at: datetime, updated_at: datetime)

Settings.all                # =>
# [#<Settings id: 1, key: "server.host", value: "127.0.0.1", created_at: "2015-12-08 15:17:56", updated_at: "2015-12-08 15:17:56">,
#  #<Settings id: 2, key: "server.port", value: "8888", created_at: "2015-12-08 15:17:56", updated_at: "2015-12-08 15:17:56">,
#  #<Settings id: 3, key: "server.smtp.host", value: "127.0.0.1", created_at: "2015-12-08 15:18:21", updated_at: "2015-12-08 15:18:21">,
#  #<Settings id: 4, key: "server.smtp.port", value: 25, created_at: "2015-12-08 15:18:22", updated_at: "2015-12-08 15:18:22">,
#  #<Settings id: 5, key: "hello", value: :world, created_at: "2015-12-08 15:18:32", updated_at: "2015-12-08 15:18:32">]
```

### Cached values

Caching implemented via ActiveSupport::Cache::Store [(read more)](http://guides.rubyonrails.org/caching_with_rails.html).

By default 10 seconds:
```ruby
Settings.hello.world = 'message'          # => 'message'
Settings.cached.hello.world               # => 'message' with asking DB
Settings.cached.hello.world               # => 'message' without asking DB
sleep 11
Settings.cached.hello.world               # => 'message' with asking DB
```

You can change time to Live:
```ruby
Settings.cached(30.minutes).hello.world   # => 'message'
# same as
Settings.cached(1800).hello.world         # => 'message'
```

### Using with [Simple Form](https://github.com/plataformatec/simple_form) and [Haml](https://github.com/haml/haml)
in view:
```ruby
= simple_form_for( Settings, url: settings_path, method: :patch ) do |f|
  = f.error_notification
  = f.input :'server.smtp.host', label: 'SMTP Host', as: :string, placeholder: 'mail.google.com'
  = f.input :'server.smtp.port', label: 'SMTP Port', as: :string, placeholder: '25'
  = f.button :submit, t('update', default: 'Update settings')
```

in controller:
```ruby
class SettingsController < ApplicationController
  def update
    if Settings.from_hash(params[:settings])
      flash[:notice] = t('settings_updated', default: 'Settings updated successfully')
    else
      flash[:alert]  = t('settings_not_updated', default: 'Settings not updated')
    end
    render :edit
  end
end
```

## The initial values
New way:
in config/initializers/settingson.rb
```ruby
Settings.defaults do
  Settings.server.smtp.host? || Settings.server.smtp.host = 'host'
  Settings.server.smtp.port? || Settings.server.smtp.port = 25
end
```

Old way:
in config/initializers/settingson.rb
```ruby
Rails.application.config.after_initialize do
  begin
    Settings.server.smtp.host? || Settings.server.smtp.host = 'host'
    Settings.server.smtp.port? || Settings.server.smtp.port = '25'
  rescue
    Rails.logger.warn('Something goes wrong')
  end
end
```

## Installation

Add this line to your application's Gemfile:

```ruby
    gem 'settingson'
```

And then execute:

```console
    $ bundle
```

Or install it yourself as:

```console
    $ gem install settingson
```

## Usage

```console
rails g settingson MODEL
```
Replace MODEL by the class name used for the applications settings, it's frequently `Settings` but it may also be `Configuration` or something else. This will create a model (if one does not exist) and configure it with default options.

Next, you'll usually run
```console
rake db:migrate
```
as the generator will have created a migration file (if your ORM supports them).

## Contributing

1. Fork it ( https://github.com/daanforever/settingson/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
