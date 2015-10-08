module Spree
  class AddressesController < Spree::StoreController
    helper Spree::AddressesHelper
    rescue_from ActiveRecord::RecordNotFound, :with => :render_404
    load_and_authorize_resource :class => Spree::Address

    def index
      @addresses = spree_current_user.addresses
    end

    def create
      @address = spree_current_user.addresses.build(address_params)
      @address.user = spree_current_user
      if @address.save
        flash[:notice] = Spree.t(:successfully_created, :resource => Spree.t(:address))
        redirect_to account_path
      else
        render :action => "new"
      end
    end

    def show
      redirect_to account_path
    end

    def edit
      session["spree_user_return_to"] = request.env['HTTP_REFERER']
    end

    def new
      @address = Spree::Address.default
    end

    def update
      if @address.editable?
        if @address.update_attributes(address_params)
          flash[:notice] = Spree.t(:successfully_updated, :resource => Spree.t(:address1))
          redirect_back_or_default(account_path)
        else
          render :action => "edit"
        end
      else
        new_address = @address.clone
        new_address.attributes = address_params
        @address.update_attribute(:deleted_at, Time.now)
        if new_address.save
          flash[:notice] = Spree.t(:successfully_updated, :resource => Spree.t(:address1))
          redirect_back_or_default(account_path)
        else
          render :action => "edit"
        end
      end
    end

    def destroy
      spree_current_user.addresses.where(:firstname => @address.firstname, :lastname => @address.lastname, :address1 => @address.address1).update_all(:active => false)
      flash[:notice] = Spree.t(:successfully_removed, :resource => Spree.t(:address1))
      respond_with do |format|
        format.html do
          redirect_to account_path
        end
      end
    end

    private

    def address_params
      params.require(:address).permit(:firstname, :lastname, :full_name, :company, :address1, :address2, :city, :state_id, :state_name, :zipcode, :country_id, :phone, :alternative_phone)
    end
  end
end