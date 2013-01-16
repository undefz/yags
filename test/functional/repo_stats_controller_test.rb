require 'test_helper'

class RepoStatsControllerTest < ActionController::TestCase
  test "should get show" do
    get :show, repo_id: 1
    
    top_adds = assigns(:top_add_contribs)
    top_deletes = assigns(:top_delete_contribs)

    assert_equal top_adds.map{ |c| c.author_id }, [7, 6, 5, 4, 3, 2, 1]
    assert_equal top_deletes.map{ |c| c.author_id }, [1, 2, 3, 4, 5, 6, 7]
    
    assert_response :success
  end

end
