# Etcd::Utils

Helper functions and classes for dumping Ruby objects to an Etcd cluster and vice versa.

A "Ruby object" can be a Hash, Array or scalar value (string, integer, bool, etc).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'etcd-utils'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install etcd-utils

## Usage

```ruby
# Load your entire Etcd cluster into a Ruby object.
object = Etcd::Utils.load

# Load part of your Etcd cluster into a Ruby object.
object = Etcd::Utils.load(root: "/some/path")

# Dump a Hash to your Etcd cluster.
hash = { blah: { foo: "hi", bar: [1, 2, 3] } }
Etcd::Utils.dump(hash)

# Dump a Hash to your Etcd cluster under a specified key (directory).
Etcd::Utils.dump(hash, root: "/blah/test")
```

## Arrays

The entire reason why I wrote this gem is because of how I want arrays
to be handled. This is best shown with an example:

```ruby
Etcd::Utils.dump(["hi", "bye", "blah"], root: "/array_demo")
```

That will produce the following key/value pairs in Etcd:

```
/array_demo/00, hi
/array_demo/01, bye
/array_demo/02, blah
```

Now if you load that key...

```ruby
Etcd::Utils.load(root: "/array_demo")
# ["hi", "bye", "blah"]

Etcd::Utils.load
# { "array_demo" => ["hi", "bye", "blah"], ... }
```

## Array padding

You can control the zero padding for the Etcd keys that represent array indices.

```ruby
Etcd::Utils.dump(["hi", "bye", "blah"], root: "/array_demo", index_padding: 5)

# In Etcd...
# /array_demo/00000, hi
# /array_demo/00001, bye
# /array_demo/00002, blah
```

# Dynamic padding

Padding can be determined by how many items are in the array.

```ruby
array = 25.times.map{ rand }
Etcd::Utils.dump(array, root: "/array_demo", index_padding: "+1")

# In Etcd...
# /array_demo/000, ...
# /array_demo/001, ...
# /array_demo/002, ...
# ...
# /array_demo/024, ...

array = 25.times.map{ rand }
Etcd::Utils.dump(array, root: "/array_demo", index_padding: "+2")

# In Etcd...
# /array_demo/0000, ...
# /array_demo/0001, ...
# /array_demo/0002, ...
# ...
# /array_demo/0024, ...
```

The default `:index_padding` is is `"+1"`.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/cjbottaro/etcd-utils.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
