Spree::Address.class_eval do
  belongs_to :user, :class_name => Spree.user_class.to_s
  attr_accessor :fullname, :full_name
  before_validation :split_fullname

  def self.active
    where(:active => true)
  end

  def fullname
    if @fullname
      result = @fullname
    elsif lastname && firstname
      if !!(/^[\x00-\x7F]*$/ =~ "#{lastname}#{firstname}")
        result = "#{firstname} #{lastname}"
      else
        result = "#{lastname}#{firstname}"
      end
    end
    result
  end
  alias :full_name :fullname


  def split_fullname
    @fullname ||= @full_name
    if @fullname
      if @fullname.include?(" ")
        # english name split with space
        split = @fullname.split(" ")
        self.lastname = split[1] ? split[1] : "."
        self.firstname = split[0] ? split[0] : "."
      elsif !!(@fullname =~ /\p{Han}/) && @fullname.length >= 3
        # double byte
        self.firstname = @fullname[@fullname.length-2, 2]
        self.lastname = @fullname.gsub(@fullname[@fullname.length-2, 2], "")
      elsif !!(@fullname =~ /\p{Han}/) && @fullname.length == 2
        self.firstname = @fullname[1, 1]
        self.lastname = @fullname[0, 1]
      else
        self.firstname = @fullname
        self.lastname = "."
      end
    end
  end

  def self.required_fields
    Spree::Address.validators.map do |v|
      v.kind_of?(ActiveModel::Validations::PresenceValidator) ? v.attributes : []
    end.flatten
  end

  def same_as?(other)
    return false if other.nil?
    attributes.except('id', 'updated_at', 'created_at', 'alternative_phone') == other.attributes.except('id', 'updated_at', 'created_at', 'alternative_phone')
  end

  # can modify an address if it's not been used in an completed order
  def editable?
    new_record? || !Spree::Order.complete.where("bill_address_id = ? OR ship_address_id = ?", self.id, self.id).exists?
  end

  def to_data
    {
        :"data-full-name" => self.try(:full_name),
        :"data-address1" => self.try(:address1),
        :"data-city" => self.try(:city),
        :"data-district" => self.try(:district),
        :"data-phone" => self.try(:phone),
        :"data-zipcode" => self.try(:zipcode)
    }
  end
end
