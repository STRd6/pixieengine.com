class Lead < ActiveRecord::Base
  def as_json(options={})
    {
      :created_at => created_at
    }
  end
end
