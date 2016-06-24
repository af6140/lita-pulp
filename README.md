# lita-pulp

A lita handler plugin for pulp server operations.

## Installation

Add lita-pulp to your Lita instance's Gemfile:

``` ruby
gem "lita-pulp"
```

## Configuration

Configuration options

```ruby
Lita.configure do |config|
  config.handlers.pulp.url="https://pulp.co.epi.web"
  config.handlers.pulp.api_path="/pulp/api/v2/"
  config.handlers.pulp.username="admin"
  config.handlers.pulp.password="admin"
  config.handlers.pulp.verify_ssl=false #optional default to false
end
```

## Usage

It can do following:
- List all rpm repositories
- List all puppet repositories
- Search rpm package
- Search puppet module
- Copy rpm package from one repository to another
- Copy puppet module from one repository to another
