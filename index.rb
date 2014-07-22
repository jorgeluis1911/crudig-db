require 'sinatra'
#require 'dbi'
require 'mysql'
require 'pg'
require 'json'
#require 'sqlite'

#$db = SQLite3::Database.new( "entornos.db" )

class App < Sinatra::Application

  configure do
    #set :sessions, true
    #set :foo, 'bar'
    #set :views, :erb => '../views'
    #set :sessions, true
    #set :entornos, []
  end
  
  @@app = ''
  @@filas = Hash.new
  @@config = {:config => {:idioma=>"es",:bd=>"",:host=>"",:user=>"",:pass=>"",:driver=>"",:port=>""}, 
                  :tablas => {},
                  :enlaces => [],
                  :graficos => {},
                  :timers => {} }
                  #:enlaces => {'1'=>'usuarios','2'=>'fotos','3'=>'entorno'} }
  
  $id_entorno = 0

  get '/' do
    mensaje='<h1>Bienvenidos a nuestra App de facil mantenimiento de tus Bases de Datos</h1>'
    home_page(mensaje)
  end
  
  get '/caracteristicas' do 
    message = ''
    erb :features, :locals => {:config => @@config[:config],
                             :tablas => @@config[:tablas],
                             :enlaces => @@config[:enlaces],
                             :message => message,}    
  end
  
  get '/caracteristicas/' do
    redirect "/caracteristicas"
  end  
  
  # =>    rutas para los graficos
  get '/chartArea' do
    message = ''
    
    viewChart( 'charts/area', message, {}, {})
  end
    
  get '/chartBar' do 
    message = ''
    
    viewChart( 'charts/barras', message, {}, {})
  end
  
  get '/chartCircle' do
    viewChart( 'charts/circle', '', {}, {})
  end

  get '/chartCircle/testingChart' do
    message = ''
    results = @@app.testingCircle( params ) if params[:testing]
    viewChart( 'charts/circle', message, {}, results)
  end
  
  get '/chartColumn' do
    message = ''
    
    viewChart( 'charts/column', message, {}, {})    
  end

  get '/chartCombo' do
    message = ''
    
    viewChart( 'charts/combo', message, {}, {})    
  end

  get '/chartLine' do
    message = ''
    
    viewChart( 'charts/line', message, {}, {})
  end

  get '/mycharts' do
    message = ''
    
    viewChart( 'charts/misgraficos', message, {}, {}) 
  end
          
  # =>    final de rutas para los graficos
  
  get '/jerarquiaUp/:tabla' do |tabla|
    message = ''
    results = @@app.jerarquia("Up", params, tabla) if (@@config[:tablas][tabla])
    verJerarquia( tabla, results, message, {}, params)
  end
  
  get '/jerarquiaDown/:tabla' do |tabla|
    message = ''
    results = @@app.jerarquia("Down", params, tabla) if (@@config[:tablas][tabla])
    verJerarquia( tabla, results, message, {}, params)    
  end  


  get '/refrescar/:tabla' do |tabla|
    @@config[:timers] = {}
    
    redirect '/refrescar/'+tabla+'/0'
  end
  
  get '/refrescar/:tabla/:segundos' do |tabla, segundos|
    
    if(!tabla.eql?('config') || !tabla.eql?('favicon.ico'))
      case segundos
      when nil, '0', ''  then
        @@config[:timers].delete(tabla) if (@@config[:timers][tabla])
      else
        segundos = segundos.to_i
        if(segundos > 9 && segundos < 50)
          timer = Hash.new
          timer[:segundos] = segundos
          timer[:inicio] = ''
          timer[:final] = ''
          @@config[:timers][tabla] = timer
        end
      end
      
      redirect '/'+tabla+'/listar'
    end
  end
  
    
  get '/config' do 
    message = ''
    erb :config, :locals => {:config => @@config[:config],
                             :tablas => @@config[:tablas],
                             :enlaces => @@config[:enlaces],
                             :message => message,}    
  end
  
  get '/config/' do
    redirect '/config'
  end
    
  post '/config/conectar' do
    message = ''
    
    case params[:driver]
    when 'Mysql', 'MariaDB'  then 
      @@app = MySQLconex.new @@config
      message= @@app.load_bd_MySQL( params[:driver], params[:dominio], params[:usuario], params[:pass], params[:bd], params[:port])
    when 'Postgress' then
      @@app = PSqlconex.new @@config
      message= @@app.load_bd_PS( params[:driver], params[:dominio], params[:usuario], params[:pass], params[:bd], params[:port])
    when 'SQLServer' 
    when 'Oracle'  
    else  message = '<div class="alert alert-danger"><p>Tiene que especificar todos los parametros de conexión</p></div>'
    end
    
    erb :config, :locals => {:config => @@config[:config],
                             :tablas => @@config[:tablas],
                             :enlaces => @@config[:enlaces],
                             :message => message,}
  end
  
  post '/config/edit_table' do
    message = ''
    
    @@app.save_config_table(@@config[:tablas], params)
    
    erb :config, :locals => {:config => @@config[:config],
                             :tablas => @@config[:tablas],
                             :enlaces => @@config[:enlaces],
                             :message => message,}    
  end
  
  get '/:controler' do |controler|
    redirect "/#{controler}/listar" unless (controler.eql?('config') || controler.eql?('favicon.ico'))
  end
    
  get '/:controler/' do |controler|
    redirect "/#{controler}/listar" unless (controler.eql?('config') || controler.eql?('favicon.ico'))
  end
  
  get '/:controler/:funcion' do |controler, funcion|
    order = ''
    search = ''

    if(!controler.eql?('config') || !controler.eql?('favicon.ico'))
      case funcion
      when 'create'      then create_id(controler, params)
      when 'create_json' then create_id_json(controler, params)
      else listar_tabla(controler, params, 0)
      end
    end
  end
  
  post '/:controler/:funcion' do |controler, funcion|
    order = ''
    search = ''

    if(!controler.eql?('config') || !controler.eql?('favicon.ico'))
      puts '----hehe---------'
      listar_tabla_json(controler, params, 0)
    end
  end  
  
  get '/:controler/:funcion/:id' do |controler, funcion, id|
    if(!controler.eql?('config') || !controler.eql?('favicon.ico'))
      case funcion
      when 'update'      then update_id(controler, id, params)
      when 'update_json' then update_id_json(controler, id, params)
      when 'delete'      then delete_id(controler, id, params)
      when 'delete_json' then delete_id_json(controler, id, params)
      else listar_tabla(controler, params, id)
      end
    end
  end
  
  post '/:controler/:funcion/:id' do |controler, funcion, id|
    if(!controler.eql?('config') || !controler.eql?('favicon.ico'))
      listar_tabla_json(controler, params, id)
    end
  end
  
  def listar_tabla(controler, params, start_limit)
    message=''
    
    order = {}
    order[:order] = @@app.set_order(params)
    order[:grid2_order] = @@app.set_sub_grid_order(params)
    
    listar(controler, {}, 'No existe el objeto '+controler, order, params) if !existe?(controler)

    filas = @@app.select_mysql(' * ', controler, params, start_limit)
    
    listar(controler, filas, message, order, params)
  end

  def listar_tabla_json(controler, params, start_limit)
    message=''
    puts 'hehe---------'
    
    order = {}
    order[:order] = @@app.set_order(params)
    order[:grid2_order] = @@app.set_sub_grid_order(params)
    
    return listar_json(controler, {}, 'No existe el objeto '+controler, order, params) if !existe?(controler)

    filas = @@app.select_mysql(' * ', controler, params, start_limit)
    
    return listar_json(controler, filas, message, order, params)
  end
    
  def update_id(controler, id, params)
    message=''
    
    actualizado = @@app.update_mysql(' * ', controler, '')
    if(actualizado) 
      message= 'Elemento insertado con éxito.'
    else  message= 'No se pudo insertar el elemento.'
    end
    
    filas = @@app.select_mysql(' * ', controler, '', '')
    listar(controler, filas, message, order)        
  end
  
  def update_id_json(controler, id, params)
    message=''
    
    actualizado = @@app.update_mysql(' * ', controler, '')
    if(actualizado) 
      message= 'Elemento insertado con éxito.'
    else  message= 'No se pudo insertar el elemento.'
    end
    
    return {"valido" => "0", "mensaje" => message}
  end  

  def delete_id(controler, id, params)
    message=''
    
    eliminado = @@app.delete_mysql(' * ', controler, '')
    if(eliminado) 
      message= 'Elemento eliminado con éxito.'
    else  message= 'No se pudo eliminar el elemento.'
    end
    
    filas = @@app.select_mysql(' * ', controler, '', '')    
    listar(controler, filas, message, order)      
  end

  def delete_id_json(controler, id, params)
    message=''
    
    eliminado = @@app.delete_mysql(' * ', controler, '')
    if(eliminado) 
      message= 'Elemento eliminado con éxito.'
    else  message= 'No se pudo eliminar el elemento.'
    end
    
    return {"valido" => "0", "mensaje" => message}
  end
    
  def create_id(controler, params)
    message=''
    
    creado = @@app.insert_mysql(' * ', controler, '')
    if(creado)
      message= 'Elemento insertado con éxito.'
    else  message= 'No se pudo insertar el elemento.'
    end
    
    filas = @@app.select_mysql(' * ', controler, '', '')        
    listar(controler, filas, message, order)    
  end
  
  def create_id_json(controler, params)
    message= 'No se pudo insertar el elemento.'
    result = ''
    
    creado = @@app.insert_mysql(params, controler, '')
    if(creado=='')  
      message= 'Elemento insertado con éxito.'
      result = '{"valido":"1", "mensaje":"'+message+'"}'
    else
      result = '{"valido":"0", "mensaje":"'+message+' - '+creado+'"}'
    end
    #puts result 
    erb result
  end  
  
end

require_relative 'libraries/libreria'
require_relative 'models/init'
#require_relative 'controllers/init'