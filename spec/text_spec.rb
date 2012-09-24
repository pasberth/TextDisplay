# -*- coding: utf-8 -*-

require 'spec_helper'

describe TextDisplay::Text do

  describe "#crop" do

    context do

    subject { described_class.new(<<-STR) }
__@@
..**
,,++
STR

      describe "return value" do
        example { subject.crop(0, 0, 5, 1).should be_kind_of TextDisplay::Text }
      end

      example { subject.crop(0, 0, 3, 1).as_string.should == "__@\n" }
      example { subject.crop(0, 1, 3, 2).as_string.should == "..*\n" }
      example { subject.crop(1, 0, 4, 1).as_string.should == "_@@\n" }
      example { subject.crop(1, 1, 4, 2).as_string.should == ".**\n" }

      example { subject.crop(2, 0, 20, 1).as_string.should == "@@\n" }
      example { subject.crop(0, 2, 3, 20).as_string.should == ",,+\n" }
      
      example { subject.crop(10, 10, 20, 20).as_string.should == "\n" }

      example { subject.crop(0, 0, 3, 3).as_string.should == <<-A }
__@
..*
,,+
A
      
      example { subject.crop(1, 1, 3, 3).as_string.should == <<-A }
.*
,+
A
    end

    context "when that contains a Japanese character" do

    subject { described_class.new(<<-STR) }
ｱｱｱｱｯ
あいうえお
ABCDEF
STR

      example { subject.crop(0, 0, 3, 3).as_string.should == <<-A }
ｱｱｱ
あ
ABC
A
      example { subject.crop(0, 0, 4, 3).as_string.should == <<-A }
ｱｱｱｱ
あい
ABCD
A
      
      example { subject.crop(0, 0, 5, 3).as_string.should == <<-A }
ｱｱｱｱｯ
あい
ABCDE
A
      example { subject.crop(0, 0, 6, 3).as_string.should == <<-A }
ｱｱｱｱｯ
あいう
ABCDEF
A
      example { subject.crop(1, 0, 5, 3).as_string.should == <<-A }
ｱｱｱｯ
あい
BCDE
A
      example { subject.crop(2, 0, 5, 3).as_string.should == <<-A }
ｱｱｯ
い
CDE
A

    end
  end

  describe "#paste" do

    subject { described_class.new(<<-STR) }
###
###
###
STR

    describe "return value" do

      example { subject.paste("@@@", 0, 0).should be_kind_of TextDisplay::Text }
    end

    describe "site effect" do

      example do
        subject.paste("@@@", 0, 0)
        subject.as_string.should == "###\n###\n###\n"
      end
    end

    shared_examples_for "an object as a text" do

      example { subject.paste(horizontal_dot_line, 0, 0).as_string.should == <<-A }
...
###
###
A
      example { subject.paste(horizontal_dot_line, 0, 1).as_string.should == <<-A }
###
...
###
A
      example { subject.paste(vertical_dot_line, 0, 0).as_string.should == <<-A }
.##
.##
.##
A
      example { subject.paste(vertical_dot_line, 1, 0).as_string.should == <<-A }
#.#
#.#
#.#
A
      example { subject.paste(dot_box, 0, 0).as_string.should == <<-A }
..#
..#
###
A
      example { subject.paste(dot_box, 1, 0).as_string.should == <<-A }
#..
#..
###
A
      example { subject.paste(dot_box, 0, 1).as_string.should == <<-A }
###
..#
..#
A
      example { subject.paste(dot_box, 1, 1).as_string.should == <<-A }
###
#..
#..
A
      example { subject.paste(dot_box, 2, 2).as_string.should == <<-A.chomp }
###
###
##..
  ..
A

      example { subject.paste(dot_box, 4, 4).as_string.should == <<-A.chomp }
###
###
###

    ..
    ..
A
    end

    it_behaves_like "an object as a text" do
      let(:horizontal_dot_line) { "..." }
      let(:vertical_dot_line) { ".\n.\n." }
      let(:dot_box) { "..\n.." }
    end

    it_behaves_like "an object as a text" do
      let(:horizontal_dot_line) { described_class.new("...") }
      let(:vertical_dot_line) { described_class.new(".\n.\n.") }
      let(:dot_box) { described_class.new("..\n..") }
    end
  end


  describe "#insert" do

    let(:horizontal_dot_line) { "..." }
    let(:vertical_dot_line) { ".\n.\n." }
    let(:dot_box) { "..\n.." }

    subject { described_class.new(<<-STR) }
###
###
###
STR

    describe "return value" do

      example { subject.insert("@@@", 0, 0).should be_kind_of TextDisplay::Text }
    end

    describe "site effect" do

      example do
        subject.insert("@@@", 0, 0)
        subject.as_string.should == "###\n###\n###\n"
      end
    end

    example { subject.insert(horizontal_dot_line, 0, 0).as_string.should == <<-A }
...###
###
###
A
    example { subject.insert(horizontal_dot_line, 0, 1).as_string.should == <<-A }
###
...###
###
A
    example { subject.insert(vertical_dot_line, 0, 0).as_string.should == <<-A }
.
.
.###
###
###
A
    example { subject.insert(vertical_dot_line, 1, 0).as_string.should == <<-A }
#.
.
.##
###
###
A
      example { subject.insert(dot_box, 0, 0).as_string.should == <<-A }
..
..###
###
###
A
    example { subject.insert(dot_box, 1, 0).as_string.should == <<-A }
#..
..##
###
###
A
    example { subject.insert(dot_box, 0, 1).as_string.should == <<-A }
###
..
..###
###
A
    example { subject.insert(dot_box, 1, 1).as_string.should == <<-A }
###
#..
..##
###
A
    example { subject.insert(dot_box, 2, 2).as_string.should == <<-A }
###
###
##..
..#
A

      example { subject.insert(dot_box, 4, 4).as_string.should == <<-A.chomp }
###
###
###

    ..
..
A
  end

  describe "#overwrite" do

    let(:horizontal_dot_line) { "..." }
    let(:newline) { "\n" }
    let(:vertical_dot_line) { ".\n.\n." }
    let(:dot_box) { "..\n.." }

    subject { described_class.new(<<-STR) }
###
###
###
STR

    describe "return value" do

      example { subject.overwrite("@@@", 0, 0).should be_kind_of TextDisplay::Text }
    end

    describe "site effect" do

      example do
        subject.overwrite("@@@", 0, 0)
        subject.as_string.should == "###\n###\n###\n"
      end
    end

    example { subject.overwrite("\n", 0, 0).as_string.should == <<-A }

###
###
A
    example { subject.overwrite("..\n", 0, 0).as_string.should == <<-A }
..
###
###
A

    example { subject.overwrite("..", 0, 0).as_string.should == <<-A }
..#
###
###
A
    example { subject.overwrite(horizontal_dot_line, 0, 0).as_string.should == <<-A }
...
###
###
A
    example { subject.overwrite(horizontal_dot_line, 0, 1).as_string.should == <<-A }
###
...
###
A
    example { subject.overwrite(".\n.", 0, 0).as_string.should == <<-A }
.
.##
###
A
    example { subject.overwrite(".\n.\n", 0, 0).as_string.should == <<-A }
.
.
###
A
    example { subject.overwrite(vertical_dot_line, 0, 0).as_string.should == <<-A }
.
.
.##
A
    example { subject.overwrite(vertical_dot_line, 1, 0).as_string.should == <<-A }
#.
.
.##
A
      example { subject.overwrite(dot_box, 0, 0).as_string.should == <<-A }
..
..#
###
A
    example { subject.overwrite(dot_box, 1, 0).as_string.should == <<-A }
#..
..#
###
A
    example { subject.overwrite(dot_box, 0, 1).as_string.should == <<-A }
###
..
..#
A
    example { subject.overwrite(dot_box, 1, 1).as_string.should == <<-A }
###
#..
..#
A
    example { subject.overwrite(dot_box, 2, 2).as_string.should == <<-A.chomp }
###
###
##..
..
A

      example { subject.overwrite(dot_box, 4, 4).as_string.should == <<-A.chomp }
###
###
###

    ..
..
A
  end
end
