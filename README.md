# AffairsOfState

You have an Active Record model. It nees to have multiple states, but not complex rules. This gem gives you validation, easy check and change methods, and a single configuration line.

## Installation

Add this line to your application's Gemfile:

    gem 'affairs_of_state'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install affairs_of_state

## Usage

The gem assumes you have a string column named "status" on your model:

    add_column :model_name, :status, :default => "active"

Then you just list your states in the model:

    affairs_of_state :active, :inactive

If you'd like to use another column, lets say "state", pass it in as a configuration option:

    affairs_of_state :active, :inactive, :column => :state

You can also turn off validation:

    affairs_of_state :active, :inactive, :allow_blank => true

Or give it a long list of statuses:

    affairs_of_state :ordered, :cancelled, :shipped, :lost, :in_transit


## Methods

The gem provides methods for checking and setting your status. The question mark method returns a boolean, and the bang method changes to that status. Lets assume you have "active" and "cancelled" as defined status:

    widget = Widget.first

    widget.cancelled! if widget.active?

You can also access all your statuses on the model like so:

    Widget::STATUES  # -> ["active", "cancelled"]

It also provides scopes automagically:

    Widget.active
    
    Widget.cancelled


## "But I want callbacks and validations and other things."

Then this gem isn't for you. Consider:

https://github.com/rubyist/aasm

https://github.com/pluginaweek/state_machine


## Tests

Just run rspec:

    rspec


## The usual

Author: Kevin McPhillips - github@kevinmcphillips.ca

