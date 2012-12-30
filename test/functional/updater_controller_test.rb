require 'test_helper'

class UpdaterControllerTest < ActionController::TestCase
  test "should get update_stats" do
    get :update_stats
    assert_response :success
  end

end
