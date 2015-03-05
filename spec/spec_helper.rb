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
  User = Struct.new(:kind, :roles)

  def self.routes
    @@routes ||= ActionDispatch::Routing::RouteSet.new.tap do |r|
      r.draw do
        get "secure",           to: "test_app/secure#index"
        get "secure/:id",       to: "test_app/secure#show"
        put "secure/:id",       to: "test_app/secure#update"
        delete "secure/:id",    to: "test_app/secure#destroy"
        put "secure/:id/fails", to: "test_app/secure#insecure"
      end
    end
  end

  def self.client(roles = ["A"])
    User.new :client, roles
  end

  def self.employee(roles = ["X"])
    User.new :employee, roles
  end

  class ApplicationController < ActionController::Base
    attr_accessor :current_user

    def current_user
      @current_user ||= TestApp.employee
    end
  end

  class SecureController < ApplicationController
    include TestApp.routes.url_helpers
    include BSM::RailsAPI::Authorization

    permit_access :read,
      client: ['A'],
      employee: :all
    permit_access :manage,
      employee: ['X']
    permit_access :destroy,
      employee: ['Z']

    def index
      render text: "INDEX"
    end

    def show
      render text: "SHOW"
    end

    def update
      render text: "UPDATE"
    end

    def destroy
      render text: "DESTROY"
    end

    def insecure
      render text: "INSECURE"
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
