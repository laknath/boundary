require 'boundary/model'
require 'boundary/controller'

ActionController::Base.extend Boundary::Controller
ActiveRecord::Base.extend Boundary::Model
