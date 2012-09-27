# -*- coding: utf-8 -*-

module TextDisplay

  module Helpers

    def each_escaped_char str, &block
      return enum_for(:each_escaped_char, str) unless block_given?

      str.split(/(?=\e)/).each do |a|
        if a =~ /^\e\[\d*(?<COL>;\d+\g<COL>?)?m/
          e = $~[0]
          a.sub!(e, "")
          yield e
          a.each_char &block
        else
          a.each_char &block
        end
      end

      self
    end

    def split_escaped_chars str
      each_escaped_char(str).to_a
    end

    def split_escape_sequence str

      if str =~ /^\e\[(?<A>\d*)(?<COL>;\d+\g<COL>?)?m/
        a = $~["A"]
        a = '0' if a.empty?
        if $~["COL"]
          b = $~["COL"].split(';')
          b.shift # $~["COL"] は ";x;y..." の形式なのでひとつ落とす
        else
          b = []
        end
        [a, *b]
      else
        []
      end
    end
  end
end
