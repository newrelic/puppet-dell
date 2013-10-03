Puppet::Type.newtype(:drac_setting) do

  def self.title_patterns
    identity = lambda { |x| x }
    [
      [ /^([A-Za-z\.]+)\/(\d+)\/(\w+)$/,
        [
          [:group, identity],
          [:object_index, identity],
          [:object_name, identity]
        ]
      ],
      [ /^([A-Za-z0-9\.]+)\/(\w+)$/,
        [
          [:group, identity],
          [:object_name, identity]
        ]
      ],
    ]
  end

  newparam(:group, :namevar => true) do
    desc "The configuration group"
    validate do |value|
      unless value =~ /^\w+/
        raise ArgumentError, "%s is not a valid configuration group" % value
      end
    end
  end

  newparam(:object_name, :namevar => true) do
    desc "The configuration object name"
    validate do |value|
      unless value =~ /^\w+/
        raise ArgumentError, "%s is not a valid configuration object name" % value
      end
    end
  end

  newparam(:object_index, :namevar => true) do
    desc "For indexed objects, the index you want"
    validate do |value|
      unless value =~ /\d+/
        raise ArgumentError, "%s is not an integer" % value
      end
    end
  end

  newproperty(:object_value) do
    desc "The value of the configuration object"
  end
end
