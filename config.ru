# config.ru

# pull in the helpers and controllers
Dir.glob('./app/controllers/*.rb').each { |file| require file }

# map the controllers to routes
map('/list') { run ListController }
map('/edit') { run EditController }
