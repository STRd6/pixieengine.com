class MakeDisplayNameUnique < ActiveRecord::Migration
  def up
    query = %Q(
      UPDATE users
        SET display_name = users.display_name || users.id
      WHERE users.display_name IN (
        SELECT u.display_name
        FROM users u
        GROUP BY u.display_name
        HAVING COUNT(*) > 1
      )
    )

    ActiveRecord::Base.connection.execute(query)

    add_index :users, :display_name, :unique => true
  end

  def down
    remove_index :users, :display_name
  end
end
