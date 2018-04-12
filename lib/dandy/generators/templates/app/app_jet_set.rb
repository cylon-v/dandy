require 'dandy'
require 'jet_set'
require './db/mapping'

class App < Dandy::App
  include Mapping

  def initialize(container = Hypo::Container.new)
    super(container)

    JetSet::init(load_mapping, container)
  end
end