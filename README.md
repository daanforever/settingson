[![Gem Version](https://badge.fury.io/rb/settingson.svg)](http://badge.fury.io/rb/settingson)

# Settingson

Settings management for Ruby on Rails 4 applications (ActiveRecord) 

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
Replace MODEL by the class name used for the applications settings, it's frequently `Settings` but could also be `Configuration`. This will create a model (if one does not exist) and configure it with default options. 

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
