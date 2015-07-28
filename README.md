[![Gem Version](https://badge.fury.io/rb/settingson.svg)](http://badge.fury.io/rb/settingson)

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
Settings.server.host = '127.0.0.1'
Settings.server.port = '8888'

Settings.server.host        # => '127.0.0.1'
Settings.server.port        # => '8888'

Settings.server.smtp.host = '127.0.0.1'
Settings.server.smtp.port = 25

Settings.server.smtp.host   # => "127.0.0.1"
Settings.server.smtp.port   # => 25

Settings.from_hash({hello: :world})
Settings.hello              # => :world

Settings.not_found          # => ""
Settings.not_found.nil?     # => true
Settings.not_found.empty?   # => true
Settings.not_found.blank?   # => true
Settings.not_found.present? # => false

# but
Settings.not_found.class    # => Settings(id: integer, key: string, value: text, created_at: datetime, updated_at: datetime)
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
