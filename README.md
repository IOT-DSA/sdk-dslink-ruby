# DSLink SDK for Ruby 

DSLink SDK for Ruby

## Getting Started

### Prerequisites

- [Git](https://git-scm.com/downloads)
- [Ruby](https://www.ruby-lang.org/en/downloads/)

### Install

Add the following to your Gemfile:

```ruby
gem 'dslink', :git => 'git://github.com/IOT-DSA/sdk-dslink-ruby.git'
```

### Usage

```ruby
# link.rb
require 'dslink'
link = DSLink::Link.instance
link.provider.load({
    'hello-world' => {
        '$name' => 'Hello',
        '$type' => 'string',
        '?value' => ''
    }
})
link.connect do |success|
  link.provider.get_node('/hello-world').value = 'World'
end
```

Run:
```bash
ruby link.rb --broker http://localhost:8080/conn --log debug
```


## Links

- [DSA Site](http://iot-dsa.org/)
- [DSA Wiki](https://github.com/IOT-DSA/docs/wiki)
