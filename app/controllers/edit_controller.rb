require 'base64'
require 'git'

require_relative '../models/repository'
require_relative '../models/post'

class EditController < ApplicationController

  before do
    @repo = Repository.new settings.content_dir
  end

  # DESCRIPTION
  # Display a new editor for a given path.
  #
  # PARAMETERS
  # :path   (String) A path somewhere in the content directory. This variable is expected to be
  #                  Base64-encoded.
  #
  # EXPLANATION
  # First, set the path variable. Then check if the path is valid and halt processing if not (rendering
  # an error template). If the path is valid, render the new template.
  get '/new/:path' do
    parent_dir = params[:path]
    halt 400, erb(:error) if reject? parent_dir, empty_allowed: false

    erb :new, :locals => { :parent_dir => parent_dir }
  end

  # DESCRIPTION
  # Display the content of a file in the editor for a given path.
  #
  # PARAMETERS
  # :path   (String) A file somewhere in the content directory. This variable is expected to be
  #                  Base64-encoded.
  #
  # EXPLANATION
  # First, set the path variable. Then check if the path is valid and halt processing if not (rendering
  # an error template). If the path is valid, decode the path and then create a content variable. Then
  # render the edit template.
  get '/:path' do
    path = params[:path]
    halt 400, erb(:error) if reject? path, empty_allowed: false

    post = Post.new(Base64.urlsafe_decode64 path)

    message = (session[:message]) ? get_message(session[:message]) : nil
    session[:message] = nil

    erb :edit, :locals => { :post => post, :flash => message, :error => nil }
  end

  # DESCRIPTION
  # Save the content of the file.
  #
  # EXPLANATION
  # First, set the path variable based on the submitted path parameter. Then check if the path is valid
  # (a path must be provided otherwise the code will be halted). If the path is valid, decode the path
  # and then extract the contents from the parameters hash. Then write the contents to the file. Last
  # redirect to the route for that path.
  #
  # TODO
  # There needs to be some sort of nonce for security.
  post '/save' do
    action = params[:action]
    halt 400, erb(:error) if action != 'create' && action != 'update'

    if action == 'create'
      name = params[:name]
      parent_dir = params[:parent]
      halt 400, erb(:error) if
            reject?(Base64.urlsafe_encode64(name), empty_allowed: false, filename_only: true) ||
            reject?(parent_dir, empty_allowed: false)
      decoded_path = (Base64.urlsafe_decode64 parent_dir) + '/' + name
      encoded_path = Base64.urlsafe_encode64 decoded_path
    elsif action == 'update'
      path = params[:path]
      halt 400, erb(:error) if reject? path, empty_allowed: false
      decoded_path = Base64.urlsafe_decode64 path
      encoded_path = path
    end

    post = Post.new decoded_path
    post.content = params[:content]
    post.save

    @repo.commit post, 'Jonah: User save.'
    session[:message] = :save_ok

    redirect to('/' + encoded_path)
  end

end