require 'paint'
require 'unicode/display_width'

module TextDisplay

  class DecoratedString < String

    ATTRS = [ :string,
              :color,
              :bgcolor,
              :bold,
              :underscore,
              :blink,
              :reverse,
              :concealed ]

    def initialize str = nil, attributes = {}
      str ? super(str) : super()
    end

    ATTRS.each do |a|
      attr_reader a
    end

    def attrs_as_hash
      Hash[*ATTRS.map { |a| [a, instance_variable_get(:"@#{a}")] }.flatten(1)]
    end

    def as_string
      Paint[String.new(self),
            *[color ? color : :default,
              bgcolor ? bgcolor : :default,
              bold ? :bold : nil,
              underscore ? :underline : nil,
              blink ? :blink : nil,
              reverse ? :inverse : nil,
              concealed ? :conceal : nil ].compact]
    end
  end
end
