class MySQLconex < Aplicacion

  def load_bd( driver, dominio, usuario, pass, bd_name, port)
    #@conexion = Mysql.new('127.0.0.1', 'root', '', 'recetas')
    #real_connect(host=nil, user=nil, passwd=nil, db=nil, port=nil, sock=nil, flag=nil).

    begin
      Sequel.datetime_class = Date
      #Sequel.convert_two_digit_years = false
	  
	  puts 'mysql://'+usuario+':'+pass+'@'+dominio+':'+port+'/'+bd_name
      @conexion = Sequel.connect('mysql://'+usuario+':'+pass+'@'+dominio+':'+port+'/'+bd_name)
      #@conexion = Mysql.new(dominio, usuario, pass, bd_name, port)
      
      # raise( rb_ePGerror , "PQconnectdb() unable to allocate structure")   unless(@conexion)
      
      @aplicacion[:config][:bd]=bd_name
      @aplicacion[:config][:host]=dominio
      @aplicacion[:config][:user]=usuario
      @aplicacion[:config][:pass]=pass
      @aplicacion[:config][:driver]=driver
      @aplicacion[:config][:port]=port
      
      puts Date.parse('2014-03-05', true)
      
      #@conexion.convert_invalid_date_time = nil
      
      return load_config_MySQL( bd_name )
    rescue Sequel::Error => e
      puts e
      return '<div class="alert alert-danger"><p>No se puede conectar a la Base de Datos, compruebe su usuario y contraseña</p></div>'
    end
    #puts "DBI:#{driver}:#{bd_name}:#{dominio}"
    #@conexion = DBI.connect("DBI:#{driver}:#{bd_name}:#{dominio}", usuario, pass)
  end
  
  def load_config_MySQL(bd_name)
    tablas = ''
    combo_string = []
    row_name = ''
    
    time1 = Time.now
    
    @aplicacion[:enlaces] = []
    @aplicacion[:tablas] = {}
    @aplicacion[:mejoras] = {}
    
    referidas = {}
    
    time11 = Time.now
    
    select = 'col.table_name, col.column_name, col.column_default, col.is_nullable, col.DATA_TYPE, col.CHARACTER_MAXIMUM_LENGTH, 
              col.COLUMN_KEY, col.PRIVILEGES, col.COLUMN_COMMENT, col.ORDINAL_POSITION, 
              col_u.CONSTRAINT_NAME, col_u.REFERENCED_TABLE_SCHEMA, col_u.REFERENCED_TABLE_NAME, col_u.REFERENCED_COLUMN_NAME '
    from = 'FROM INFORMATION_SCHEMA.columns as col left join INFORMATION_SCHEMA.key_column_usage as col_u 
                on col_u.table_name=col.table_name and col_u.column_name=col.column_name'
    order = ' ORDER BY col.table_name, col.ordinal_position '
    
	#@conexion.query('SELECT '+select+' '+from+' WHERE col.table_schema =\''+bd_name+'\' '+order).each_hash{ |row|
    @conexion['SELECT '+select+' '+from+' WHERE col.table_schema =\''+bd_name+'\' '+order].each{ |row|
      #print row[:column_name]
      
      time22 = Time.now
      puts row
      #puts "    consulta - Time elapsed #{(time22 - time11)*1000} milliseconds"

      if !row[:table_name].eql?(tablas)
        
        if (@aplicacion[:tablas][tablas] && 
            @aplicacion[:tablas][tablas]['config'][:combo_string_fk].length == 0)
          combo_string << row_name
        end
        
        @aplicacion[:enlaces] << row[:table_name]
        @aplicacion[:tablas][row[:table_name]] = {}
        @aplicacion[:mejoras][row[:table_name]] = {:min=>0, :max=>0, :minW=>0, :maxW=>0}
        
        config_tabla= {}
        config_tabla[:inner_join] = true

        #config_tabla[:nombre_grid] = row['table_name']
        #config_tabla[:ver_en_menu] = true
        #config_tabla[:nombre_menu] = row['table_name']

        config_tabla[:nombre_grid] = row[:table_name]
        config_tabla[:ver_en_menu] = true
        config_tabla[:nombre_menu] = row[:table_name]

        config_tabla[:insert_window] = true
        config_tabla[:edit_window] = true
        config_tabla[:detalle_de] = ''
        config_tabla[:referencias] = {}
        config_tabla[:paginador] = 10
        config_tabla[:combo_string_fk] = []
        @aplicacion[:tablas][row[:table_name]]['config'] = config_tabla
        @aplicacion[:tablas][row[:table_name]]['columnas'] = {}
      end
      tablas = row[:table_name]
      
      solo_texto = ['varchar', 'char', 'text', 'long_text']
      # => agregar las columnas
      columna= {}
      columna[:position] = row[:ORDINAL_POSITION]
      columna[:default_value] = row[:COLUMN_DEFAULT]
      columna[:is_nullable] = row[:is_nullable]
      columna[:data_type] = row[:DATA_TYPE].to_s   # varchar , char , text
      columna[:is_number] = 1
      columna[:is_number] = 0 if (solo_texto.index columna[:data_type] )
      columna[:length] = row[:CHARACTER_MAXIMUM_LENGTH]
      columna[:column_key] = row[:COLUMN_KEY]      # ['PRI', 'UNI', 'MUL']
      columna[:comments] = row[:COLUMN_COMMENT]
      
      # => datos sobre FK
      columna[:key_name] = row[:CONSTRAINT_NAME]
      columna[:esquema_rel] = row[:REFERENCED_TABLE_SCHEMA]
      columna[:tabla_rel] = row[:REFERENCED_TABLE_NAME]
      columna[:column_rel] = row[:REFERENCED_COLUMN_NAME]
      
      # => datos sobre FTP
      columna[:carpeta_ftp] = "/"
      columna[:es_archivo] = "0"  # 0=no 1=si
      
      # => configuración de vista
      columna[:vista_grid] = true
      columna[:texto_grid] = ''
      
      # => campos a mostrar en combo texto FK
      combo_string = @aplicacion[:tablas][tablas]['config'][:combo_string_fk]
      if ( (row[:DATA_TYPE].to_s=='varchar' || row[:DATA_TYPE].to_s=='char') )
        combo_string << row[:column_name]
        #puts row[:column_name]
      end
            
      @aplicacion[:tablas][tablas]['config'][:referidas] = []
      if columna[:tabla_rel]
        @aplicacion[:tablas][tablas]['config'][:referencias][columna[:tabla_rel]] = columna[:column_rel]
        @aplicacion[:tablas][tablas]['config'][:detalle_de] = columna[:tabla_rel]

        referidas[columna[:tabla_rel]] = []   unless ( referidas[columna[:tabla_rel]] )
        referidas[columna[:tabla_rel]] << tablas
      end
      row_name = row[:column_name]
      @aplicacion[:tablas][tablas]['columnas'][row[:column_name]] = columna
      
      time11 = Time.now
    }    
    
    if (@aplicacion[:tablas][tablas] && 
        @aplicacion[:tablas][tablas]['config'][:combo_string_fk].length == 0)
      combo_string << row_name
    end
        
    referidas.each{ |tabla, tablas_ref|
      @aplicacion[:tablas][tabla]['config'][:referidas] = tablas_ref
    }
    
    time2 = Time.now
    puts "load_BD MySQL - Time elapsed #{(time2 - time1)*1000} milliseconds"
    
    return '<div class="alert alert-success"><p>Confuración BD cargada con éxito</p></div>'
  end

  # => subselect = 1 es para que sigua ejecutando las select de las tablas relacionadas
  def select_mysql(select, tabla, params, start_limit, subselects)
    refresh
    time1 = Time.now
    filas = Hash.new
    cont = 0
    
    ordenar_sql = ordenar_create(tabla, params)
    where_sql = buscar_create(tabla, params)
    limit = ' LIMIT ' + @aplicacion[:tablas][tabla]['config'][:paginador].to_s + ' OFFSET ' + start_limit.to_s
            
        #@aplicacion[:tablas][tabla]['config'][:paginador] = 10 
    
    select = ''
    from = tabla
    alias_SQL = 1
    alias_campos = 1
    #@aplicacion[:tablas][tabla].each {|key, value| select << "#{key}," if (value[:column_key] != 'PRI' )}
    @aplicacion[:tablas][tabla]['columnas'].each {|key, value|
      
      time3 = Time.now
      select = select+"#{tabla}.#{key},"
      if (value[:column_rel])
        from = from+' left join '+value[:tabla_rel]+' as '+value[:tabla_rel]+'_'+alias_SQL.to_s
        from = from+' on '+tabla+'.'+key+'='+value[:tabla_rel]+'_'+alias_SQL.to_s+'.'+value[:column_rel]
        select = select+"#{value[:tabla_rel]}_#{alias_SQL.to_s}.#{value[:column_rel]} "
        select = select+" as #{value[:tabla_rel]}_#{value[:column_rel]}_#{alias_campos}," 
        
        puts select
        puts from
        
        combo = @aplicacion[:tablas][value[:tabla_rel]]['config'][:combo_string_fk]
        combo_string = ''
        
        if (combo.length > 0)
          select = select+"#{value[:tabla_rel]}_#{alias_SQL.to_s}.#{combo.first} "
          select = select+" as #{value[:tabla_rel]}_#{combo.first}_#{alias_campos},"
          combo.each{ |val| combo_string += val+','}
          alias_campos = alias_campos + 1
        end
        
        unless filas[value[:tabla_rel]]
          filas[value[:tabla_rel]] = simple_select( combo_string+value[:column_rel], value[:tabla_rel], '','','')
        end
      end
      
      alias_SQL = alias_SQL + 1
      time2 = Time.now
      #puts "    bucle select general - Time elapsed #{(time2 - time3)*1000} milliseconds"
    }
    select = select[0..-2]
    
    filas[tabla] = simple_select(select, from, where_sql, ordenar_sql, limit)
        
    filas[:filas_detalle] = {}
    sub_params = get_sub_params(params)
    
    @aplicacion[:tablas][tabla]['config'][:referidas].each {|key, value|
      unless(subselects==1 && filas[:filas_detalle][key])      
        filas[:filas_detalle][key] = select_mysql('*', key, sub_params, 0, 0)
      end
    }
    
    filas['filas_total'] = simple_select(' COUNT(*) as total ', from, where_sql, '', '')
    #puts filas
    
    time2 = Time.now
    #puts "select general - Time elapsed #{(time2 - time1)*1000} milliseconds"
    
    return filas
  end
  
  def simple_select(select, from, where_sql, ordenar_sql, limit)
    refresh
    
    filas = Hash.new
    cont = 0
    
    #puts 'simple_select()'
    puts 'SELECT '+select
    puts 'FROM '+from+' '+where_sql+' '+ordenar_sql+limit
    #@conexion.query('SELECT '+select+' FROM '+from+' '+where_sql+' '+ordenar_sql+limit.to_s).each_hash{ |row|
    @conexion['SELECT '+select+' FROM '+from+' '+where_sql+' '+ordenar_sql+limit.to_s].each{ |row|
      filas["#{cont}"] = row
      cont += 1
    }
    #puts 'SELECT * '+from+' '+where_sql+' '+ordenar_sql +limit
    return filas        
  end  
  
  def one_select_sin_count(select, from, where_sql, ordenar_sql, limit)
    refresh
    #puts 'SELECT '+select + ' '+ from+' '+where_sql+' '+ordenar_sql +limit
    
    #return @conexion.query('SELECT '+select+' '+from+' '+where_sql+' '+ordenar_sql +limit)
    return @conexion['SELECT '+select+' '+from+' '+where_sql+' '+ordenar_sql +limit]
  end  


# => errores SQL

# - Duplicate entry '1' for key 'PRIMARY'

end