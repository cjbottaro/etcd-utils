require "json"

module Etcd
  module Utils
    class Loader

      attr_reader :root, :options

      def initialize(options)
        @options = Etcd::Utils.defaults.merge(options)
        @root = options[:root]
      end

      def call
        handle_node(root_node)
      end

      def handle_node(node)
        if node["dir"]

          # We're not interested in the whole key, just the last part of it.
          node["nodes"].each{ |n| n["key_part"] = n["key"].split("/").last }

          if node["nodes"].all?{ |n| n["key_part"].match(/^\d+$/) }
            node_to_array(node)
          else
            node_to_hash(node)
          end
        else
          node_to_value(node)
        end
      end

      # TODO make an option not to sort (may be too slow).
      def node_to_array(node)
        # Is this too clever?
        #   { "01" => "bar", "00" => "foo", "02" => "baz" }  # node_to_hash
        #   [ ["01", "bar"], ["00", "foo"], ["02", "baz"] ]  # to_a
        #   [ ["00", "foo"], ["01", "bar"], ["02", "baz"] ]  # sort
        #   [ "foo", "bar", "baz" ]                          # map
        node_to_hash(node).to_a.sort.map(&:last)
      end

      def node_to_hash(node)
        node["nodes"].inject({}) do |memo, n|
          memo[ n["key_part"] ] = handle_node(n)
          memo
        end
      end

      def node_to_value(node)
        node["value"]
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
