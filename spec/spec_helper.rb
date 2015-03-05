$:.unshift File.dirname(__FILE__)
$:.unshift File.expand_path('../../lib', __FILE__)
ENV["RAILS_ENV"] ||= 'test'

require 'rubygems'
require 'bundler/setup'
require 'rails'
require 'action_controller/railtie'
require 'action_controller/test_case'
require 'rspec'
require 'bsm-rails-api'

module TestApp

  def self.routes
    @@routes ||= ActionDispatch::Routing::RouteSet.new.tap do |r|
      r.draw do
        get "posts", to: "test_app/posts#index"
      end
    end
  end

  class PostsController < ActionController::Base
    include TestApp.routes.url_helpers
    include BSM::RailsAPI::Authorization

    def index
      render text: "OK"
    end
  end

end

module RSpec::SetupAndTeardownAdapter
  extend ActiveSupport::Concern

  module ClassMethods
    # Wraps `setup` calls from within Rails' testing framework in `before`
    # hooks.
    def setup(*methods)
      methods.each do |method|
        if method.to_s =~ /^setup_(with_controller|fixtures|controller_request_and_response)$/
          prepend_before { __send__ method }
        else
          before         { __send__ method }
        end
      end
    end

    # @api private
    #
    # Wraps `teardown` calls from within Rails' testing framework in
    # `after` hooks.
    def teardown(*methods)
      methods.each { |method| after { __send__ method } }
    end
  end

  def initialize(*args)
    super
    @example = nil
  end

  def method_name
    @example
  end
end
