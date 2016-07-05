# Affairs of State

[![Build Status](https://travis-ci.org/kmcphillips/affairs_of_state.png?branch=master)](https://travis-ci.org/kmcphillips/affairs_of_state)

You have an Active Record model. It nees to have multiple states, boolean convenience methods, simple validation, but not complex rules. This gem gives you this in a single line class method.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'affairs_of_state'
```

Or install it with:

```ruby
$ gem install affairs_of_state
```

## Usage

The gem assumes you have a string column named `status` on your model:

```ruby
add_column :model_name, :status, default: "active"
```

Then you just list your states in the model:

```ruby
affairs_of_state :active, :inactive
```

If you'd like to use another column, lets say `state`, pass it in as a configuration option:

```ruby
affairs_of_state :active, :inactive, column: :state
```

You can also turn off validation:

```ruby
affairs_of_state :active, :inactive, allow_blank: true
```

Or give it a long list of statuses:

```ruby
affairs_of_state :ordered, :cancelled, :shipped, :lost, :in_transit
```

You can also pass a proc or a method name symbol to the :if option to bypass validation:

```ruby
affairs_of_state :active, :inactive, if: ->(object) { only_validate_if_this_is_true(object) }
```
or
```ruby
affairs_of_state :active, :inactive, if: :only_validate_if_this_method_returns_true
```


## Methods

The gem provides methods for checking and setting your status. The question mark method returns a boolean, and the bang method changes to that status. Lets assume you have "active" and "cancelled" as defined status:

```ruby
widget = Widget.first
widget.cancelled! if widget.active?
```

You can also access all your statuses on the model like so:

```ruby
Widget::STATUSES  # -> ["active", "cancelled"]
```

It also provides scopes automagically:

```ruby
Widget.active
Widget.cancelled
```

For select inputs in forms there is a convenience method that returns all states in the format expected by `options_for_select`

```ruby
<%= f.select :status, options_for_select(Widget.statuses_for_select) %>
```


## "But I want callbacks and validations etc."

Then this gem isn't for you. Consider:

https://github.com/rubyist/aasm

https://github.com/pluginaweek/state_machine


## Tests

Just run rspec:

```
rspec
```


## The usual

By Kevin McPhillips (github@kevinmcphillips.ca)

[MIT License](http://opensource.org/licenses/MIT)
