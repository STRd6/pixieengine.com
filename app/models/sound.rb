class Sound < ActiveRecord::Base
  include Commentable

  has_attached_file :wav, S3_OPTS.merge(
    :path => "sounds/:id/:style.:extension"
  )

  has_attached_file :mp3, S3_OPTS.merge(
    :path => "sounds/:id/:style.:extension"
  )

  validates_attachment_presence :wav

  has_attached_file :sfs, S3_OPTS.merge(
    :path => "sounds/:id/:style.:extension"
  )

  validates_attachment_presence :sfs

  acts_as_archive

  belongs_to :user

  before_validation :convert_to_mp3

  def sfs_base64
    open(sfs.url, "rb") do |f|
      Base64.encode64(f.read())
    end
  end

  def display_name
    if title.blank?
      "Sound #{id}"
    else
      title
    end
  end

  def to_param
    if title.blank?
      id
    else
      "#{id}-#{title.seo_url}"
    end
  end

  def reconvert_to_mp3
    wavfile = Tempfile.new(".wav")
    wavfile.binmode

    open(wav.url) do |f|
      wavfile << f.read
    end

    wavfile.close

    convert_tempfile(wavfile)
  end

  def convert_to_mp3
    tempfile = wav.queued_for_write[:original]

    unless tempfile.nil?
      convert_tempfile(tempfile)
    end
  end

  def convert_tempfile(tempfile)
    padded_file = Tempfile.new(".wav")

    # Pad out sound with silence to make sure it exceeds minimum length required for Chrome browser to play reliably
    cmd_args = ["-m", "-v", "1", File.expand_path(tempfile.path), Rails.root.join("util", "silence.wav").to_s, "-t", "wav", File.expand_path(padded_file.path)]
    system("sox", *cmd_args)

    destination_file = Tempfile.new(".mp3")

    # Convert to mp3
    cmd_args = [File.expand_path(padded_file.path), File.expand_path(destination_file.path)]
    system("lame", *cmd_args)

    destination_file.binmode
    io = StringIO.new(destination_file.read)
    destination_file.close

    io.original_filename = "sound.mp3"
    io.content_type = "audio/mpeg"

    self.mp3 = io
  end
end
