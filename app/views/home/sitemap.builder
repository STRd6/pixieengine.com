xml.instruct!

xml.urlset "xmlns" => "http://www.google.com/schemas/sitemap/0.84" do
  xml.url do
    xml.loc         "http://pixie.strd6.com/"
    xml.lastmod     w3c_date(Time.now)
    xml.changefreq  "always"
  end

  1.upto(@sprite_pages_count) do |page|
    xml.url do
      xml.loc         url_for(:only_path => false, :controller => 'sprites', :action => 'index', :page => page)
      xml.lastmod     w3c_date(Time.now)
      xml.changefreq  "daily"
      xml.priority    0.9
    end
  end

  @users.each do |user|
    xml.url do
      xml.loc         url_for(:only_path => false, :controller => 'users', :action => 'show', :id => user.id)
      xml.lastmod     w3c_date(user.updated_at)
      xml.changefreq  "weekly"
      xml.priority    0.7
    end
  end

  @sprites.each do |sprite|
    xml.url do
      xml.loc         url_for(:only_path => false, :controller => 'sprites', :action => 'show', :id => sprite.id)
      xml.lastmod     w3c_date(sprite.updated_at)
      xml.changefreq  "weekly"
      xml.priority    0.6
    end
  end
end
