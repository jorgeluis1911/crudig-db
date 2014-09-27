class App < Sinatra::Application

  
  def listar_tabla(app, controler, params, start_limit)
    return unless validController(controler)
    message=''
    
    order = {}
    order[:order] = app.set_order(params)
    order[:grid2_order] = app.set_sub_grid_order(params)
    
    listar(controler, {}, 'No existe el objeto '+controler, order, params) if !existe?(controler)

    filas = app.select_mysql(' * ', controler, params, start_limit)
    
    listar(controler, filas, message, order, params)
  end

  def listar_tabla_json(app, controler, params, start_limit)
    message=''
    puts 'hehe---------'
    
    order = {}
    order[:order] = app.set_order(params)
    order[:grid2_order] = app.set_sub_grid_order(params)
    
    return listar_json(controler, {}, 'No existe el objeto '+controler, order, params) if !existe?(controler)

    filas = app.select_mysql(' * ', controler, params, start_limit)
    
    return listar_json(controler, filas, message, order, params)
  end
    
  def update_id(app, controler, params)
    message=''
    
    actualizado = app.update_mysql(' * ', controler, '', params)
    if(actualizado) 
      message= 'Elemento insertado con éxito.'
    else  message= 'No se pudo insertar el elemento.'
    end
    
    filas = app.select_mysql(' * ', controler, '', '')
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
    
    filas = app.select_mysql(' * ', controler, '', '')    
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
    
    filas = app.select_mysql(' * ', controler, '', '')        
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



  
  def validController(controler)
    valido = false
    
    if(!controler.eql?('config') || !controler.eql?('favicon.ico') || !controler.eql?('js') || !controler.eql?('css'))
      valido = true;
    end    
    return valido    
  end
  
  def existe?(controler)
    if @@config[:tablas].has_key?(controler)
      TRUE
    else
      FALSE
    end
  end
  
  def home_page( message )
    erb :features, :locals => {}
  end

  def view_ayuda(message)
    erb :"help/ayuda", :locals => {:config => @@config[:config],
                       :enlaces => @@config[:enlaces],
                       :message => message}
  end

  def view_configuraciones_demos(message, filas={})
    erb :"demos/listarDemosConfig", :locals => {:config => @@config[:config],
                                   #:tablas => @@config[:tablas],
                                   :configTabla => 'demos_config',
                                   :usersTabla => 'demos_users_config',
                                   :enlaces => @@config[:enlaces],
                                   :filas => filas,
                                   :crudigTablas => @@demosConfig[:tablas],
                                   :idioma => @@demosConfig[:config][:idioma],
                                   :message => message}
  end
      
  def view_configuraciones(message, filas={})
    erb :listarConfig, :locals => {:config => @@config[:config],
                                   #:tablas => @@config[:tablas],
                                   :configTabla => 'configuraciones',
                                   :usersTabla => 'users_config',
                                   :enlaces => @@config[:enlaces],
                                   :filas => filas,
                                   :crudigTablas => @@crudigConfig[:tablas],
                                   :idioma => @@config[:config][:idioma],
                                   :message => message}
  end

  def view_config_demos(message, conexionBDId)
    erb :"demos/demosConfig", :locals => {:config => @@config[:config],
                             :tablas => @@config[:tablas],
                             :enlaces => @@config[:enlaces],
                             :conexionBD => conexionBDId,
                             :idioma => @@config[:config][:idioma],
                             :message => message}
  end
        
  def view_config(message, conexionBDId)
    erb :config, :locals => {:config => @@config[:config],
                             :tablas => @@config[:tablas],
                             :enlaces => @@config[:enlaces],
                             :conexionBD => conexionBDId,
                             :idioma => @@config[:config][:idioma],
                             :message => message}
  end

  def listar( tabla='', filas={}, message='',order={}, params={} )
    erb :listar, :locals => {:tabla => tabla, :filas => filas, :message => message,
                              :order => order, :enlaces => @@config[:enlaces],
                              :params => params, :tablas => @@config[:tablas],
                              :idioma => @@config[:config][:idioma],
                              :traductor => @@idiomas[@@config[:config][:idioma]],
                              :timers => @@config[:timers]}
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
    erb :"#{urlchart}", :locals => { :message => message, :enlaces => @@config[:enlaces],
                                    :params => params, :tablas => @@config[:tablas],
                                    :idioma => @@config[:config][:idioma],
                                    :resultChart => resultChart }
  end
  
  def verJerarquia( tabla='', filas={}, message='',order={}, params={} )

    erb :jerarquia, :locals => {:tabla => tabla, :filas => filas, :message => message,
                                :order => order, :enlaces => @@config[:enlaces],
                                :params => params, :tablas => @@config[:tablas]}
  end    
    
end