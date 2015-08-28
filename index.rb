require 'sinatra'
#require 'dbi'
require 'mysql'
require 'pg'
require 'json'
require 'sqlite3'
require 'net/ftp'
require 'prawn'
require 'prawn/table'
require 'sequel'

#$db = SQLite3::Database.new( "entornos.db" )

# => http://app-rack2.herokuapp.com

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
  
  @@debug = 0
  
  @@rutaFiles = './upload_sqlite'
  @@fileSqlite = ''
 
=begin
  :tabla1=>{:c=>1,:r=>1,:u=>1,:d=>1,:i=>1,:g=>1,:a=>1,:n=>1}
  
{:tabla1=>{:c=>1,:r=>1,:u=>1,:d=>1,:i=>1},    43 letras Maximo * 20 tablas =   
:tabla2=>{:c=>1,:r=>1,:u=>1}}
 
  replace
  
{tabla1={c1,r1,u1},    20 letras Maximo * 20 tablas =   400 letras maximo
 tabla2={c1,r1,u1}}
  
=end
   
  @@idiomas = Hash.new
  @@filas = Hash.new
  @@config = {:config => {:idioma=>"es",:bd=>"",:host=>"",:user=>"",:pass=>"",:driver=>"",:port=>"",
                          :hostFTP=>"",:portFTP=>"",:userFTP=>"",:passFTP=>"",:rutaFTP=>""}, 
              :tablas => {},
              :enlaces => [],
              :graficos => {},
              :timers => {},
              :mejoras => {},     # tabla => { min , max, minW, maxW }
              :busquedas => {},   # tabla => { defecto = '', otras => [ nombre='', url='' ] }
              :listados => {} }   # tabla => [ nombre='', titulo='', url='' ]
                  #:enlaces => {'1'=>'usuarios','2'=>'fotos','3'=>'entorno'} }
  
  @@crudigConfig = {:config => {:bd=>"crudig",:host=>"127.0.0.1",:user=>"root",:pass=>"",:driver=>"MySQL",:port=>"3306"}, 
                    :tablas => {}, :enlaces => []}
  @@demosConfig = {:config => {:idioma=>"ES",:bd=>"demosCrudig",:host=>"127.0.0.1",:user=>"root",:pass=>"",:driver=>"MySQL",:port=>"3306"}, 
                    :tablas => {}, :enlaces => []}
  $id_entorno = 0
  
  @@timer = 0;


  get '/' do
    redirect "/es"
  end  
  get '/:lang' do |lang|
    redirect "/es" unless (validLanguage(lang))
    
    mensaje='<h1>Bienvenidos a nuestra App de facil mantenimiento de tus Bases de Datos</h1>'
    home_page(mensaje)
  end
  get '/:lang/' do |lang|
    redirect '/'+lang
  end
  
  get '/:lang/caracteristicas' do |lang|
    redirect "/es/caracteristicas" unless (validLanguage(lang))
    
    message = ''
    erb :features, :locals => {:config => @@config[:config],
                             :tablas => @@config[:tablas],
                             :enlaces => @@config[:enlaces],
                             :message => message,}    
  end
  
  get '/:lang/caracteristicas/' do |lang|
    redirect "/es/caracteristicas" unless (validLanguage(lang))
    redirect "/#{lang}/caracteristicas"
  end  
  
  # =>    rutas para los graficos
  get '/:lang/chartArea' do |lang|
    redirect "/es/chartArea" unless (validLanguage(lang))
    message = ''
    
    viewChart( 'charts/area', message, {}, {})
  end
    
  get '/:lang/chartBar' do |lang|
    redirect "/es/chartBar" unless (validLanguage(lang))
    message = ''
    
    viewChart( 'charts/barras', message, {}, {})
  end
  
  get '/:lang/chartCircle' do |lang|
    redirect "/es/chartCircle" unless (validLanguage(lang))
    viewChart( 'charts/circle', '', {}, {})
  end

  get '/:lang/chartCircle/testingChart' do |lang|
    redirect "/es/chartCircle/testingChart" unless (validLanguage(lang))
    
    message = ''
    results = @@app.testingCircle( params ) if params[:testing]
    viewChart( 'charts/circle', message, {}, results)
  end
  
  get '/:lang/chartColumn' do |lang|
    redirect "/es/chartColumn" unless (validLanguage(lang))
    message = ''
    
    viewChart( 'charts/column', message, {}, {})    
  end

  get '/:lang/chartCombo' do |lang|
    redirect "/es/chartCombo" unless (validLanguage(lang))
    message = ''
    
    viewChart( 'charts/combo', message, {}, {})    
  end

  get '/:lang/chartLine' do |lang|
    redirect "/es/chartLine" unless (validLanguage(lang))
    message = ''
    
    viewChart( 'charts/line', message, {}, {})
  end

  get '/:lang/mycharts' do |lang|
    redirect "/es/mycharts" unless (validLanguage(lang))
    message = ''
    
    viewChart( 'charts/misgraficos', message, {}, {}) 
  end
          
  # =>    final de rutas para los graficos
  
  get '/:lang/jerarquiaUp/:tabla' do |lang, tabla|
    redirect "/es/jerarquiaUp/#{tabla}" unless (validLanguage(lang))
    
    message = ''
    results = @@app.jerarquia("Up", params, tabla) if (@@config[:tablas][tabla])
    verJerarquia( tabla, results, message, {}, params)
  end
  
  get '/:lang/jerarquiaDown/:tabla' do |lang, tabla|
    redirect "/es/jerarquiaDown/#{tabla}" unless (validLanguage(lang))
    
    message = ''
    results = @@app.jerarquia("Down", params, tabla) if (@@config[:tablas][tabla])
    verJerarquia( tabla, results, message, {}, params)    
  end  


  get '/:lang/refrescar/:tabla' do |lang, tabla|
    redirect "/es/refrescar/#{tabla}" unless (validLanguage(lang))
    @@config[:timers] = {}
    
    redirect "#{lang}/refrescar/#{tabla}/0"
  end
  
  get '/:lang/refrescar/:tabla/:segundos' do |lang, tabla, segundos|
    redirect "/es/refrescar/#{tabla}/#{segundos}" unless (validLanguage(lang))
    
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
  
  get '/:lang/mejoras' do |lang|
    redirect "/es/mejoras" unless (validLanguage(lang))
    message = ''
    view_mejoras(message)
  end
  get '/:lang/mejoras/' do |lang|
    redirect "/es/mejoras" unless (validLanguage(lang))
    redirect "#{lang}/mejoras"
  end  
  
  get '/:lang/ayuda' do |lang|
    redirect "/es/ayuda" unless (validLanguage(lang))
    message = ''
    view_ayuda(message)
  end
  get '/:lang/ayuda/' do |lang|
    redirect "/es/ayuda" unless (validLanguage(lang))
    redirect "#{lang}/ayuda"
  end
  
  get '/:lang/demos' do |lang|
    redirect "/es/demos" unless (validLanguage(lang))
    message = ''
    url = request.base_url
    
    #if(@@appCRUDig=='')
    if(url=='127.0.0.1' || url=='http://localhost:9292' || url=='localhost:9292')
      @@appDemos = MySQLconex.new @@demosConfig
      message= @@appDemos.load_bd( @@demosConfig[:config][:driver], @@demosConfig[:config][:host], 
                                          @@demosConfig[:config][:user], @@demosConfig[:config][:pass], 
                                          @@demosConfig[:config][:bd], @@demosConfig[:config][:port])
      # => @@demosConfig = {:config => {:bd=>"crudig",:host=>"127.0.0.1",:user=>"root",:pass=>"",:driver=>"MySQL",:port=>"3306"}, 
    else
      @@appDemos = PSqlconex.new @@demosConfig
      message= @@appDemos.load_bd( 'Postgress', 'ec2-54-225-243-113.compute-1.amazonaws.com', 
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
  
  get '/:lang/demos/:controler/:funcion' do |lang, controler, funcion|
    redirect "/es/demos/#{controler}/#{funcion}" unless (validLanguage(lang))
    
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
  
  get '/:lang/demos/' do |lang|
    redirect "/es/demos" unless (validLanguage(lang))
    redirect "/#{lang}/demos"
  end
  get '/:lang/demos/config/view/:id' do |lang, idConfig|
    redirect "/es/demos/config/view/#{idConfig}" unless (validLanguage(lang))
    
    message = ''
    select_demos_config_id(idConfig)
  end  
  
  get '/:lang/configuraciones' do |lang|
    redirect "/es/configuraciones" unless (validLanguage(lang))
    message = ''
    
    url = request.base_url

    #if(@@appCRUDig=='')
    if(url=="127.0.0.1" || url=="http://localhost:9292" || url=="localhost:9292")
      @@appCRUDig = MySQLconex.new @@crudigConfig
      message= @@appCRUDig.load_bd( @@crudigConfig[:config][:driver], @@crudigConfig[:config][:host], 
                                          @@crudigConfig[:config][:user], @@crudigConfig[:config][:pass], 
                                          @@crudigConfig[:config][:bd], @@crudigConfig[:config][:port])
      # => @@crudigConfig = {:config => {:bd=>"crudig",:host=>"127.0.0.1",:user=>"root",:pass=>"",:driver=>"MySQL",:port=>"3306"},
    else
      @@appCRUDig = PSqlconex.new @@demosConfig
      message= @@appCRUDig.load_bd( 'Postgress', 'ec2-54-225-243-113.compute-1.amazonaws.com', 
                                      'xzchupaeemrrya', 'xWCbCz3hLiVVMXhDPA92P8GV1c', 'd7f28efnvgfki', '5432')
    end   
    @@crudigConfig[:enlaces] = []
    #else  message = '<div class="alert alert-danger"><p>No se puede conectar a CRUDig ahora</p></div>'     
    #end
    #if(@@appCRUDig!='')
      #filas = @@appCRUDig.simple_select(' * ', 'configuraciones', '', '', '')
      filas = @@appCRUDig.select_mysql(' * ', 'configuraciones', params, 0)
    #end
    
    view_configuraciones(message, filas)
  end
  
  get '/:lang/configuraciones/:controler/:funcion' do |lang, controler, funcion|
    redirect "/es/configuraciones/#{controler}/#{funcion}" unless (validLanguage(lang))
    
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
  
  get '/:lang/configuraciones/' do |lang|
    redirect "/es/configuraciones" unless (validLanguage(lang))
    redirect "/#{lang}/configuraciones"
  end  
    
  get '/:lang/config' do |lang|
    redirect "/es/config" unless (validLanguage(lang))
    
    message = ''
    conexionBDId = {:bd=>"fullcrud",:host=>"127.0.0.1",:user=>"root",:pass=>"",:driver=>"MySQL",:port=>"3306"}
    view_config(message, conexionBDId)
  end
  
  get '/:lang/config/' do |lang|
    redirect "/es/config" unless (validLanguage(lang))
    redirect "/#{lang}/config"
  end
    
  post '/config/conectarBD' do
    message = ''
    
    case params[:driver]
    when 'Sqlite' then
      puts params
      if params[:sqlitefile]
        filename = params[:sqlitefile][:filename]
        file = params[:sqlitefile][:tempfile]
        time = Time.new
  
        @@fileSqlite = time.strftime("%Y%m%d_%H%M%S_")+filename
        File.open(File.join( @@rutaFiles, @@fileSqlite), 'wb') do |f|
          f.write file.read
        end
        
        @@app = Sqliteconex.new @@config
        message= @@app.load_bd( params[:driver], @@rutaFiles, @@fileSqlite)
        
      else
        message = msgError 'Se debe seleccionar un fichero Sqlite'
      end
      
    when 'Mysql', 'MariaDB'  then 
      @@app = MySQLconex.new @@config
      message= @@app.load_bd( params[:driver], params[:dominio], params[:usuario], params[:pass], params[:bd], params[:port])
    when 'Postgress' then
      @@app = PSqlconex.new @@config
      message= @@app.load_bd( params[:driver], params[:dominio], params[:usuario], params[:pass], params[:bd], params[:port])
    when 'SQLServer' 
    when 'Oracle'  
    else  message = '<div class="alert alert-danger"><p>Tiene que especificar todos los parametros de conexión</p></div>'
    end
    
    view_config(message, @@config[:config])
  end
  
  post '/:lang/config/conectarFTP' do |lang|
    redirect "/es/config" unless (validLanguage(lang))
    message = ''
    
    result = @@app.conectFTP(params[:host], params[:port], params[:usuario], params[:pass])
    
    if(result==1)
      message = '<div class="alert alert-danger"><p>Tiene que especificar todos los parametros de conexión FTP</p></div>'
    else
      message = '<div class="alert alert-success"><p>Confuración FTP cargada con éxito</p></div>'
    end
    view_config(message, @@config[:config])
  end  
  
  post '/:lang/config/edit/:tabla' do |lang, tabla|
    redirect "/es/config" unless (validLanguage(lang))
    message = ''

    redirect "/#{lang}/config" if (!validController(tabla))

    result=@@app.save_config_table(@@config[:tablas], tabla, params)
    if result==1
      message='<div class="alert alert-danger"><p>La tabla referenciada no se encuentra</p></div>'
    else
      message='<div class="alert alert-success"><p>Configuraciones guardadas con éxito para la tabla '+tabla+'</p></div>'
    end
    view_config(message, @@config[:config])
  end

  get '/:lang/config/view/:id' do |lang, idConfig|
    redirect "/es/config/view/#{idConfig}" unless (validLanguage(lang))
    
    message = ''
    select_config_id('idAdmin', idConfig)
  end
    
  get '/:lang/:controler' do |lang, controler|
    redirect "/es/#{controler}/listar" unless (validLanguage(lang))
    redirect "/#{lang}/#{controler}/listar" unless validController(controler)
    redirect "/#{lang}/#{controler}/listar"
  end
    
  get '/:lang/:controler/' do |lang, controler|
    redirect "/es/#{controler}/listar" unless (validLanguage(lang))
    redirect "/#{lang}/#{controler}/listar" unless validController(controler)
    redirect "/#{lang}/#{controler}/listar"
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


  get '/:lang/:controler/' do |lang, controler, funcion|
    redirect "/es/#{controler}/#{funcion}" unless (validLanguage(lang))
    
  end
    
  get '/:lang/:controler/:funcion' do |lang, controler, funcion|
    redirect "/es/#{controler}/#{funcion}" unless (validLanguage(lang))
    
    order = ''
    search = ''

    if(validController(controler))
      case funcion
        #when 'view'                   then create_id(@@app, controler, params)
        #when 'view_json'              then create_id_json(@@app, controler, params)
        when 'get'                    then get_id(@@app, controler, params)
        when 'get_json'               then get_id_json(@@app, controler, params)                  
        when 'create'                 then create_id(@@app, controler, params)
        when 'create_json'            then create_id_json(@@app, controler, params)
        when 'update'                 then update_id(@@app, controler, params)
        when 'update_json'            then update_id_json(@@app, controler, params)
        when 'delete'                 then delete_id(@@app, controler, params)
        when 'delete_json'            then delete_id_json(@@app, controler, params)        
        when 'listar'                 then listar_tabla(@@app, controler, params, 0)
        when 'generatepdf'            then generarPDF(@@app, controler, params)
        when 'save_generatepdf_json'  then save_generatepdf_json(@@app, controler, params)
        when 'default_search_json'    then default_search_json(@@app, controler, params)
        when 'save_search_json'       then saveSearch_json(@@app, controler, params)
      end
    else
      redirect "/es/config"
    end
    
  end
  
  get '/:lang/:controler/:funcion/:id' do |lang, controler, funcion, id|
    #redirect "/#{controler}/#{funcion}" unless (controler.eql?('config') || controler.eql?('favicon.ico'))
    redirect "/es/#{controler}/#{funcion}/#{id}" unless (validLanguage(lang))
    
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