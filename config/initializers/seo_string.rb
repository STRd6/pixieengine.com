class String
  def seo_url
    downcase.gsub(/[^[:alnum:]]/, '-').gsub(/-{2,}/, '-').gsub(/\A-/, '').gsub(/-\Z/, '')
  end
end
