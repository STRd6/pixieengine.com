class UpdateUsersTable < ActiveRecord::Migration[5.0]
  def change
    enable_extension 'citext'

    User.delete([
      9,
      10,
      98,
      757,
      842,
      1102,
      1103,
      1113,
      1194,
      1496,
      1627,
      1707,
      1745,
      3341,
      4569,
    ])

    duplicate_names = User.select("LOWER(display_name) AS disp").group("LOWER(display_name)").having("count(*) > 1").map(&:disp)
    User.select("LOWER(display_name) AS disp", :id, :display_name).where(["LOWER(display_name) in (?)", duplicate_names]).group_by do |u|
      u.display_name.downcase
    end.map do |name, user_set|
      user_set.sort_by(&:id)
    end.each do |user_set|
      # First guy gets to keep
      user_set.shift
      # Rest get a suffix
      user_set.each do |user|
        user.update_column(:display_name, "#{user.display_name}-#{user.id}")
      end
    end

    remove_column :users, "paying", :boolean, default: false, null: false
    remove_column :users, "forem_admin", :boolean, default: false, null: false
    remove_column :users, "forum_notifications", :booloan, default: true, null: false
    remove_column :users, "help_tips", :boolean, default: true, null: false
    remove_column :users, "spreedly_token", :string, limit: 255

    change_column :users, :email, :citext, null: false
    change_column :users, :display_name, :citext, null: false

    add_index :users, :email, unique: true
    add_index :users, :perishable_token, unique: true

  end
end
