# config.ru

# pull in the helpers and controllers
Dir.glob('./app/controllers/*.rb').each { |file| require file }

# map the controllers to routes
map('/list') { run ListController }
map('/edit') { run EditController }

# Set up the serving of static assets.
use Rack::Static,
  :urls => ["/images", "/javascripts", "/stylesheets"],
  :root => "static"

run lambda { |env|
  [
    200,
    {
      'Content-Type'  => 'text/html',
      'Cache-Control' => 'public, max-age=86400'
    },
    File.open('static/index.html', File::RDONLY)
  ]
}