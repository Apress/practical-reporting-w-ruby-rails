require File.dirname(__FILE__) + '/../test_helper'
require 'homepage_controller'

# Re-raise errors caught by the controller.
class HomepageController; def rescue_action(e) raise e end; end

class HomepageControllerTest < Test::Unit::TestCase
  def setup
    @controller = HomepageController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
