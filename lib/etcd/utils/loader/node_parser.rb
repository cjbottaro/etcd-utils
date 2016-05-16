module Etcd
  module Utils
    class Loader
      class NodeParser

        attr_reader :root_node, :options

        def initialize(root_node, options = {})
          @root_node = root_node
          @options = options
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
          case options[:cast_values]
          when Proc
            options[:cast_values].call( node["value"] )
          when true
            cast_value( node["value"] )
          else
            node["value"]
          end
        end

        def cast_value(value)
          if value == ""
            nil
          elsif value =~ /^[+-]?\d+\.\d+$/
            value.to_f
          elsif value =~ /^[+-]?\d+$/
            value.to_i
          elsif value.strip.downcase == "true"
            true
          elsif value.strip.downcase == "false"
            false
          else
            value
          end
        end

      end
    end
  end
end
