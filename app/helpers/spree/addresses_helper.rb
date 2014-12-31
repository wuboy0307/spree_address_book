module Spree
  module AddressesHelper


    def address_field(form, method, address_id = "b", &handler)
      content_tag :p, :id => [address_id, method].join, :class => "field form-group" do
        if handler
          handler.call
        else
          is_required = Spree::Address.required_fields.include?(method)
          separator = is_required ? '<span class="required">*</span>' : ''
          form.label(method, :class => "label") + separator.html_safe +
              form.text_field(method, :class => is_required ? 'required form-control' : "form-control")
        end
      end
    end

    def address_state(form, country, address_id)
      country ||= Spree::Country.find(Spree::Config[:default_country_id])
      have_states = !country.states.empty?
      state_elements = [
          form.collection_select(:state_id, country.states.order(:name),
                                 :id, :name,
                                 {:include_blank => true},
                                 {:class => have_states ? "required form-control" : "hidden form-control",
                                  :disabled => !have_states}) +
              form.text_field(:state_name,
                              :class => !have_states ? "required form-control" : "hidden form-control",
                              :disabled => have_states)
      ].join.gsub('"', "'").gsub("\n", "")

      form.label(:state, Spree.t(:state)) +
          %Q(<span class="required" id="#{address_id}state-required">*</span>).html_safe +
          content_tag(:noscript, form.text_field(:state_name, :class => 'required')) +
          javascript_tag("document.write(\"#{state_elements.html_safe}\");")
    end


    def address_is_checked(order, address, address_type)
      field = address_type == 'shipping' ? :ship_address_id : :bill_address_id
      selected = order.public_send(field) if order.public_send(field).present?
      return address.id == selected
    end

    # Outputs a checkbox to allow a user to indicate if we should save the address
    # as their default address.
    def save_default_address_check_box
      user = try_spree_current_user # To save a few characters

      # The user model doesn't support saving a default address
      return unless user.respond_to?(:persist_order_address) &&
          user.respond_to?(:ship_address_id) &&
          user.respond_to?(:bill_address_id)

      # For clarity
      has_defaults = user.bill_address_id? && user.ship_address_id?

      # By default don't overwrite their default address
      should_save = false

      # It should save if they don't already have a default
      should_save = true unless has_defaults

      # In general the user should be able to modify this input
      readonly = false

      # If they don't already have a default force them to
      readonly = true unless has_defaults

      # To work around the fact that readonly doesn't really stop a checkbox
      # from being enabled/disabled in HTML
      onclick = 'this.checked=!this.checked' if readonly

      # Build actual UI elements
      label = label_tag :save_user_address, Spree.t(:save_my_address)
      input = check_box_tag 'save_user_address', '1', should_save, readonly: readonly, onclick: onclick

      (input + label).html_safe
    end
  end
end
