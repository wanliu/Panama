module People::TransactionsHelper

  def transaction_path(people, record)
    if record.new_record?
      person_transactions_path(people.login)
    else
      person_transaction_path(people.login, record)
    end
  end
end
