require 'spec_helper'

describe BSM::RailsAPI::Authorization do
  include RSpec::SetupAndTeardownAdapter
  include ActionController::TestCase::Behavior
  tests TestApp::PostsController

  before do
    @routes = TestApp.routes
  end

  it 'should respond' do
    get :index
    expect(response).to be_forbidden
  end

end
