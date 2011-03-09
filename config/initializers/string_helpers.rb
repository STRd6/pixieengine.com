class String
  def seo_url
    downcase.gsub(/[^[:alnum:]]/, '-').gsub(/-{2,}/, '-').gsub(/\A-/, '').gsub(/-\Z/, '')
  end

  def to_filename(extension=nil)
    name = underscore.gsub(" ", '_').gsub(/[^A-Za-z0-9_\.-]/, '')

    if extension
      name = "#{name}.#{extension}" unless name.ends_with?(".#{extension}")
    end

    name
  end
end
