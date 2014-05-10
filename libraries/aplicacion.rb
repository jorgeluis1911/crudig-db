class App < Sinatra::Application
      
  def load_bd( driver, dominio, usuario, pass, bd_name, port)
    #@@conexion = Mysql.new('127.0.0.1', 'root', '', 'recetas')
    #real_connect(host=nil, user=nil, passwd=nil, db=nil, port=nil, sock=nil, flag=nil).
    begin
      @@conexion = Mysql.new(dominio, usuario, pass, bd_name, port)
      
      return load_config( bd_name )
    rescue Mysql::Error
      return '<div class="alert alert-danger"><p>No se puede conectar a la Base de Datos, compruebe su usuario y contraseña</p></div>'
    end
    #puts "DBI:#{driver}:#{bd_name}:#{dominio}"
    #@@conexion = DBI.connect("DBI:#{driver}:#{bd_name}:#{dominio}", usuario, pass)
  end
  
  def load_config(bd_name)
    tablas = ''
    
    @@aplicacion[:enlaces] = []
    @@aplicacion[:tablas] = {}
    
    referidas = {}
    
    select = 'col.table_name, col.column_name, col.column_default, col.is_nullable, col.DATA_TYPE, col.CHARACTER_MAXIMUM_LENGTH, 
              col.COLUMN_KEY, col.PRIVILEGES, col.COLUMN_COMMENT, col.ORDINAL_POSITION, 
              col_u.CONSTRAINT_NAME, col_u.REFERENCED_TABLE_SCHEMA, col_u.REFERENCED_TABLE_NAME, col_u.REFERENCED_COLUMN_NAME '
    from = 'FROM INFORMATION_SCHEMA.columns as col left join INFORMATION_SCHEMA.key_column_usage as col_u 
                on col_u.table_name=col.table_name and col_u.column_name=col.column_name'
    order = ' ORDER BY col.table_name, col.ordinal_position '
    @@conexion.query('SELECT '+select+' '+from+' WHERE col.table_schema =\''+bd_name+'\' '+order).each_hash{ |row|
      #print row['column_name']

      if !row['table_name'].eql?(tablas)
        @@aplicacion[:enlaces] << row['table_name']
        @@aplicacion[:tablas][row['table_name']] = {}
        
        config_tabla= {}
        config_tabla[:inner_join] = true
        config_tabla[:nombre_grid] = ''
        config_tabla[:ver_en_menu] = true
        config_tabla[:insert_window] = true
        config_tabla[:edit_window] = true
        config_tabla[:detalle_de] = ''
        config_tabla[:referencias] = {}
        config_tabla[:paginador] = 7
        @@aplicacion[:tablas][row['table_name']]['config'] = config_tabla
        @@aplicacion[:tablas][row['table_name']]['columnas'] = {}
      end
      tablas = row['table_name']
      
      # => agregar las columnas
      columna= {}
      columna[:position] = row['ORDINAL_POSITION']
      columna[:default_value] = row['COLUMN_DEFAULT']
      columna[:is_nullable] = row['is_nullable']
      columna[:data_type] = row['DATA_TYPE'].to_s
      columna[:length] = row['CHARACTER_MAXIMUM_LENGTH']
      columna[:column_key] = row['COLUMN_KEY']      # ['PRI', 'UNI', 'MUL']
      columna[:comments] = row['COLUMN_COMMENT']
      
      # => datos sobre FK
      columna[:key_name] = row['CONSTRAINT_NAME']
      columna[:esquema_rel] = row['REFERENCED_TABLE_SCHEMA']
      columna[:tabla_rel] = row['REFERENCED_TABLE_NAME']
      columna[:column_rel] = row['REFERENCED_COLUMN_NAME']
      
      # => configuración de vista
      columna[:vista_grid] = true
      columna[:texto_grid] = ''
            
      @@aplicacion[:tablas][tablas]['config'][:referidas] = []
      if columna[:tabla_rel]
        @@aplicacion[:tablas][tablas]['config'][:referencias][columna[:tabla_rel]] = columna[:column_rel]
        @@aplicacion[:tablas][tablas]['config'][:detalle_de] = columna[:tabla_rel]

        referidas[columna[:tabla_rel]] = []   unless ( referidas[columna[:tabla_rel]] )
        referidas[columna[:tabla_rel]] << tablas
      end
      @@aplicacion[:tablas][tablas]['columnas'][row['column_name']] = columna
    }
    referidas.each{ |tabla, tablas_ref|   
      @@aplicacion[:tablas][tabla]['config'][:referidas] = tablas_ref
    }
    
    return '<div class="alert alert-success"><p>Confuración cargada con éxito</p></div>'
  end
  
  def select_mysql(select, tabla, params, start_limit)
    filas = Hash.new
    cont = 0
    
    ordenar_sql = ordenar_create(tabla, params)
    where_sql = buscar_create(tabla, params)
    limit = ' LIMIT '+start_limit.to_s+', '+ @@aplicacion[:tablas][tabla]['config'][:paginador].to_s
            
        #@@aplicacion[:tablas][tabla]['config'][:paginador] = 7 
    
    select = ''
    from = 'FROM '+tabla
    #@@aplicacion[:tablas][tabla].each {|key, value| select << "#{key}," if (value[:column_key] != 'PRI' )}
    @@aplicacion[:tablas][tabla]['columnas'].each {|key, value| 
      select << "#{tabla}.#{key},"
      if (value[:column_rel])
        from << ' left join '+value[:tabla_rel]+' on '+tabla+'.'+key+'='+value[:tabla_rel]+'.'+value[:column_rel]
        select << "#{value[:tabla_rel]}.#{value[:column_rel]} as #{value[:tabla_rel]}_#{value[:column_rel]},"
        
        filas[value[:tabla_rel]] = simple_select( value[:column_rel], ' FROM '+value[:tabla_rel],'','','')
      end
    }
    select = select[0..-2]
    
    filas[tabla] = simple_select(select, from, where_sql, ordenar_sql, limit)
        
    filas[:filas_detalle] = {}
    sub_params = get_sub_params(params)
    
    @@aplicacion[:tablas][tabla]['config'][:referidas].each {|key, value|
      unless(filas[:filas_detalle][key])
        filas[:filas_detalle][key] = select_mysql('*', key, sub_params, 0)
      end
    }
    
    filas['filas_total'] = simple_select(' COUNT(*) as total ', from, where_sql, '', '')
    return filas
  end
  
  def simple_select(select, from, where_sql, ordenar_sql, limit)
    load_bd unless(@@conexion)
    filas = Hash.new
    cont = 0
    
    @@conexion.query('SELECT '+select+' '+from+' '+where_sql+' '+ordenar_sql +limit).each_hash{ |row|
      filas["#{cont}"] = row
      cont += 1
    }
    #puts 'SELECT * '+from+' '+where_sql+' '+ordenar_sql +limit
    return filas        
  end
  
  def update_mysql(select, tabla, where)
    load_bd unless(@@conexion)
    filas = Hash.new
    cont = 0
    
    select = ''
    @@aplicacion[:tablas].each {|key, value| select << "#{key}," if (value[:column_key] != 'PRI' )}
    @@conexion.query('SELECT '+select+' FROM '+tabla).each_hash{ |row|
      filas["#{cont}"] = row
      cont += 1
    }
    return filas    
  end
  
  def delete_mysql(select, tabla, where)
    load_bd unless(@@conexion)
    filas = Hash.new
    cont = 0
    
    select = ''
    @@aplicacion[:tablas].each {|key, value| select << "#{key}," if (value[:column_key] != 'PRI' )}
    @@conexion.query('SELECT '+select+' FROM '+tabla).each_hash{ |row|
      filas["#{cont}"] = row
      cont += 1
    }
    return filas    
  end      
  
  def insert_mysql(params, tabla, where)
    load_bd unless(@@conexion)
    filas = Hash.new
    cont = 0
    
    columnas = ''
    values=''
    params.each{ |key, value|
      if (@@aplicacion[:tablas][tabla]['columnas'][key])
        columnas = columnas + key + ','
        values = values + '\''+ value + '\',' 
      end
    }
    columnas = columnas[0..-2] if (columnas != '')
    values = values[0..-2] if (values != '')
    puts 'INSERT INTO '+tabla+' ('+columnas+') VALUES ('+values+')'
    
    error = ''
    begin
      @@conexion.query('INSERT INTO '+tabla+' ('+columnas+') VALUES ('+values+')')
    rescue Mysql::Error => e
      #puts e.errno
      #puts e.error
      return e.error
    ensure
      #con.close if con
    end
    return ''
  end    
  
  def existe?(controler)
    if @@aplicacion[:tablas].has_key?(controler)
      TRUE
    else
      FALSE
    end
  end
  
  def listar( tabla='', filas={}, message='',order={}, params={} )
    erb :listar, :locals => {:tabla => tabla, :filas => filas, :message => message,
                              :order => order, :enlaces => @@aplicacion[:enlaces],
                              :params => params, :tablas => @@aplicacion[:tablas]}
  end
  
  def listar_json( tabla='', filas={}, message='',order={}, params={} )
    global_var = {:tabla => tabla, :filas => filas, :message => message,
                  :order => order, :enlaces => @@aplicacion[:enlaces],
                  :params => params, :tablas => @@aplicacion[:tablas]}
    return global_var.to_json
  end
  
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
    return '' unless (@@aplicacion[:tablas][tabla])
    
    where = ''
    params.each{ |key, value|
      if (@@aplicacion[:tablas][tabla]['columnas'][key])
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
  
end