require "json"
require "etcd/utils/loader/node_parser"

module Etcd
  module Utils
    class Loader

      attr_reader :root, :options

      def initialize(options)
        @options = Etcd::Utils.defaults.merge(options)
        @root = options[:root]
      end

      def call
        case options[:root]
        when String
          NodeParser.new(root_node, options).call
        when Hash
          NodeParser.new(options[:root], options).call
        else
          raise ArgumentError, "expecting string or hash"
        end
      end

      def root_node
        @root_node ||= begin
          url = build_url("%s%s?recursive=true" % [options[:prefix], root])
          response = fetch_url(url)
          JSON.parse(response.body)["node"]
        end
      end

      def fetch_url(url)
        uri = URI.parse(url)
        response = Net::HTTP.get_response(uri)
        case response
        when Net::HTTPSuccess then
          response
        when Net::HTTPRedirection then
          location = response['location']
          fetch_url(build_url(location))
        else
          response.value
        end
      end

      def build_url(path)
        "http://%s:%d#{path}" % [options[:host], options[:port]]
      end

    end
  end
end
