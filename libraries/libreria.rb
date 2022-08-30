class App < Sinatra::Application

  
  def is_conexion?()
    
  end
  
  def listar_tabla(app, controler, params, start_limit)
    return unless validController(controler)
    message=''
    
    order = {}
    order[:order] = app.set_order(params)
    order[:grid2_order] = app.set_sub_grid_order(params)
    
    listar(controler, {}, 'No existe el objeto '+controler, order, params) if !existe?(controler)

    filas = app.select_mysql(' * ', controler, params, start_limit, 1)
    
    listar(controler, filas, message, order, params)
  end

  def listar_tabla_json(app, controler, params, start_limit)
    message=''
    puts '--listando JSON----'
    
    order = {}
    order[:order] = app.set_order(params)
    order[:grid2_order] = app.set_sub_grid_order(params)
    
    return listar_json(controler, {}, 'No existe el objeto '+controler, order, params) if !existe?(controler)

    filas = app.select_mysql(' * ', controler, params, start_limit, 1)
    
    return listar_json(controler, filas, message, order, params)
  end
    
  def update_id(app, controler, params)
    message=''
    
    actualizado = app.update_mysql(' * ', controler, '', params)
    if(actualizado) 
      message= 'Elemento insertado con éxito.'
    else  message= 'No se pudo insertar el elemento.'
    end
    
    filas = app.select_mysql(' * ', controler, '', '', 1)
    listar(controler, filas, message, order)        
  end
  
  def update_id_json(app, controler, params)
    message= 'No se pudieron actualizar los datos.'
    result = ''
        
    actualizado = app.update_mysql(' * ', controler, '', params)
    if(actualizado=='')
      message= 'Datos actualizados con éxito.'
      result = '{"valido":"1", "mensaje":"'+message+'"}'
    else  
      result = '{"valido":"0", "mensaje":"'+message+' - '+actualizado+'"}'
    end
    erb result
  end  

  def delete_id(app, controler, params)
    message=''
    
    eliminado = app.delete_mysql(' * ', controler, '')
    if(eliminado) 
      message= 'Elemento eliminado con éxito.'
    else  message= 'No se pudo eliminar el elemento.'
    end
    
    filas = app.select_mysql(' * ', controler, '', '', 1)
    listar(controler, filas, message, order)      
  end

  def delete_id_json(app, controler, params)        
    message= 'No se pudieron eliminar los datos.'
    result = ''
    
    eliminado = app.delete_mysql(' * ', controler, '', params)
    if(eliminado=='') 
      message= 'Datos eliminados con éxito.'
      result = '{"valido":"1", "mensaje":"'+message+'"}'
    else  
      result = '{"valido":"0", "mensaje":"'+message+' - '+actualizado+'"}'
    end
    erb result
  end
    
  def create_id(app, controler, params)
    message=''
    
    creado = app.insert_mysql(' * ', controler, '')
    if(creado)
      message= 'Elemento insertado con éxito.'
    else  message= 'No se pudo insertar el elemento.'
    end
    
    filas = app.select_mysql(' * ', controler, '', '', 1)
    listar(controler, filas, message, order)    
  end
  
  def create_id_json(app, controler, params)
    message= 'No se pudo insertar el elemento.'
    result = ''
    
    creado = app.insert_mysql(params, controler, '')
    if(creado=='')  
      message= 'Elemento insertado con éxito.'
      result = '{"valido":"1", "mensaje":"'+message+'"}'
    else
      result = '{"valido":"0", "mensaje":"'+message+' - '+creado+'"}'
    end
    #puts result 
    erb result
  end  


  def get_listar_tabla_json(app, controler, params, start_limit)
    message=''
    puts '--listando JSON----'
    
    order = {}
    order[:order] = app.set_order(params)
    order[:grid2_order] = app.set_sub_grid_order(params)
    
    #return listar_json(controler, {}, 'No existe el objeto '+controler, order, params) if !existe?(controler)

    return app.select_mysql(' * ', controler, params, start_limit, 1)
  end
    
  def select_demos_config_id(idConfig)
    conexionBDId = {:bd=>"fullcrud",:host=>"127.0.0.1",:user=>"root",:pass=>"",:driver=>"MySQL",:port=>"3306"}

    filas = @@appDemos.simple_select(' * ', ' FROM demos_config ',' Where id_config='+idConfig.to_str,'', '')
    puts filas
    filas.each{ |key, en|
      puts en
      conexionBDId[:bd] = en['bd_name']
      conexionBDId[:host] = en['dominio']
      conexionBDId[:user] = en['bd_user']
      conexionBDId[:pass] = en['bd_passw']
      conexionBDId[:driver] = en['driver']
      conexionBDId[:port] = en['bd_puerto']
    }
    if filas.length >0
      message='<div class="alert alert-success"><p>Configuración encontrada. Modifique los datos y haga click en "Conectar"</p></div>'
    else
      message='<div class="alert alert-danger"><p>La configuración seleccionada no existe.</p></div>'
    end
    view_config_demos(message, conexionBDId)
  end
  
  def select_config_id(idAdmin, idConfig)
    conexionBDId = {:bd=>"fullcrud",:host=>"127.0.0.1",:user=>"root",:pass=>"",:driver=>"MySQL",:port=>"3306"}
    
    filas = @@app.simple_select(' * ', ' FROM configuraciones ',' Where id_config='+idConfig,'', '')
    puts filas
    filas.each{ |key, en|
      puts en
      conexionBDId[:bd] = en['bd_name']
      conexionBDId[:host] = en['dominio']
      conexionBDId[:user] = en['bd_user']
      conexionBDId[:pass] = en['bd_passw']
      conexionBDId[:driver] = en['driver']
      conexionBDId[:port] = en['bd_puerto']
    }
    if filas.length >0
      message='<div class="alert alert-success"><p>Configuración encontrada. Modifique los datos y haga click en "Conectar"</p></div>'
    else
      message='<div class="alert alert-danger"><p>La configuración seleccionada no existe.</p></div>'
    end
    view_config(message, conexionBDId)
  end  



  def save_generatepdf_json(app, controler, params)
    unless @@config[:listados][controler]
      @@config[:listados][controler] = Array.new
    end
    @@config[:listados][controler] << {:nombre=>'', :url=>'', :titulo=>''}
    
    puts @@config[:listados][controler].to_s
    
    result = '{"valido":"1", "mensaje":"Nuevo listado guardado con éxito"}'
    erb result
  end
  
  def default_search_json(app, controler, params)
    unless @@config[:busquedas][controler]
      @@config[:busquedas][controler] = {:defecto =>'', :otras => Array.new }
    end
    @@config[:busquedas][controler][:defecto] = params[:url_busqueda]
    
    puts @@config[:busquedas][controler].to_s
    
    result = '{"valido":"1", "mensaje":"Busqueda por defecto guardada con éxito"}'
    erb result 
  end
    
  def saveSearch_json(app, controler, params)
    unless @@config[:busquedas][controler]
      @@config[:busquedas][controler] = {:defecto=>'', :otras => Array.new }
    end
    @@config[:busquedas][controler][:otras] << {:nombre=> params[:nom_busqueda], :url=> params[:url_busqueda]} 
    
    puts @@config[:busquedas][controler].to_s
    
    result = '{"valido":"1", "mensaje":"Nueva busqueda guardada con éxito"}'
    erb result 
  end

  def generarPDF(app, controler, params)

    result = get_listar_tabla_json(app, controler, params, 0)
    
    pdf = Prawn::Document.new    
    #pdf.margin_box( {:top=>30, :left=>30,:right=>30,:bottom=>30} )
    pdf.font_size 10
    
    pdf.text "Reporte de tabla : "+controler
    pdf.move_down(-10)
    pdf.text "Generado: "+Time.now.to_s , :align => :right
              
    #t = pdf.make_table([ ["this is the first row"],["this is the second row"] ])
    #t.draw
    
    pdf.move_down 20
    
    lista = Array.new
    columns = Array.new
    result[controler].each do |num, row|
      fila = Array.new
      cols = Array.new
      row.each do |col, value|
        fila << value
        cols << col
      end
      lista << fila
      columns << cols
    end

    listado = Array.new
    listado = [columns[0]] + lista
    #puts listado
    pdf.table(listado, :width => 530)
    #pdf.text lista.to_s
    
    #string = "page <page> of <total>"
    string = "página <page> de <total>"
    # Green page numbers 1 to 7
    options = { :at => [pdf.bounds.right - 150, 0],
                :width => 150,
                :align => :right,
                #:page_filter => (1..7),
                :start_count_at => 1,
                :color => "000000" }
    pdf.number_pages string, options
 
    pdf.render_file "public/informes/"+controler+".pdf"

    #t = make_table([ ["this is the first row"],["this is the second row"] ])
    #t.draw
    
    message= 'No se pudieron actualizar los datos.'
    result = ''
        
    if(1==1)
      message= 'Datos actualizados con éxito.'
      result = '{"valido":"1", "mensaje":"'+message+'"}'
    else  
      result = '{"valido":"0", "mensaje":"'+message+' - '+actualizado+'"}'
    end
    
    send_file "public/informes/"+controler+".pdf", :filename => controler+".pdf", :type => "application/pdf"
    
    #erb listado.to_s
  end
  
  def validController(controler)
    valido = false
    
    if(@@config[:tablas][controler] && 
        (!controler.eql?('config') || !controler.eql?('favicon.ico') || 
          !controler.eql?('js') || !controler.eql?('css')))
      valido = true;
    end
    return valido    
  end
  
  def validLanguage(lang)
    valido = false
    lang2 = lang.downcase
    
    # => en = INGLES /  es = ESPAÑOL / fr = FRANCES / de = ALEMAN  / it =ITALIANO / pr =PORTUGUES
      
    if(lang2.eql?('es') || lang2.eql?('en') || lang2.eql?('fr') || 
       lang2.eql?('de') || lang2.eql?('it') || lang2.eql?('pr') )
      
      @@config[:config][:idioma] = lang2
      valido = true;
    end    
    return valido    
  end  
  
  def existe?(controler)
=begin
    if @@config[:tablas].has_key?(controler)
      TRUE
    else
      FALSE
    end
=end
    return @@config[:tablas].has_key?(controler)
  end


  def msgError(texto)
    return '<div class="alert alert-danger"><p>'+texto+'</p></div>'
  end

  def msgOk(texto)
    return '<div class="alert alert-success"><p>'+texto+'</p></div>' 
  end
  
  def msgAviso(texto)
    return '<div class="alert alert-clear"><p>'+texto+'</p></div>'
  end

  
  def home_page( message )
    cleanHtml(erb :features, :locals => {:traductor => @@idiomas[@@config[:config][:idioma]],
                                :idioma => @@config[:config][:idioma]})
  end
  
  def view_features( message )
    cleanHtml(erb :features, :locals => {:config => @@config[:config],
                               :tablas => @@config[:tablas],
                               :enlaces => @@config[:enlaces],
                               :traductor => @@idiomas[@@config[:config][:idioma]],
                               :idioma => @@config[:config][:idioma],
                               :message => message,})
  end
  
  def view_empezar( message )
    cleanHtml(erb :empezar, :locals => {:config => @@config[:config],
                               :tablas => @@config[:tablas],
                               :enlaces => @@config[:enlaces],
                               :message => message,
                               :traductor => @@idiomas[@@config[:config][:idioma]],
                               :idioma => @@config[:config][:idioma]})
  end

  def view_ayuda(message)
    cleanHtml(erb :"help/ayuda", :locals => {:config => @@config[:config],
                                   :tablas => @@config[:tablas],
                                   :enlaces => @@config[:enlaces],
                                   :message => message,
                                   :traductor => @@idiomas[@@config[:config][:idioma]],
                                   :idioma => @@config[:config][:idioma]})
  end
  
  def view_mejoras(message)
    cleanHtml(erb :mejoras, :locals => {:config => @@config[:config],
                               :enlaces => @@config[:enlaces],
                               :message => message,
                               :traductor => @@idiomas[@@config[:config][:idioma]],
                               :idioma => @@config[:config][:idioma],
                               :mejoras => @@config[:mejoras]})
  end  

  def view_configuraciones_demos(message, filas={})
    cleanHtml(erb :"demos/listarDemosConfig", :locals => {:config => @@config[:config],
                                   #:tablas => @@config[:tablas],
                                   :configTabla => 'demos_config',
                                   :usersTabla => 'demos_users_config',
                                   :enlaces => @@config[:enlaces],
                                   :filas => filas,
                                   :crudigTablas => @@demosConfig[:tablas],
                                   :traductor => @@idiomas[@@config[:config][:idioma]],
                                   :idioma => @@demosConfig[:config][:idioma],
                                   :message => message})
  end
      
  def view_configuraciones(message, filas={})
    cleanHtml(erb :listarConfig, :locals => {:config => @@config[:config],
                                   :tablas => @@config[:tablas],
                                   :configTabla => 'configuraciones',
                                   :usersTabla => 'users_config',
                                   :rolesTabla => 'roles',
                                   :enlaces => @@config[:enlaces],
                                   :filas => filas,
                                   :crudigTablas => @@crudigConfig[:tablas],
                                   :traductor => @@idiomas[@@config[:config][:idioma]],
                                   :idioma => @@config[:config][:idioma],
                                   :message => message})
  end

  def view_config_demos(message, conexionBDId)
    cleanHtml(erb :"demos/demosConfig", :locals => {:config => @@config[:config],
                             :tablas => @@config[:tablas],
                             :enlaces => @@config[:enlaces],
                             :conexionBD => conexionBDId,
                             :traductor => @@idiomas[@@config[:config][:idioma]],
                             :idioma => @@config[:config][:idioma],
                             :message => message})
  end
        
  def view_config(message, conexionBDId)    
    cleanHtml(erb :config, :locals => {:config => @@config[:config],
                             :tablas => @@config[:tablas],
                             :enlaces => @@config[:enlaces],
                             :conexionBD => conexionBDId,
                             :traductor => @@idiomas[@@config[:config][:idioma]],
                             :idioma => @@config[:config][:idioma],
                             :message => message})
  end

  def listar( tabla='', filas={}, message='',order={}, params={} )
    cleanHtml(erb :listar, :locals => {:tabla => tabla, :filas => filas, :message => message,
                              :order => order, :enlaces => @@config[:enlaces],
                              :params => params, :tablas => @@config[:tablas],
                              :idioma => @@config[:config][:idioma],
                              :traductor => @@idiomas[@@config[:config][:idioma]],
                              :timers => @@config[:timers],
                              :listados => @@config[:listados],
                              :busquedas => @@config[:busquedas]})
  end
  
  def listar_json( tabla='', filas={}, message='',order={}, params={} )
    global_var = {:tabla => tabla, :filas => filas, :message => message,
                  :order => order, :enlaces => @@config[:enlaces],
                  :params => params, :tablas => @@config[:tablas],
                  :idioma => @@config[:config][:idioma],
                  :graficos => @@config[:graficos]}
    return global_var.to_json
  end
  
  
  
  def viewChart( urlchart , message='', params={} , resultChart={})
    cleanHtml(erb :"#{urlchart}", :locals => { :message => message, :enlaces => @@config[:enlaces],
                                    :params => params, :tablas => @@config[:tablas],
                                    :traductor => @@idiomas[@@config[:config][:idioma]],
                                    :idioma => @@config[:config][:idioma],
                                    :resultChart => resultChart })
  end
  
  def verJerarquia( tabla='', filas={}, message='',order={}, params={} )
    cleanHtml(erb :jerarquia, :locals => {:tabla => tabla, :filas => filas, :message => message,
                                :order => order, :enlaces => @@config[:enlaces],
                                :params => params, :tablas => @@config[:tablas],
                                :traductor => @@idiomas[@@config[:config][:idioma]],
                                :idioma => @@config[:config][:idioma] })
  end
  
  def cleanHtml( html='' )
    html.gsub(/\n+/, '').gsub(/\t+/, '').gsub(Regexp.new(">\\s+<"), '><')
    .gsub(Regexp.new("<!---->|<!--[^\\[].*?-->"), '')
    # => [\s\t\r\n\f]
    
    # => https://github.com/paolochiodi/htmlcompressor/blob/master/lib/htmlcompressor/compressor.rb
  end
    
end