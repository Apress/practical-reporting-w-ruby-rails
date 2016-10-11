module BudgetOptimizerHelper
  def format_google_currency(currency_value)
      "#{'%0.2f' % (currency_value/10000.0) } cents"
  end
end
