require 'spec_helper'

describe Etcd::Utils do

  before(:each) do
    begin
      client.delete("/", recursive: true)
    rescue Etcd::KeyNotFound
    end
  end

  after(:each) do
    begin
      client.delete("/", recursive: true)
    rescue Etcd::KeyNotFound
    end
  end

  it 'has a version number' do
    expect(Etcd::Utils::VERSION).not_to be nil
  end

  it 'writes nested hashes' do
    dump(foo: { bar: [1, 2, 3] }, baz: "hi")

    expect_get "/foo/bar/00", "1"
    expect_get "/foo/bar/01", "2"
    expect_get "/foo/bar/02", "3"
    expect_get "/baz", "hi"
  end

  it "reads nested hashes" do
    set "/foo/bar/00", 1
    set "/foo/bar/01", 2
    set "/foo/bar/02", 3
    set "/baz", "hi"

    expect_load("foo" => { "bar" => %w[1 2 3] }, "baz" => "hi")
  end

  it "writes arrays" do
    dump ["foo", "bar", "baz"], root: "/array_demo"

    expect_get "/array_demo/00", "foo"
    expect_get "/array_demo/01", "bar"
    expect_get "/array_demo/02", "baz"
  end

  it "reads arrays" do
    set "/array_demo/00", "foo"
    set "/array_demo/01", "bar"
    set "/array_demo/02", "baz"

    expect_load({ root: "/array_demo" }, %w[foo bar baz])
    expect_load "array_demo" => %w[foo bar baz]
  end

  it "writes scalars" do
    dump "chris", root: "/name"
    expect_get "/name", "chris"
  end

  it "reads scalars" do
    set "/name", "chris"
    expect_load({ root: "/name" }, "chris")
  end

  it "dumper doesn't produce double slashes" do
    
    hash = {
      "cassandra" => {
        "replication_factor" => 2,
        "hosts" => [
          "node1.foo.com",
          "node2.foo.com"
        ]
      }
    }

    dumper = Etcd::Utils::Dumper.new(hash)
    dumper.traverse do |k, v|
      expect(k).to_not match("//")
    end

    dumper = Etcd::Utils::Dumper.new(hash, root: "/")
    dumper.traverse do |k, v|
      expect(k).to_not match("//")
    end

    dumper = Etcd::Utils::Dumper.new(hash, root: "/foo/")
    dumper.traverse do |k, v|
      expect(k).to_not match("//")
    end

  end

  def dump(*args)
    Etcd::Utils.dump(*args)
  end

  def load(*args)
    Etcd::Utils.load(*args)
  end

  def expect_load(*args)
    if args.length == 1
      expect(load).to eq(args.first)
    elsif args.length == 2
      expect(load(args.first)).to eq(args.last)
    else
      raise "unexpected args: #{args.inspect}"
    end
  end

  def expect_get(key, value)
    expect( client.get(key).value ).to eq(value)
  end

  def set(key, value)
    client.set(key, value: value)
  end

  def client
    @client ||= Etcd.client
  end

end
