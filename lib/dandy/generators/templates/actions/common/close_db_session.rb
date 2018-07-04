require 'sequel'
require 'jet_set'

class CloseDbSession
  def initialize(sequel)
    @sequel = sequel
  end

  def call
    @sequel.disconnect
  end
end