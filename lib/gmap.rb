module GoogleMap

  def gmap( options = {} )
    opt = defaults.merge( options ) 
    str = google_script( opt ) + mapdiv( opt  )
    str << gmarker( opt  ) if opt[:marker]
    str
  end
  
  def gmarker( opt = {}  )
    return "gmarker requires ':gmapid' parameter!" if !opt[:gmapid]
    content = opt[:content] ? opt[:content].gsub!( /"/, '\\"' ) : nil
    if ! opt[:address]
      content_tag( :script,
        "google_map_icon_js( #{opt[:gmapid]}, " + 
        "#{opt[:long]},#{opt[:lat]},\"#{content}\", \"#{opt[:icon]}\", \"#{opt[:shadow]}\", \"#{opt[:thumbnail]}\" );",
          { :type => "text/javascript" } ) + "\n"          
    else
      content_tag( :script,
        "google_map_icon_by_adr_js( #{opt[:gmapid]}, " +
        "'#{opt[:address]}',\"#{content}\", \"#{opt[:icon]}\", \"#{opt[:shadow]}\", \"#{opt[:thumbnail]}\" );",
          { :type => "text/javascript" } ) + "\n"                
    end
  end  
  
  def gline( opt = {} )
    return "gmarker requires ':gmapid' parameter!" if !opt[:gmapid]
    content = opt[:content] ? opt[:content] : nil
    line = "google_map_boundary_add_js( bdry, ["
    opt[:line].each do |pnt|
      line << "new GLatLng(#{pnt[1]},#{pnt[0]}),"
    end if opt[:line]
    line.chop!
    line << "] );"
    content_tag( :script, line ,
        { :type => "text/javascript" } ) + "\n"        
  end
  
private

  def defaults
    { :width => "200", 
      :height => "200",
      :long => "-122.01686382293701",
      :lat => "37.31932181336203",
      :zoom => "15",
      :marker => true,
      :key => '',
      :gmapid => 'gmap' + rand(10000).to_s  }
  end
  
  def google_script( opt )
    content_tag( :script, "",
        { :type => "text/javascript",
          :src => "http://maps.google.com/maps?file=api&v=2&key=#{opt[:key]}" } ) + "\n"
  end    
   

  
  def mapdiv( opt )
    div_style = "width:#{opt[:width]}px;height:#{opt[:height]}px;"
    if ! opt[:address]
      embed_script = "var #{opt[:gmapid]} = google_map_js( '#{opt[:gmapid]}', " +
                       "#{opt[:long]},#{opt[:lat]},#{opt[:zoom]} );"
    else
      embed_script = "var #{opt[:gmapid]} = google_map_by_adr_js( '#{opt[:gmapid]}', " +
                       "'#{opt[:address]}',#{opt[:zoom]} );"
    end                                                  
    content_tag( :div, "",
                 { :id => opt[:gmapid],
                   :style => div_style } ) + "\n" +
    content_tag( :script, embed_script, { :type=>"text/javascript" } ) + "\n"
  end   
  
  def content_tag( tag, str, opts = {} )
    out = '<' + tag.to_s 
    opts.each do |k,v|
      out = out + ' ' + k.to_s + '=' + '"' + v + '"'
    end
    out = out +  '>' + str
    return out + '</' + tag.to_s + '>'
  end

end