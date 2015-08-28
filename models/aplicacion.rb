class Aplicacion
  
  attr_reader :aplicacion
  attr_reader :conexion
  attr_reader :timer
  
  def initialize( args )
    @aplicacion = args
    @conexion = nil
    
    @timer = 0
  end

  def refresh
    begin
      @conexion.query( "SELECT 1" )
      
    rescue Mysql::Error => err

      load_bd(@aplicacion[:config][:driver], @aplicacion[:config][:host],
                @aplicacion[:config][:user], @aplicacion[:config][:pass],
                @aplicacion[:config][:bd],   @aplicacion[:config][:port])
                      
    rescue Errno::Error => err
      #$stderr.puts "%p while testing connection: %s" % [ err.class, err.message ]
            
      load_bd(@aplicacion[:config][:driver], @aplicacion[:config][:host],
                @aplicacion[:config][:user], @aplicacion[:config][:pass],
                @aplicacion[:config][:bd],   @aplicacion[:config][:port])
                      
    end
  end


  #     funciones archivos FTP
  
  def conectFTP( host, port, user, pass)
    Net::FTP.open( host, user, pass) do |ftp|
      #files = ftp.list
      #puts "list out files in root directory : "+ftp.pwd
      #puts files
      @aplicacion[:config]={:hostFTP=>host,:portFTP=>port,:userFTP=>user,:passFTP=>pass,:rutaFTP=>ftp.pwd}
      return 0
    end
    return 1
  end
  
  def upload_file
    
  end
  
  #     funciones SQL
      
  def update_mysql(select, tabla, where, params)
    load_bd unless(@conexion)
    
    set = ''
    where = ''
    columnas = @aplicacion[:tablas][tabla]['columnas'] 
    params.each {|key, value|
      if (columnas[key] && columnas[key][:column_key] != 'PRI')
        set << ", " if (set != '')
        set << key+"='"+params[key]+"'"
      end
      if (columnas[key] && columnas[key][:column_key] == 'PRI')
        where << " and " if (where != '')
        where << key+"='"+params[key]+"'"
      end
    }
    puts 'Update '+tabla+' Set '+set+' Where '+where
    if (where != '')
      begin
        @conexion.query('Update '+tabla+' Set '+set+' Where '+where)
      rescue Mysql::Error => e
        #puts e.errno     #puts e.error
        return e.error
      ensure
        #con.close if con
      end
    end
    return ''    
  end
  
  def delete_mysql(select, tabla, where, params)
    load_bd unless(@conexion)

    where = ''
    columnas = @aplicacion[:tablas][tabla]['columnas'] 
    params.each {|key, value|
      if (columnas[key] && columnas[key][:column_key] == 'PRI')
        where << " and " if (where != '')
        where << key+"='"+params[key]+"'"
      end
    }
    puts 'Delete From '+tabla+' '+where
    if (where != '')
      begin
        @conexion.query('Delete From '+tabla+' Where '+where)
      rescue Mysql::Error => e
        #puts e.errno     #puts e.error
        return e.error
      ensure
        #con.close if con
      end
    end
    return ''    
  end      
  
  def insert_mysql(params, tabla, where)
    load_bd unless(@conexion)
    filas = Hash.new
    cont = 0
    
    columnas = ''
    values=''
    
    #puts params[:foto]
    #puts params[:foto][:filename] if params[:foto]
    
    params.each{ |key, value|
      if (@aplicacion[:tablas][tabla]['columnas'][key])
        columnas = columnas + key + ','
        values = values + '\''+ value + '\',' 
      end
    }
    columnas = columnas[0..-2] if (columnas != '')
    values = values[0..-2] if (values != '')
    
    error = ''
    begin
      @conexion.query('INSERT INTO '+tabla+' ('+columnas+') VALUES ('+values+')')
    rescue Mysql::Error => e
      #puts e.errno
      #puts e.error
      return e.error
    ensure
      #con.close if con
    end
    return ''
  end    
  
  #     tablas de CRUDig
  
  
  #   funciones comunes
  
  def ordenar_create( tabla, params )
    order = ''
    
    if (params[:g_g] && (params[:g_g]==tabla))
      (params[:g_o] && params[:g_o]!='') ? order = params[:g_o]           : order = 'asc'
      (params[:g_f] && params[:g_f]!='') ? order = params[:g_f]+' '+order : order = ''
    else
      (params[:order] && params[:order]!='') ? order = params[:order]           : order = 'asc'
      (params[:field] && params[:field]!='') ? order = params[:field]+' '+order : order = ''
    end

    #(order=='asc') ? order='desc' : order='asc'
    return ' ORDER BY '+order if (order != '')
    return ''
  end
  
  def buscar_create( tabla, params )
    return '' unless (@aplicacion[:tablas][tabla])
    
    where = ''
    params.each{ |key, value|
      if (@aplicacion[:tablas][tabla]['columnas'][key])
        where = where+' '+tabla+'.'+key+' like \'%'+value+'%\' and ' 
      end
    }
    where = where[0..-5] if (where != '')

    return ' WHERE '+where if (where != '')
    return ''
  end  
  
  def set_order( params )
    return 'desc' if (params[:order]=='asc')
    return 'asc'
  end  
  
  def set_sub_grid_order( params )
    return 'desc' if (params[:g_o]=='asc')
    return 'asc'
  end  
  
  def get_sub_params(params)
    sub_params = {}
    sub_params[:g_g] = params[:g_g] if params[:g_g] 
    sub_params[:g_f] = params[:g_f] if params[:g_f]
    sub_params[:g_o] = params[:g_o] if params[:g_o]
    return sub_params
  end  
  

  
  
  
  def inner_join(tabla1, tabla2, sintabla1=false)
    from = tabla1+' inner join '+tabla2+' on '
    from = ' inner join '+tabla2+' on ' if sintabla1
        
    #column = @aplicacion[:tablas][tabla2]['config'][:referencias][tabla1]
    count = 0;
    @aplicacion[:tablas][tabla2]['columnas'].each { |key_col, value|
      if value[:tabla_rel].eql?(tabla1)
        from = from+' and ' if(count>1)
        from = from+' '+tabla1+'.'+value[:column_rel]+' = '+tabla2+'.'+key_col
        count+=1
      end
    }
    if(count == 0)
      @aplicacion[:tablas][tabla1]['columnas'].each { |key_col, value|
        if value[:tabla_rel].eql?(tabla2)
          from = from+' and ' if(count>1)
          from = from+' '+tabla2+'.'+value[:column_rel]+' = '+tabla1+'.'+key_col
          count+=1
        end
      }
    end
    return from
  end
  
  def make_form(tabla1, tabla2, from, sintabla1=false)
    return tabla1 if tabla1.eql?(tabla2)
    return '' unless @aplicacion[:tablas][tabla1]
    
    arr_referidas = @aplicacion[:tablas][tabla1]['config'][:referidas]
    arr_referencias = @aplicacion[:tablas][tabla1]['config'][:referencias]
    
    pos_referidas = arr_referidas.include?(tabla2)
    pos_referencias = arr_referencias.key?(tabla2)
    
    if (pos_referidas.eql?(TRUE))
      from = inner_join(tabla1, tabla2, sintabla1)
    elsif (pos_referencias.eql?(TRUE))
      from = inner_join(tabla1, tabla2, sintabla1)
    else
      if(arr_referidas.length > arr_referencias.length)
        #arr_referidas.each { |tablaAux|
        tablaAux = arr_referidas[0]
          from = '('+inner_join(tabla1, tablaAux, sintabla1)+')'
          from = '(' + from + make_form(tablaAux, tabla2, from, true) +')'
        #}
      else
        #arr_referencias.each{ |tablaAux, col |
        tablaAux = arr_referencias.keys[0]
          from = '('+inner_join(tabla1, tablaAux, sintabla1)+')'
          from = '('+ from + make_form(tablaAux, tabla2, from, true) + ')'
        #}
      end
    end
    return from
  end
  
  #       funciones de los CHARTS
  
#select salary, first_name from employees as emp inner 
#    join salaries as sala on emp.emp_no=sala.emp_no
#group by salary, first_name  

#select count(title) as cantidades, 
#titles.title as elementos from employees as emp inner 
#    join titles on emp.emp_no=titles.emp_no
#group by title

#SELECT departments.dept_name as elementos, count(employees.first_name) as cantidades  
#FROM departments inner join dept_emp on  departments.dept_no = dept_emp.dept_no  
#    inner join employees on employees.emp_no=dept_emp.emp_no
#GROUP BY departments.dept_name ORDER BY departments.dept_name

  def testingCircle( params ) 
    result = {}
    cantidad = params[:cantidades].split('.')
    elemento = params[:elementos].split('.')
    
    select = params[:elementos]+' as elementos, count('+params[:cantidades]+') as cantidades '
    group_by = ' GROUP BY '+params[:elementos]
    ordenar_sql = ' ORDER BY '+params[:elementos]
    from = 'FROM '+make_form( elemento[0], cantidad[0], '' )
    
    type_col_cantidades = @aplicacion[:tablas][cantidad[0]]['columnas'][cantidad[1]][:data_type]
    
    #if ('varchar'.eql?(type_col_cantidades) || 'char'.eql?(type_col_cantidades))
    if ('int'.eql?(type_col_cantidades)) 
      select = params[:elementos]+' as elementos, sum('+params[:cantidades]+') as cantidades '
    end
      
    if (from != 'FROM ' &&  @conexion)
      puts 'SELECT '+select+' '+from+' '+group_by+' '+ordenar_sql
      result = @conexion.query('SELECT '+select+' '+from+' '+group_by+' '+ordenar_sql)
    end
    return result
  end
  
  def testingArea( params ) 
    result = {}
    cantidad = params[:cantidades].split('.')
    elemento = params[:elementos].split('.')
    
    return result
  end
  
  def testingBar( params ) 
    result = {}
    return result
  end
  
  def testingColumn( params ) 
    result = {}
    return result
  end  
  
  def testingLine( params ) 
    result = {}
    return result
  end
  
  def testingCombo( params ) 
    result = {}
    return result
  end

  def castToBol(ceroUno)
    ceroUno=='0' ? false : true 
  end

  def save_config_table(tablas, nom_tabla, params)
    return 1 unless tablas[nom_tabla]
    #puts tablas[nom_tabla]['config']
    #puts tablas[nom_tabla]['config'][:inner_join]
    
    tablas[nom_tabla]['config'][:inner_join] = castToBol(params[:inner_join])     if params[:inner_join]
    tablas[nom_tabla]['config'][:nombre_grid] = params[:nombre_tabla]    if params[:nombre_tabla]
    tablas[nom_tabla]['config'][:ver_en_menu] = castToBol(params[:ver_tabla_en_menu])    if params[:ver_tabla_en_menu]
    tablas[nom_tabla]['config'][:nombre_menu] = params[:nombre_menu]    if params[:nombre_menu]
    tablas[nom_tabla]['config'][:insert_window] = castToBol(params[:insertar_por_ventana]) if params[:insertar_por_ventana]
    tablas[nom_tabla]['config'][:edit_window] = castToBol(params[:editar_por_ventana])    if params[:editar_por_ventana]
    # =>  :detalle_de 
    tablas[nom_tabla]['config'][:paginador] = params[:paginador]      if params[:paginador]
    
    #   configuraciones por columnas 
    tablas[nom_tabla]['columnas'].each{ |col, val|
      tablas[nom_tabla]['columnas'][col][:position] = params[col+'_position'] if params[col+'_position']
      tablas[nom_tabla]['columnas'][col][:default_value] = params[col+'_default_value'] if params[col+'_default_value']
      tablas[nom_tabla]['columnas'][col][:comments] = params[col+'_comments'] if params[col+'_comments']
      tablas[nom_tabla]['columnas'][col][:vista_grid] = params[col+'_ver_engrid'] if params[col+'_ver_engrid']
      tablas[nom_tabla]['columnas'][col][:texto_grid] = params[col+'_vertexto_engrid'] if params[col+'_vertexto_engrid']
      tablas[nom_tabla]['columnas'][col][:es_archivo] = params[col+'_es_archivo'] if params[col+'_es_archivo']
      tablas[nom_tabla]['columnas'][col][:carpeta_ftp] = params[col+'_carpeta_ftp'] if params[col+'_carpeta_ftp']
    }
    return 0
  end
  
  def jerarquia(upDown, params, tabla)
    select = one_select_sin_count('*', 'FROM '+tabla, '', '', '')
    
    results = Hash.new
    results[tabla] = select_down_up(upDown, tabla, params, select)
    return results
  end
    
  def jerarquia2(upDown, params, tabla, tabla2, fila)
    from = make_form( tabla, tabla2, '' )
    
    where = ''
    fila.each{ |col, val|
      if (where.eql?(''))
        where = where+tabla+'.'+col+'=\''+val+'\' '
      else
        where = where+' and '+tabla+'.'+col+'=\''+val+'\' '
      end
    }
    where = ' WHERE ' + where
    select = one_select_sin_count(tabla2+'.*', 'FROM '+from, where, '', '')
    
    return select_down_up(upDown, tabla2, fila, select)
  end
  
  def select_down_up(upDown, tabla, params, select)
    results = Hash.new

    arr_referidas = @aplicacion[:tablas][tabla]['config'][:referidas]
    arr_referencias = @aplicacion[:tablas][tabla]['config'][:referencias]
    
    count = 0;
    select.each_hash{ |row|
      fila = Hash.new{}
      fila[:fila] = row
      fila[:hijos] = Hash.new
      
      if(upDown.eql?('Down'))
        arr_referidas.each{ |tabla_ref|
          fila[:hijos][tabla_ref] = jerarquia2(upDown, params, tabla, tabla_ref, row)
        }
      else
        arr_referencias.each{ |tabla_ref|
          fila[:hijos][tabla_ref] = jerarquia2(upDown, params, tabla, tabla_ref, row)
        }
      end
      results[count] = fila
      count +=1;
    }
    return results
  end
        
end

