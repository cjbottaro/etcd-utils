require "etcd/utils/version"
require "etcd/utils/loader"
require "etcd/utils/dumper"

module Etcd
  module Utils

    @defaults = {
      host: "localhost",
      port: 2379,
      prefix: "/v2/keys",
      root: "/",
      redirect_limit: 2,
      index_padding: "+1",
      cast_values: false
    }

    def self.defaults
      @defaults
    end

    # Load from Etcd server to Ruby object.
    def self.load(options = {})
      Loader.new(options).call
    end

    # Dump from Ruby object to Etcd server.
    def self.dump(object, options = {})
      Dumper.new(object, options).call
    end

  end
end
