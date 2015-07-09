module Spree
  CheckoutController.class_eval do
    helper Spree::AddressesHelper

    before_action :load_addresses, :only => :update

    def load_addresses
      @addresses = spree_current_user ? spree_current_user.addresses.active.to_a.uniq{|a| "#{a.full_name}-#{a.address1}"} : []
    end
  end
end