require 'spec_helper'

describe BSM::RailsAPI::Authorization do
  include RSpec::SetupAndTeardownAdapter
  include ActionController::TestCase::Behavior
  tests TestApp::SecureController

  before do
    @routes = TestApp.routes
  end

  describe "index" do

    it 'should permit access when roles are set to :all' do
      @controller.current_user = TestApp.employee(["X"])
      get :index
      expect(response).to be_ok
    end

    it 'should permit access when role requirements are met' do
      @controller.current_user = TestApp.client(["A"])
      get :index
      expect(response).to be_ok
    end

    it 'should reject access when role missing' do
      @controller.current_user = TestApp.client(["B"])
      get :index
      expect(response).to be_forbidden
    end

  end

  describe "update" do

    it 'should permit access when role requirements are met' do
      @controller.current_user = TestApp.employee(["X"])
      put :update, id: 1
      expect(response).to be_ok
    end

    it 'should reject access when role missing' do
      @controller.current_user = TestApp.employee(["Y"])
      put :update, id: 1
      expect(response).to be_forbidden
    end

    it 'should reject access when kind forbidden' do
      @controller.current_user = TestApp.client(["A"])
      put :update, id: 1
      expect(response).to be_forbidden
    end

  end

  describe "destroy" do

    it 'should permit access when role requirements are met' do
      @controller.current_user = TestApp.employee(["Z"])
      delete :destroy, id: 1
      expect(response).to be_ok
    end

    it 'should reject access when role missing' do
      @controller.current_user = TestApp.employee(["X"])
      delete :destroy, id: 1
      expect(response).to be_forbidden
    end

    it 'should reject access when kind forbidden' do
      @controller.current_user = TestApp.client(["A"])
      delete :destroy, id: 1
      expect(response).to be_forbidden
    end

  end

  describe "insecure" do

    it 'should error' do
      @controller.current_user = TestApp.employee(["Z"])
      expect(-> { put :insecure, id: 1 }).to raise_error(BSM::RailsAPI::Authorization::NotSecure)
    end

  end

end
