class AddReferenceToTickets < ActiveRecord::Migration[5.2]
  def change
    add_column :tickets, :payment_reference, :string
  end
end
