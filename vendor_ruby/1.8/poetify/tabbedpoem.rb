
# to mix in think of it as -able

# to use as a namespace just mod::

module TabbedPoem
  
  # use snake_case
  require File.here 'commonpoem'
  include CommonPoem

  #
  # used by save
  #
  def self.poem_body params
    poem_hash = {}
    params.each do |x|
      if x[0].start_with? "poem"
        poem_hash[x[0].to_sym] = x[1]
      end
    end
    poem_hash
  end
  
  def self.render
    :play_with_tabbed
  end
  
  #
  # used by edit and play
  #
  def self.javascriptify verse
    v = verse # trailing whitespace is stripped
    v.gsub!(/\r\n/, "\n") # turn CR+LF into newline
    # not at the moment
    # v.gsub!(/\/\//, "\n") # turn // into newline
    #
    v.rstrip!
    v.lstrip!
    w = ''
    v.split("\n").each do |line|
      w += line # for clarity
      w += "\\" # backslash
      w += "n"  # + n for newline in the multiline javascript string
      w += "\\" # single backslash before actual newline in document
      w += "\n" # actual newline (which split rightly discards)
    end
    w
  end
  
  # title, version & id come from commonpoem
  
  #
  # used by rhtml
  #
  def poems
    poem_hash = TabbedPoem::poem_body @request.POST()
    poems = ''
    sorted = poem_hash.keys.map {|x| x.to_s}.sort
    sorted.each_with_index do |x,j|
      poems <<= "\nfigure.poems["+j.to_s+"] = fn_poem"+j.to_s+"();"
      poems <<= "\nfigure.titles["+j.to_s+'] = "'+title+'";'
    end
    poems <<= "\nfigure.max = "+sorted.length.to_s+';'
    "uhuh\n//"+poems
  end
  
  def poem_functions
    # wrong place for this, should use @input
    poem_hash = TabbedPoem::poem_body @request.POST()
    poems = ''
    poem_hash.keys.map {|x| x.to_s}.sort.each_with_index do |x,j|
      each_poem = poem_hash[x.to_sym]
      # need to escape quotes, here and elsewhere
      poems <<= "\nfunction fn_poem"+j.to_s+"() {\n"+'  return "'+(@e_poem_module::javascriptify each_poem)+'";'+"\n}"
    end
    "ahah\n//"+poems
  end
end