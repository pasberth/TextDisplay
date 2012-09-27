# -*- coding: utf-8 -*-
require 'give4each'
require 'text_display/helpers'

module TextDisplay

  class Text

    include TextDisplay::Helpers

    def initialize text = ''
      case text
      when String
        attributes = {}

        @lines = text.lines.map do |line|
          line = line.chomp
          
          each_escaped_char(line).map do |char|

            if char[0] == "\e"
              attributes = attributes.merge(DecoratedString.parse_escape_sequence(char))
              nil
            else
              DecoratedString.new(char, attributes)
            end
          end.compact
        end

        if text[-1] == "\n"
          @lines << []
        end
      when Array
        @lines = text.map(&:clone)
      when Text
        @lines = text.each_line.map(&:clone)
      else raise TypeError, "Can't convert #{text.class} into #{Text}"
      end

      format_lines!
    end

    def as_string color = false
      if color
        each_line.map { |l| l.map(&:as_string).join }.join("\n")
      else
        each_line.map(&:join).join("\n")
      end
    end

    def each_line
      return enum_for(:each_line) unless block_given?

      @lines.each.with_index do |line, i|
        yield line
      end

      self
    end

    def cut_range start, final
      Text.new(each_line.map.with_index do |ln, i|
        case i
        when start...final then ln.map(&:as_string).join
        else nil
        end
      end.compact.join("\n"))
    end

    def crop start_x, start_y, final_x, final_y
      # TODO: 最後に改行を含むべきかどうか決める
      Text.new(cut_range(start_y, final_y).each_line.map do |line|
        [].tap do |cut|
          i = 0

          line.each do |c|
            if i + c.display_width <= start_x
              i += c.display_width
            elsif i + c.display_width <= final_x
              cut << c
              i += c.display_width
            else
              i += c.display_width
            end
          end
        end
      end)
    end

    def delete_char x, y
      @lines[y] && @lines[y].delete_at(x) or nil
    end

    def delete_line lineno
      @lines.delete_at lineno
    end

    def insert! text, x, y
      lines = Text.new(text).each_line.to_a

      # 改行が必要な行の処理
      # 最後の行は改行しない
      # 挿入が1行のみの場合、それが最後の行なので改行しない
      lines[0..-2].each_with_index do |line, i|
        rest = @lines.fetch(y + i) { Array.new(x) }[0...x] || []
        push = @lines.fetch(y + i, [])[x..-1] || []
        @lines[y + i] = rest + line
        @lines.insert(y + i + 1, push)

        x = 0
      end

      i = lines.length - 1
      rest = @lines.fetch(y + i, [])[0...x] || []
      push = @lines.fetch(y + i, [])[x..-1] || []
      @lines[y + i] = rest + lines.last + push

      format_lines!
      nil
    end

    def insert *args
      clone.tap &:insert!.with(*args)
    end

    def overwrite! text, x, y
      lines = Text.new(text).each_line.to_a

      lines[0..-2].each_with_index do |line, i|
        rest = @lines.fetch(y + i) { Array.new(x) }[0...x] || []
        @lines[y + i] = rest + line

        x = 0
      end

      i = lines.length - 1
      rest = @lines.fetch(y + i, [])[0...x] || []
      push = @lines.fetch(y + i, [])[x+lines.last.length..-1] || []
      @lines[y + i] = rest + lines.last + push

      format_lines!
      nil
    end

    def overwrite *args
      clone.tap &:overwrite!.with(*args)
    end

    def paste! text, x, y
      # FIXME: pasteは日本語などの場合 display_width を使う
      # この実装だと文字の数しか見ない
      Text.new(text).each_line.with_index do |line, i|
        (@lines[y + i] ||= [])[x, line.length] = line
      end

      format_lines!
      nil
    end

    def paste *args
      clone.tap &:paste!.with(*args)
    end

    def clone
      cln = super
      lns = @lines.map(&:clone)

      cln.instance_eval do
        @lines = lns
      end

      cln
    end

    private

      def format_lines!
        @lines.each_with_index do |line, i|
          line = line || @lines[i] = []
          line.map! { |a| a ? a : DecoratedString::SPACE }
        end
      end
  end
end
