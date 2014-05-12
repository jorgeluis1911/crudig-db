class App < Sinatra::Application
  
  def existe?(controler)
    if @@config[:tablas].has_key?(controler)
      TRUE
    else
      FALSE
    end
  end

  def listar( tabla='', filas={}, message='',order={}, params={} )
    erb :listar, :locals => {:tabla => tabla, :filas => filas, :message => message,
                              :order => order, :enlaces => @@config[:enlaces],
                              :params => params, :tablas => @@config[:tablas]}
  end
  
  def listar_json( tabla='', filas={}, message='',order={}, params={} )
    global_var = {:tabla => tabla, :filas => filas, :message => message,
                  :order => order, :enlaces => @@config[:enlaces],
                  :params => params, :tablas => @@config[:tablas]}
    return global_var.to_json
  end
    
end