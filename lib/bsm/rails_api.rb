require 'active_support/concern'

module BSM
  module RailsAPI
  end
end

%w|
  authorization
|.each do |name|
  require "bsm/rails_api/#{name}"
end
