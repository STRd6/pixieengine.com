extends "comments/commentable"

code :image do |model|
  if model.respond_to? :image
    {
      :src => model.image.url(:thumb),
      :width => 96,
      :height => 96,
    }
  end
end
