PixieStrd6Com::Application.config.middleware.use Rack::Cors do
  allow do
    origins '*'
    resource "*",
      :headers => ['Origin', 'Accept', 'Content-Type'],
      :methods => [:get, :post, :options]
  end
end
