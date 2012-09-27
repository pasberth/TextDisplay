require 'paint'
require 'unicode/display_width'
require 'text_display/helpers'

module TextDisplay

  class DecoratedString < String

    extend TextDisplay::Helpers

    ATTRS = [ :string,
              :color,
              :bgcolor,
              :bold,
              :underscore,
              :blink,
              :reverse,
              :concealed ]

    ANSI_COLOR_FG = {
      :black => "30",
      :red => "31",
      :green => "32",
      :yellow => "33",
      :blue => "34",
      :magenta => "35",
      :cyan => "36",
      :white => "37",
      :default => "39"
    }

    ANSI_COLOR_BG = {
      :black => "40",
      :red => "41",
      :green => "42",
      :yellow => "43",
      :blue => "44",
      :magenta => "45",
      :cyan => "46",
      :white => "47",
      :default => "49"}

    ANSI_COLOR_FG_TO_NAME = Hash[*ANSI_COLOR_FG.map { |a, b| [b, a] }.flatten(1)]
    ANSI_COLOR_BG_TO_NAME = Hash[*ANSI_COLOR_BG.map { |a, b| [b, a] }.flatten(1)]

    def self.parse_escape_sequence char
      {}.tap do |attributes|

        split_escape_sequence(char).each do |a|
          case a
          when '0'
            ATTRS.each do |att|
              attributes[att] = nil
            end
          when '1' then attributes[:bold] = true
          when '4' then attributes[:underscore] = true
          when '5' then attributes[:blink] = true
          when '7' then attributes[:reverse] = true
          when '8' then attributes[:concealed] = true
          when '30'..'39' then attributes[:color] = ANSI_COLOR_FG_TO_NAME[a]
          when '40'..'49' then attributes[:bgcolor] = ANSI_COLOR_BG_TO_NAME[a]
          end
        end
      end
    end

    def initialize str = nil, attributes = {}
      str ? super(str) : super()

      attributes.each do |att, val|
        if ATTRS.include? att
          instance_variable_set(:"@#{att}", val)
        else
          raise ArgumentError, "Unexpected attribute: '#{att}' = #{val.inspect}"
        end
      end

      if color or bgcolor or
        bold or underscore or blink or
        reverse or concealed then
        @as_string = Paint[self,
                           *[color ? color : :default,
                             bgcolor ? bgcolor : :default,
                             bold ? :bold : nil,
                             underscore ? :underline : nil,
                             blink ? :blink : nil,
                             reverse ? :inverse : nil,
                             concealed ? :conceal : nil ].compact]
      else
        @as_string = self
      end

      freeze
    end

    ATTRS.each do |a|
      attr_reader a
    end

    def attrs_as_hash
      Hash[*ATTRS.map { |a| [a, instance_variable_get(:"@#{a}")] }.flatten(1)]
    end

    def as_string
      @as_string
    end
  end
end
