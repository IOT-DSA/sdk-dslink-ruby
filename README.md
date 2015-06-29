# DSLink SDK for Ruby 

DSLink SDK for Ruby

## Getting Started

### Install

Add the following to your Gemfile:

```bash
gem 'dslink', :git => 'git://github.com/IOT-DSA/sdk-dslink-ruby.git'
```

### Usage

```
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
```
ruby link.rb --broker http://localhost:8080/conn --log debug
```





### Prerequisites

- [Git](https://git-scm.com/downloads)
- [Ruby](https://www.ruby-lang.org/en/downloads/)

## Links

- [DSA Site](http://iot-dsa.org/)
- [DSA Wiki](https://github.com/IOT-DSA/docs/wiki)
