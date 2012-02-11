module Sanitization
  def sanitize(text)
    Sanitize.clean(text, :elements => ['a', 'img', 'em', 'strong', 'pre', 'code', 'hr', 'ul', 'li', 'ol', 'h1', 'h2', 'h3', 'h4', 'h5', 'h6', 'u', 'p'],
      :attributes => {
        'a' => ['href', 'title', 'target'],
        'img' => ['src']
      },
      :protocols => {
        'a' => {'href' => ['http', 'https', 'mailto']},
        'img' => {'src' => ['http', 'data']}
      }
    )
  end
end
