require File.dirname(__FILE__) + '/../test_helper'
require 'pancake_controller'

# Re-raise errors caught by the controller.
class PancakeController; def rescue_action(e) raise e end; end

class PancakeControllerTest < Test::Unit::TestCase
  def setup
    @controller = PancakeController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
