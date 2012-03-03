class MakeDisplayNameUnique < ActiveRecord::Migration
  def up
    make_unique = %Q(
      UPDATE users
        SET display_name = users.display_name || users.id
      WHERE users.display_name IN (
        SELECT u.display_name
        FROM users u
        GROUP BY u.display_name
        HAVING COUNT(*) > 1
      )
      AND users.id NOT IN (
        SELECT MIN(id) AS id
        FROM users u
        GROUP BY u.display_name
        HAVING COUNT(*) > 1
      )
    )

    remove_periods = %Q(
      UPDATE users
        SET display_name = replace(display_name, '.', '-')
    )

    ActiveRecord::Base.connection.execute(make_unique)
    ActiveRecord::Base.connection.execute(remove_periods)

    add_index :users, :display_name, :unique => true
  end

  def down
    remove_index :users, :display_name
  end
end
