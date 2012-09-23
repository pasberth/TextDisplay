TextDisplay
=============================

テキストを二次元的に扱うライブラリです。

.. code:: ruby

  require 'text_display'

  title = TextDisplay::Text.new(<<-EOF)
  ########################################
  #                                      #
  ########################################
  EOF

  title.paste!("\e[1mHELLO WORLD\e[0m", 14, 1)

  puts title.as_string(true)

.. code::

  ########################################
  #             HELLO WORLD              #
  ########################################
