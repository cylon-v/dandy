# Don't forget add dependencies
# require './domain/user'
# require './domain/invoice'

module Mapping
  def load_mapping
    JetSet::map do
      # Example:
      #
      # entity User do
      #   field :first_name
      #   field :last_name
      #   field :company
      #   collection :invoices, type: Invoice
      # end
      #
      # entity Invoice do
      #   field :amount
      #   field :date
      #   field :created_at
      #   reference :user, type: User
      # end
    end
  end
end