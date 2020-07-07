# Xcoed

Xcoed (Xcode co-ed) - Use a `Package.swift` manifest for an Xcode project.

**Currently, only packages with public git URLs and local packages are supported.**  
**Currently, only packages with range version requirements are supported.**

## Installation:

* Meant to be used with [Xcake](https://github.com/igor-makarov/xcake) or some other Xcodeproj generator.
* Add `gem 'xcoed'` in your Gemfile
* Add a `before_save` hook:  
```ruby
project.before_save do |project|
  Xcoed::integrate_package_swift! project
end
```

## Alternative Usage:

* Add `gem 'xcoed'` in your Gemfile
* `bundle exec xcoed`

For more info, look at [DemoXcoed](https://github.com/igor-makarov/DemoXcoed) project.
