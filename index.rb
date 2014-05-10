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
  
  @@conexion = ''
  @@filas = Hash.new
  @@aplicacion = {:config => {:idioma => "es", :bd => "", :host => "", :user => "", :password => ""}, 
                  :tablas => {},
                  :enlaces => [] }
                  #:enlaces => {'1'=>'usuarios','2'=>'fotos','3'=>'entorno'} }
  
  $id_entorno = 0

  get '/' do
    mensaje='<h1>Bienvenidos a nuestra App de facil mantenimiento de tus Bases de Datos</h1>'
    listar('', {}, mensaje, '')
  end


  get '/config' do 
    message = ''
    erb :config, :locals => {:config => @@aplicacion[:config],
                             :tablas => @@aplicacion[:tablas],
                             :enlaces => @@aplicacion[:enlaces],
                             :message => message,}    
  end
  
  get '/config/' do
    redirect "/config"
  end
  
  get '/caracteristicas' do 
    message = ''
    erb :features, :locals => {:config => @@aplicacion[:config],
                             :tablas => @@aplicacion[:tablas],
                             :enlaces => @@aplicacion[:enlaces],
                             :message => message,}    
  end
  
  get '/caracteristicas/' do
    redirect "/caracteristicas"
  end  
  
  get '/graficos' do 
    message = ''
    erb :graficos, :locals => {:config => @@aplicacion[:config],
                             :tablas => @@aplicacion[:tablas],
                             :enlaces => @@aplicacion[:enlaces],
                             :message => message,}    
  end
  
  get '/graficos/' do
    redirect "/graficos"
  end
  
  post '/config/conectar' do
    message = ''
    
    case params[:driver]
    when 'Mysql'    then
      message= load_bd( params[:driver], params[:dominio], params[:usuario], params[:pass], params[:bd], params[:port])
    when 'MariaDB'  then 
      message= load_bd( params[:driver], params[:dominio], params[:usuario], params[:pass], params[:bd], params[:port])
    when 'Postgress' 
    when 'SQLServer' 
    when 'Oracle'  
    else  message = '<div class="alert alert-danger"><p>Tiene que especificar todos los parametros de conexión</p></div>'
    end
    #load_bd('','','','')
    erb :config, :locals => {:config => @@aplicacion[:config],
                             :tablas => @@aplicacion[:tablas],
                             :enlaces => @@aplicacion[:enlaces],
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
    order[:order] = set_order(params)
    order[:grid2_order] = set_sub_grid_order(params)
    
    listar(controler, {}, 'No existe el objeto '+controler, order, params) if !existe?(controler)

    filas = select_mysql(' * ', controler, params, start_limit)
    
    listar(controler, filas, message, order, params)
  end

  def listar_tabla_json(controler, params, start_limit)
    message=''
    puts 'hehe---------'
    
    order = {}
    order[:order] = set_order(params)
    order[:grid2_order] = set_sub_grid_order(params)
    
    return listar_json(controler, {}, 'No existe el objeto '+controler, order, params) if !existe?(controler)

    filas = select_mysql(' * ', controler, params, start_limit)
    
    return listar_json(controler, filas, message, order, params)
  end
    
  def update_id(controler, id, params)
    message=''
    
    actualizado = update_mysql(' * ', controler, '')
    if(actualizado) 
      message= 'Elemento insertado con éxito.'
    else  message= 'No se pudo insertar el elemento.'
    end
    
    filas = select_mysql(' * ', controler, '', '')
    listar(controler, filas, message, order)        
  end
  
  def update_id_json(controler, id, params)
    message=''
    
    actualizado = update_mysql(' * ', controler, '')
    if(actualizado) 
      message= 'Elemento insertado con éxito.'
    else  message= 'No se pudo insertar el elemento.'
    end
    
    return {"valido" => "0", "mensaje" => message}
  end  

  def delete_id(controler, id, params)
    message=''
    
    eliminado = delete_mysql(' * ', controler, '')
    if(eliminado) 
      message= 'Elemento eliminado con éxito.'
    else  message= 'No se pudo eliminar el elemento.'
    end
    
    filas = select_mysql(' * ', controler, '', '')    
    listar(controler, filas, message, order)      
  end

  def delete_id_json(controler, id, params)
    message=''
    
    eliminado = delete_mysql(' * ', controler, '')
    if(eliminado) 
      message= 'Elemento eliminado con éxito.'
    else  message= 'No se pudo eliminar el elemento.'
    end
    
    return {"valido" => "0", "mensaje" => message}
  end
    
  def create_id(controler, params)
    message=''
    
    creado = insert_mysql(' * ', controler, '')
    if(creado)
      message= 'Elemento insertado con éxito.'
    else  message= 'No se pudo insertar el elemento.'
    end
    
    filas = select_mysql(' * ', controler, '', '')        
    listar(controler, filas, message, order)    
  end
  
  def create_id_json(controler, params)
    message= 'No se pudo insertar el elemento.'
    result = ''
    
    creado = insert_mysql(params, controler, '')
    if(creado=='')  
      message= 'Elemento insertado con éxito.'
      result = '{"valido":"1", "mensaje":"'+message+'"}'
    else
      result = '{"valido":"0", "mensaje":"'+message+' - '+creado+'"}'
    end
    puts result 
    erb result
  end  
  
end

require_relative 'libraries/aplicacion'
require_relative 'models/init'
#require_relative 'controllers/init'