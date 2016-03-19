$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'etcd/utils'
require "etcd"

Etcd::Utils.defaults[:prefix] = "/v2/keys/etcd-utils-test"

module Etcd
  module Keys
    def key_endpoint
      Etcd::Utils.defaults[:prefix]
    end
  end
end
