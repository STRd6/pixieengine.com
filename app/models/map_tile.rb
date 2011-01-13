class MapTile < ActiveRecord::Base
  belongs_to :tilemap
  belongs_to :sprite
end
