require 'sinatra'
#require 'dbi'
require 'mysql'
require 'pg'
require 'json'
#require 'sqlite'
require 'net/ftp'
require 'prawn'
require 'prawn/table'

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
  @@appCRUDig = ''
  @@appDemos = ''
  
  @@idiomas = Hash.new
  @@filas = Hash.new
  @@config = {:config => {:idioma=>"ES",:bd=>"",:host=>"",:user=>"",:pass=>"",:driver=>"",:port=>"",
                          :hostFTP=>"",:portFTP=>"",:userFTP=>"",:passFTP=>"",:rutaFTP=>""}, 
              :tablas => {},
              :enlaces => [],
              :graficos => {},
              :timers => {},
              :listados => {} }   # tabla => { nombre='', titulo='', url='' }
                  #:enlaces => {'1'=>'usuarios','2'=>'fotos','3'=>'entorno'} }
  
  @@crudigConfig = {:config => {:bd=>"crudig",:host=>"127.0.0.1",:user=>"root",:pass=>"",:driver=>"MySQL",:port=>"3306"}, 
                    :tablas => {}, :enlaces => []}
  @@demosConfig = {:config => {:idioma=>"ES",:bd=>"demosCrudig",:host=>"127.0.0.1",:user=>"root",:pass=>"",:driver=>"MySQL",:port=>"3306"}, 
                    :tablas => {}, :enlaces => []}
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
  
  
  get '/ayuda' do
    message = ''
    view_ayuda(message)    
  end
  get '/ayuda/' do
    redirect '/ayuda'
  end
  
  get '/demos' do
    message = ''
    url = request.base_url
    
    #if(@@appCRUDig=='')
    if(url=="127.0.0.1" || url=="http://localhost:9292" || url=="localhost:9292")
      @@appDemos = MySQLconex.new @@demosConfig
      message= @@appDemos.load_bd_MySQL( @@demosConfig[:config][:driver], @@demosConfig[:config][:host], 
                                          @@demosConfig[:config][:user], @@demosConfig[:config][:pass], 
                                          @@demosConfig[:config][:bd], @@demosConfig[:config][:port])
      # => @@demosConfig = {:config => {:bd=>"crudig",:host=>"127.0.0.1",:user=>"root",:pass=>"",:driver=>"MySQL",:port=>"3306"}, 
    else
      @@appDemos = PSqlconex.new @@demosConfig
      message= @@appDemos.load_bd_PS( 'Postgress', 'ec2-54-225-243-113.compute-1.amazonaws.com', 
                                      'xzchupaeemrrya', 'xWCbCz3hLiVVMXhDPA92P8GV1c', 'd7f28efnvgfki', '5432')
    end  
    @@demosConfig[:enlaces] = []
    #else  message = '<div class="alert alert-danger"><p>No se puede conectar a CRUDig ahora</p></div>'     
    #end
    #if(@@appDemos!='')
      filas = @@appDemos.select_mysql(' * ', 'demos_config', params, 0)
    #end    
    view_configuraciones_demos(message, filas)
  end
  get '/demos/:controler/:funcion' do |controler, funcion|
    if(validController(controler))
      case funcion
      when 'create'      then create_id(@@appDemos, controler, params)
      when 'create_json' then create_id_json(@@appDemos, controler, params)
      when 'update'      then update_id(@@appDemos, controler, params)
      when 'update_json' then update_id_json(@@appDemos, controler, params)
      when 'delete'      then delete_id(@@appDemos, controler, params)
      when 'delete_json' then delete_id_json(@@appDemos, controler, params)        
      when 'listar'      then listar_tabla(@@appDemos, controler, params, 0)
      end
    end
  end    
  get '/demos/' do
    redirect '/demos'
  end
  get '/demos/config/view/:id' do |idConfig|
    message = ''
    select_demos_config_id(idConfig)
  end  
  
  get '/configuraciones' do
    message = ''
    
    #if(@@appCRUDig=='')
      @@appCRUDig = MySQLconex.new @@crudigConfig
      message= @@appCRUDig.load_bd_MySQL( @@crudigConfig[:config][:driver], @@crudigConfig[:config][:host], 
                                          @@crudigConfig[:config][:user], @@crudigConfig[:config][:pass], 
                                          @@crudigConfig[:config][:bd], @@crudigConfig[:config][:port])
      # => @@crudigConfig = {:config => {:bd=>"crudig",:host=>"127.0.0.1",:user=>"root",:pass=>"",:driver=>"MySQL",:port=>"3306"}, 
      @@crudigConfig[:enlaces] = []
    #else  message = '<div class="alert alert-danger"><p>No se puede conectar a CRUDig ahora</p></div>'     
    #end
    #if(@@appCRUDig!='')
      filas = @@appCRUDig.select_mysql(' * ', 'configuraciones', params, 0)
    #end
    
    view_configuraciones(message, filas)
  end
  get '/configuraciones/:controler/:funcion' do |controler, funcion|
    if(validController(controler))
      case funcion
      when 'create'      then create_id(@@appCRUDig, controler, params)
      when 'create_json' then create_id_json(@@appCRUDig, controler, params)
      when 'update'      then update_id(@@appCRUDig, controler, params)
      when 'update_json' then update_id_json(@@appCRUDig, controler, params)
      when 'delete'      then delete_id(@@appCRUDig, controler, params)
      when 'delete_json' then delete_id_json(@@appCRUDig, controler, params)        
      when 'listar'      then listar_tabla(@@appCRUDig, controler, params, 0)
      end
    end
  end  
  get '/configuraciones/' do
    redirect '/configuraciones'
  end  
    
  get '/config' do 
    message = ''
    conexionBDId = {:bd=>"fullcrud",:host=>"127.0.0.1",:user=>"root",:pass=>"",:driver=>"MySQL",:port=>"3306"}
    view_config(message, conexionBDId)
  end
  
  get '/config/' do
    redirect '/config'
  end
    
  post '/config/conectarBD' do
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
    
    view_config(message, @@config[:config])
  end
  
  post '/config/conectarFTP' do
    message = ''
    
    result = @@app.conectFTP(params[:host], params[:port], params[:usuario], params[:pass])
    
    if(result==1)
      message = '<div class="alert alert-danger"><p>Tiene que especificar todos los parametros de conexión FTP</p></div>'
    else
      message = '<div class="alert alert-success"><p>Confuración FTP cargada con éxito</p></div>'
    end
    view_config(message, @@config[:config])
  end  
  
  post '/config/edit/:tabla' do |tabla|
    message = ''

    redirect "/config" if (tabla.eql?('config') || tabla.eql?('favicon.ico') || tabla.eql?('js') || tabla.eql?('css'))

    result=@@app.save_config_table(@@config[:tablas], tabla, params)
    if result==1
      message='<div class="alert alert-danger"><p>La tabla referenciada no se encuentra</p></div>'
    else
      message='<div class="alert alert-success"><p>Configuraciones guardadas con éxito para la tabla '+tabla+'</p></div>'
    end
    view_config(message)
  end

  get '/config/view/:id' do |idConfig|
    message = ''
    select_config_id('idAdmin', idConfig)
  end
    
  get '/:controler' do |controler|
    redirect "/#{controler}/listar" unless (controler.eql?('config') || controler.eql?('favicon.ico') || controler.eql?('js') || controler.eql?('css'))
  end
    
  get '/:controler/' do |controler|
    redirect "/#{controler}/listar" unless (controler.eql?('config') || controler.eql?('favicon.ico') || controler.eql?('js') || controler.eql?('css'))
  end

  post '/:controler/:funcion' do |controler, funcion|
    order = ''
    search = ''

    if(validController(controler))
      puts '----JSON POST---------'
      case funcion
      when 'create_json' then create_id_json(@@app, controler, params)
      when 'listar'      then listar_tabla_json(@@app, controler, params, 0)
      end
    end
  end  
  
  get '/:controler/:funcion' do |controler, funcion|
    order = ''
    search = ''

    if(validController(controler))
      case funcion
      when 'create'      then create_id(@@app, controler, params)
      when 'create_json' then create_id_json(@@app, controler, params)
      when 'update'      then update_id(@@app, controler, params)
      when 'update_json' then update_id_json(@@app, controler, params)
      when 'delete'      then delete_id(@@app, controler, params)
      when 'delete_json' then delete_id_json(@@app, controler, params)        
      when 'listar'      then listar_tabla(@@app, controler, params, 0)
      when 'generatepdf' then generarPDF(@@app, controler, params)
      end
    end
  end
  
  get '/:controler/:funcion/:id' do |controler, funcion, id|
    #redirect "/#{controler}/#{funcion}" unless (controler.eql?('config') || controler.eql?('favicon.ico'))
    
    if(validController(controler))
      case funcion
      #when 'update'      then update_id(controler, id, params)
      #when 'update_json' then update_id_json(controler, id, params)
      #when 'delete'      then delete_id(controler, id, params)
      #when 'delete_json' then delete_id_json(controler, id, params)
      when 'listar'      then listar_tabla(@@app, controler, params, id)
      end
    end
  end
  
  post '/:controler/:funcion/:id' do |controler, funcion, id|
    if(validController(controler))
      listar_tabla_json(@@app, controler, params, id, 0)
    end
  end

  
end

require_relative 'libraries/libreria'
require_relative 'libraries/idiomas'
require_relative 'models/init'
#require_relative 'controllers/init'