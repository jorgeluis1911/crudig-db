class PSqlconex < Aplicacion

  def load_bd( driver, dominio, usuario, pass, bd_name, port)
    #@conexion = Mysql.new('127.0.0.1', 'root', '', 'recetas')
    #real_connect(host=nil, user=nil, passwd=nil, db=nil, port=nil, sock=nil, flag=nil).
    begin
      @conexion = PG::Connection.new(:host=>dominio, :user=>usuario, :password=>pass, :dbname=>bd_name, :port=>port, )
      
      raise( rb_ePGerror , "PQconnectdb() unable to allocate structure")   unless(@conexion)
        
      @aplicacion[:config][:bd]=bd_name
      @aplicacion[:config][:host]=dominio
      @aplicacion[:config][:user]=usuario
      @aplicacion[:config][:pass]=pass
      @aplicacion[:config][:driver]=driver
      @aplicacion[:config][:port]=port
      
      return load_config_PS( bd_name )
    rescue PG::Error => err
      #puts err
      return '<div class="alert alert-danger"><p>No se puede conectar a la Base de Datos, compruebe su usuario y contraseña</p></div>'
    end
    #puts "DBI:#{driver}:#{bd_name}:#{dominio}"
    #@conexion = DBI.connect("DBI:#{driver}:#{bd_name}:#{dominio}", usuario, pass)
  end
  
  def load_config_PS(bd_name)
    tablas = ''
    
    @aplicacion[:enlaces] = []
    @aplicacion[:tablas] = {}
    
    referidas = {}
    
    select = 'col.table_name, col.column_name, col.column_default, col.is_nullable, col.data_type, col.CHARACTER_MAXIMUM_LENGTH, 
              col.ORDINAL_POSITION, 
              col_u.CONSTRAINT_NAME, col_u.table_catalog as ref_table_catalog, 
              col_u.TABLE_NAME as ref_table_name, col_u.COLUMN_NAME as ref_column_name'
    from = ' FROM INFORMATION_SCHEMA.columns as col left join INFORMATION_SCHEMA.key_column_usage as col_u 
                on col_u.table_name=col.table_name and col_u.column_name=col.column_name'
    where = ' WHERE col.table_catalog =\''+bd_name+'\' and col.table_schema=\'public\''
    order = ' ORDER BY col.table_name, col.ordinal_position '
    
    @conexion.exec('SELECT '+select+' '+from+' '+where+' '+order) do |result|
    
      result.each{ |row|
        #print row['column_name']        
        next unless row['table_name']
        
        if !row['table_name'].eql?(tablas)
          @aplicacion[:enlaces] << row['table_name']
          @aplicacion[:tablas][row['table_name']] = {}
          
          config_tabla= {}
          config_tabla[:inner_join] = true
          config_tabla[:nombre_grid] = ''
          config_tabla[:ver_en_menu] = true
          config_tabla[:insert_window] = true
          config_tabla[:edit_window] = true
          config_tabla[:detalle_de] = ''
          config_tabla[:referencias] = {}
          config_tabla[:paginador] = 10
          @aplicacion[:tablas][row['table_name']]['config'] = config_tabla
          @aplicacion[:tablas][row['table_name']]['columnas'] = {}
        end
        tablas = row['table_name']
        
        # => agregar las columnas
        columna= {}
        columna[:position] = row['ordinal_position']
        columna[:default_value] = "" #row['COLUMN_DEFAULT']
        columna[:is_nullable] = row['is_nullable']
        columna[:data_type] = row['data_type'].to_s
        columna[:length] = row['character_maximum_length']
        columna[:column_key] = "" #row['COLUMN_KEY']      # ['PRI', 'UNI', 'MUL']
        columna[:comments] = "" #row['COLUMN_COMMENT']
        
        # => datos sobre FK
        columna[:key_name] = row['constraint_name']
        columna[:esquema_rel] = row['ref_table_catalog']
        columna[:tabla_rel] = row['ref_table_name']
        columna[:column_rel] = row['ref_column_name']
              
        # => datos sobre FTP
        columna[:carpeta_ftp] = "/"
        columna[:es_archivo] = "0"  # 0=no 1=si
        
        # => configuración de vista
        columna[:vista_grid] = true
        columna[:texto_grid] = ''
        
        pkey = ''
        pkey = columna[:key_name][-4, 4]   if(columna[:key_name])
        columna[:column_key] = 'PRI'       if(pkey == 'pkey')
          
        @aplicacion[:tablas][tablas]['config'][:referidas] = []
        if ( columna[:tabla_rel] &&  (pkey != 'pkey'))
          @aplicacion[:tablas][tablas]['config'][:referencias][columna[:tabla_rel]] = columna[:column_rel]
          @aplicacion[:tablas][tablas]['config'][:detalle_de] = columna[:tabla_rel]
  
          referidas[columna[:tabla_rel]] = []   unless ( referidas[columna[:tabla_rel]] )
          referidas[columna[:tabla_rel]] << tablas
        end
        @aplicacion[:tablas][tablas]['columnas'][row['column_name']] = columna
      }
    end
    
    referidas.each{ |tabla, tablas_ref|   
      @aplicacion[:tablas][tabla]['config'][:referidas] = tablas_ref
    }
    
    return '<div class="alert alert-success"><p>Confuración BD cargada con éxito</p></div>'
  end  

  def select_mysql(select, tabla, params, start_limit)
    filas = Hash.new
    cont = 0
    
    ordenar_sql = ordenar_create(tabla, params)
    where_sql = buscar_create(tabla, params)
    limit = ' LIMIT '+ @aplicacion[:tablas][tabla]['config'][:paginador].to_s + ' OFFSET ' + start_limit.to_s
            
        #@aplicacion[:tablas][tabla]['config'][:paginador] = 7 
    
    select = ''
    from = 'FROM '+tabla
    #@aplicacion[:tablas][tabla].each {|key, value| select << "#{key}," if (value[:column_key] != 'PRI' )}
    @aplicacion[:tablas][tabla]['columnas'].each {|key, value| 
      select << "#{tabla}.#{key},"
      pkey = ''
      pkey = value[:key_name][-4, 4]   if(value[:key_name])
      if (value[:column_rel] && (pkey != 'pkey'))
        from << ' left join '+value[:tabla_rel]+' on '+tabla+'.'+key+'='+value[:tabla_rel]+'.'+value[:column_rel]
        select << "#{value[:tabla_rel]}.#{value[:column_rel]} as #{value[:tabla_rel]}_#{value[:column_rel]},"
        
        filas[value[:tabla_rel]] = simple_select( value[:column_rel], ' FROM '+value[:tabla_rel],'','','')
      end
    }
    select = select[0..-2]
    
    filas[tabla] = simple_select(select, from, where_sql, ordenar_sql, limit)
        
    filas[:filas_detalle] = {}
    sub_params = get_sub_params(params)
    
    @aplicacion[:tablas][tabla]['config'][:referidas].each {|key, value|
      unless(filas[:filas_detalle][key])
        filas[:filas_detalle][key] = select_mysql('*', key, sub_params, 0)
      end
    }
    
    filas['filas_total'] = simple_select(' COUNT(*) as total ', from, where_sql, '', '')
    return filas
  end
  
  def simple_select(select, from, where_sql, ordenar_sql, limit)
    refresh
    
    filas = Hash.new
    cont = 0
    
    puts 'SELECT '+select+' '+from+' '+where_sql+' '+ordenar_sql +limit
    @conexion.exec('SELECT '+select+' '+from+' '+where_sql+' '+ordenar_sql +limit).each { |row|
      filas["#{cont}"] = row
      cont += 1
    }
    #puts 'SELECT * '+from+' '+where_sql+' '+ordenar_sql +limit
    return filas        
  end
  
  def one_select_sin_count(select, from, where_sql, ordenar_sql, limit)
    refresh
    
    puts 'SELECT '+select + ' '+ from+' '+where_sql+' '+ordenar_sql +limit
    return @conexion['SELECT '+select+' '+from+' '+where_sql+' '+ordenar_sql +limit]
  end  

end