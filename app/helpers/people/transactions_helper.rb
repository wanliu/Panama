module People::TransactionsHelper

  @@toolbars = []

  def transaction_path(people, record)
    if record.new_record?
      person_transactions_path(people.login)
    else
      person_transaction_path(people.login, record)
    end
  end

  def state_toolbar(&block)
    @@toolbars.push block
  end

  def render_toolbar
    @@toolbars.each do |toolbar|
      toolbar.call
    end
  end
end
