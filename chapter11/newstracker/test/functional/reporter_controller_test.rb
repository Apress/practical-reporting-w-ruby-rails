require File.dirname(__FILE__) + '/../test_helper'
require 'reporter_controller'

# Re-raise errors caught by the controller.
class ReporterController; def rescue_action(e) raise e end; end

class ReporterControllerTest < Test::Unit::TestCase
  def setup
    @controller = ReporterController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
