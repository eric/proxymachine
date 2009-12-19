require 'rubygems'
require 'eventmachine'

require 'proxymachine/client_connection'
require 'proxymachine/server_connection'

class ProxyMachine
  def self.log(str)
    puts str if false
  end

  def self.incr
    @@counter ||= 0
    @@counter += 1
    log @@counter
  end

  def self.decr
    @@counter ||= 0
    @@counter -= 1
    log @@counter
  end

  def self.set_router(block)
    @@router = block
  end

  def self.router
    @@router
  end

  # For advanced_proxy
  def self.client(&block)
    set_router(block)
  end

  def self.greeting(greeting = nil, &block)
    @@greeting = greeting unless greeting.nil?
    @@greeting = block    unless block.nil?

    @@greeting.respond_to?(:call) ? @@greeting.call : @@greeting
  end

  def self.server_filter(&block)
    @@server_filter = block unless block.nil?
    @@server_filter
  end

  def self.run(host, port)
    EM.epoll

    EM.run do
      EventMachine::Protocols::ClientConnection.start(host, port)
    end
  end
end

module Kernel
  def proxy(&block)
    ProxyMachine.set_router(block)
  end

  def advanced_proxy(&block)
    block.call(ProxyMachine)
  end
end