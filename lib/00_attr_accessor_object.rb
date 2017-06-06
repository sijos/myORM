class AttrAccessorObject
  def self.my_attr_accessor(*names)
    names.each do |var|
      define_method var do
        self.instance_variable_get("@#{var}")
      end

      define_method("#{var}=") do |value|
        self.instance_variable_set("@#{var}", value)
      end
    end
  end
end
