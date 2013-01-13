extends "comments/commentable"

code :image do |model|
  if model.respond_to? :image
    {
      :src => model.image.url,
      :width => model.width,
      :height => model.height,
    }
  end
end
