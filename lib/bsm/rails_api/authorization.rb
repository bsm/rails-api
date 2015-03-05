require 'active_support/concern'

module BSM::RailsAPI::Authorization
  extend ActiveSupport::Concern

  class NotSecure < StandardError
  end

  included do
    after_filter :ensure_permit_access_authorized!
  end

  class_methods do

    # Manage access permissions.
    # Assumptions:
    #
    #  * users are already authenticated
    #  * controller has a method called current_user which returns a user record
    #  * the user has a `#kind` method which returns a string, e.g. 'employee' or 'client'
    #  * the user has a `#roles` method which returns an array of strings, e.g. ['app:some:role', 'app:other:role']
    #
    # Example:
    #
    #   permit_access :read, employee: :all, client: ["app:custom:role"]
    #   permit_access :manage, :destroy, employee: ["app:admin"]
    #
    def permit_access(*actions)
      opts = actions.extract_options!
      acts = actions.map do |name|
        case name
        when :read   then [:index, :show]
        when :manage then [:create, :update]
        else name.to_sym
        end
      end.flatten.uniq

      before_filter only: acts do |ctrl|
        user = ctrl.send(:current_user)
        ctrl.send :unauthorized! unless user

        reqs = opts[user.kind.to_sym]
        ctrl.send :unauthorized! if reqs != :all && (Array.wrap(reqs) & user.roles).empty?
        ctrl.send :instance_variable_set, :@_bsm_rails_api_authorized, true
      end unless acts.empty?
    end

  end

  protected

    # Render a 403
    def unauthorized!
      render text: "Unauthorized", status: 403
    end

  private

    # Callback to ensure we have actually granted the user permission
    # to access a resource via permit_access
    def ensure_permit_access_authorized!
      unless @_bsm_rails_api_authorized
        raise NotSecure, "This action failed because permit_access filters were not run. Add permit_access to secure this endpoint."
      end
    end

end
