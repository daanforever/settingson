[![Gem Version](https://badge.fury.io/rb/settingson.svg)](http://badge.fury.io/rb/settingson)

# Settingson

Settings management for Ruby on Rails 4 applications (ActiveRecord) 

```ruby
Settings.server.host = '127.0.0.1'
Settings.server.port = '8888'

Settings.server.host # => '127.0.0.1'
Settings.server.port # => '8888'

Settings.server.smtp.host = '127.0.0.1'
Settings.server.smtp.port = 25

Settings.server.smtp.host # => "127.0.0.1"
Settings.server.smtp.port # => 25

# With hash
Settings.rules = { '1st RULE' => 'You do not talk about FIGHT CLUB.' }
Settings.rules['1st RULE'] #  => "You do not talk about FIGHT CLUB."

# With array
Settings.array = [ 1, 2, 3, 4, 5 ]
Settings.array # => [1, 2, 3, 4, 5]

# Array of hashes
Settings.array.of.hashes = [ { hello: :world}, {'glad' => :to}, {see: 'you'} ]
Settings.array.of.hashes # => [{:hello=>:world}, {"glad"=>:to}, {:see=>"you"}]
```

### Using with [Simple Form](https://github.com/plataformatec/simple_form) and [Haml](https://github.com/haml/haml)
```ruby
= simple_form_for Settings.server do |f|
  = f.input :host
  = f.input :port
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
Replace MODEL by the class name used for the applications settings, it's frequently `Settings` but could also be `Configuration`. This will create a model (if one does not exist) and configure it with default options. 

Next, you'll usually run 
```console
rake db:migrate
``` 
as the generator will have created a migration file (if your ORM supports them).

## Example

```console
rails g settingson Settings
rake db:migrate
```

In rails console:
```ruby
2.1.1 :006 > Settings.hello.hello3.hello2
  Settings Load (0.2ms)  SELECT "settings".* FROM "settings" WHERE "settings"."name" = 'hello' LIMIT 1
  Settings Load (0.2ms)  SELECT "settings".* FROM "settings" WHERE "settings"."name" = 'hello.hello3' LIMIT 1
  Settings Load (0.1ms)  SELECT "settings".* FROM "settings" WHERE "settings"."name" = 'hello.hello3.hello2' LIMIT 1
 => #<Settingson::Store:0x000001016aee68 @klass=Settings(id: integer, name: string, value: text, created_at: datetime, updated_at: datetime), @name="hello.hello3.hello2", @value=#<Settingson::Store:0x000001016aee68 ...>>
 
2.1.1 :007 > Settings.hello.hello3.hello2 = 1
  Settings Load (0.2ms)  SELECT "settings".* FROM "settings" WHERE "settings"."name" = 'hello' LIMIT 1
  Settings Load (0.2ms)  SELECT "settings".* FROM "settings" WHERE "settings"."name" = 'hello.hello3' LIMIT 1
  Settings Load (0.1ms)  SELECT "settings".* FROM "settings" WHERE "settings"."name" = 'hello.hello3.hello2' LIMIT 1
   (0.1ms)  begin transaction
  SQL (5.2ms)  INSERT INTO "settings" ("created_at", "name", "updated_at", "value") VALUES (?, ?, ?, ?)  [["created_at", Sat, 03 May 2014 09:45:25 UTC +00:00], ["name", "hello.hello3.hello2"], ["updated_at", Sat, 03 May 2014 09:45:25 UTC +00:00], ["value", "--- 1\n...\n"]]
   (2.4ms)  commit transaction
 => 1
 
2.1.1 :008 > Settings.hello.hello3.hello2
  Settings Load (0.3ms)  SELECT "settings".* FROM "settings" WHERE "settings"."name" = 'hello' LIMIT 1
  Settings Load (0.2ms)  SELECT "settings".* FROM "settings" WHERE "settings"."name" = 'hello.hello3' LIMIT 1
  Settings Load (0.1ms)  SELECT "settings".* FROM "settings" WHERE "settings"."name" = 'hello.hello3.hello2' LIMIT 1
 => 1
 ```

## Contributing

1. Fork it ( https://github.com/daanforever/settingson/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
