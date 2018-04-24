class HandleErrors < Dandy::HandleErrors
  def call
    puts @dandy_error
  end
end