class AddToToFailures < ActiveRecord::Migration
  def change
    add_column :failures, :to, :string
  end
end
