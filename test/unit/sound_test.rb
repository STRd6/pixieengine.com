require 'test_helper'

class SoundTest < ActiveSupport::TestCase
  setup do
    @sound = Factory :sound
  end

  context "archiving" do
    should "be archiveable and restoreable" do
      assert_difference "Sound::Archive.count", +1 do
        assert_difference "Sound.count", -1 do
          @sound.destroy
        end
      end

      assert_difference "Sound::Archive.count", -1 do
        assert_difference "Sound.count", +1 do
          Sound.restore_all([ 'id = ?', @sound.id ])
        end
      end
    end
  end
end
