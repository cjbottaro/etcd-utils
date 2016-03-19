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
    hash = { foo: { bar: [1, 2, 3] }, baz: "hi" }
    Etcd::Utils.dump(hash)

    expect(get("/foo/bar/00")).to eq("1")
    expect(get("/foo/bar/01")).to eq("2")
    expect(get("/foo/bar/02")).to eq("3")
    expect(get("/baz")).to eq("hi")
  end

  it "writes arrays" do
    array = ["foo", "bar", "baz"]
    Etcd::Utils.dump(array, root: "/array_demo")

    expect(get("/array_demo/00")).to eq("foo")
    expect(get("/array_demo/01")).to eq("bar")
    expect(get("/array_demo/02")).to eq("baz")
  end

  it "reads nested hashes" do
    set("/foo/bar/00", value: 1)
    set("/foo/bar/01", value: 2)
    set("/foo/bar/02", value: 3)
    set("/baz", value: "hi")

    expect(Etcd::Utils.load).to eq({ "foo" => { "bar" => %w[1 2 3] }, "baz" => "hi" })
  end

  it "reads arrays" do
    set "/array_demo/00", value: "foo"
    set "/array_demo/01", value: "bar"
    set "/array_demo/02", value: "baz"

    expect(Etcd::Utils.load(root: "/array_demo")).to eq(%w[foo bar baz])
    expect(Etcd::Utils.load).to eq("array_demo" => %w[foo bar baz])
  end

  it "writes scalars" do
    Etcd::Utils.dump("chris", root: "/name")
    expect(get("/name")).to eq("chris")
  end

  it "reads scalars" do
    set "/name", value: "chris"
    expect(Etcd::Utils.load(root: "/name")).to eq("chris")
  end

  def get(*args)
    client.get(*args).value
  end

  def set(*args)
    client.set(*args)
  end

  def client
    @client ||= ::Etcd.client
  end

end
