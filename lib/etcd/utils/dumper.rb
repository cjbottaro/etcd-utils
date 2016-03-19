module Etcd
  module Utils
    class Dumper

      attr_reader :root, :object, :options

      def initialize(object, options = {})
        @object = object
        @options = Etcd::Utils.defaults.merge(options)

        @root = options[:root]
        @traverse_callback = nil
      end

      def call
        @base_uri = URI.parse "http://%s:%d%s" % [options[:host], options[:port], options[:prefix]]
        @put_uri  = @base_uri.dup

        Net::HTTP.start(@base_uri.host, @base_uri.port) do |http|
          traverse{ |k, v| do_set(http, k, v) }
        end

        @base_uri = @put_uri = nil
      end

      def traverse(&block)
        @traverse_callback = block
        handle_object(object, root)
        @traverse_callback = nil
      end

    private

      def handle_object(object, path)
        case object
        when Array
          handle_array(object, path)
        when Hash
          handle_hash(object, path)
        else
          handle_scalar(object, path)
        end
      end

      def handle_array(array, path)
        hash = {}
        padding = determine_padding(array)
        array.each_with_index do |object, i|
          next_path = "#{path}/%0#{padding}d" % i
          hash[next_path] = handle_object(object, next_path)
        end

        hash
      end

      def handle_hash(hash, path)
        hash.inject({}) do |memo, (key, object)|
          next_path = "#{path}/#{key}"
          memo[next_path] = handle_object(object, next_path)
          memo
        end
      end

      def handle_scalar(object, path)
        @traverse_callback.call(path, object)
      end

      def determine_padding(array)
        case options[:index_padding]
        when Fixnum
          padding = options[:index_padding]
        else
          padding = options[:index_padding].match(/\+(\d+)/)[1].to_i + array.length.to_s.length
        end
      end

      def do_set(http, key, value)
        @put_uri.path = @base_uri.path + key
        put = Net::HTTP::Put.new(@put_uri)
        put.set_form_data(value: value)

        response = http.request(put)

        if !(200..299).include?(response.code.to_i)
          raise "HTTP #{response.code}: #{response.body}"
        end
      end

    end
  end
end
