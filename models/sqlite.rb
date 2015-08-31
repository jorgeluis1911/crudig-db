class Sqliteconex < Aplicacion

  def load_bd( driver, rutaFiles, bd_file)
    #@conexion = Mysql.new('127.0.0.1', 'root', '', 'recetas')
    #real_connect(host=nil, user=nil, passwd=nil, db=nil, port=nil, sock=nil, flag=nil).

    begin
      Sequel.datetime_class = Date
      #Sequel.convert_two_digit_years = false
      
      #puts 'sqlite://'+rutaFiles
      @conexion = Sequel.connect('sqlite://'+rutaFiles+'/'+bd_file)
      #Sequel.connect('sqlite://./upload_sqlite/20150820_180140_example.db')
      
      # raise( rb_ePGerror , "PQconnectdb() unable to allocate structure")   unless(@conexion)
      
      @aplicacion[:config][:bd]=bd_file
      @aplicacion[:config][:host]=''  #dominio
      @aplicacion[:config][:user]=''  #usuario
      @aplicacion[:config][:pass]=''  #pass
      @aplicacion[:config][:driver]=driver
      @aplicacion[:config][:port]=''  #port
      
      puts Date.parse('2014-03-05', true)
      
      #@conexion.convert_invalid_date_time = nil
      
      # bd_name es bd_file 
      return load_config_SQLite( bd_file )
    rescue Sequel::Error => e
      puts e
      return '<div class="alert alert-danger"><p>No se puede conectar a la Base de Datos, compruebe su usuario y contraseña</p></div>'
    end
    #puts "DBI:#{driver}:#{bd_name}:#{dominio}"
    #@conexion = DBI.connect("DBI:#{driver}:#{bd_name}:#{dominio}", usuario, pass)
  end
  
  def load_config_SQLite(bd_name)
    # bd_name es bd_file
    tablas = ''
    combo_string = []
    row_name = ''
    
    time1 = Time.now
    
    @aplicacion[:enlaces] = []
    @aplicacion[:tablas] = {}
    @aplicacion[:mejoras] = {}
    
    referidas = {}
    
    time11 = Time.now
=begin    
    select = 'col.table_name, col.column_name, col.column_default, col.is_nullable, col.DATA_TYPE, col.CHARACTER_MAXIMUM_LENGTH, 
              col.COLUMN_KEY, col.PRIVILEGES, col.COLUMN_COMMENT, col.ORDINAL_POSITION, 
              col_u.CONSTRAINT_NAME, col_u.REFERENCED_TABLE_SCHEMA, col_u.REFERENCED_TABLE_NAME, col_u.REFERENCED_COLUMN_NAME '
    from = 'FROM INFORMATION_SCHEMA.columns as col left join INFORMATION_SCHEMA.key_column_usage as col_u 
                on col_u.table_name=col.table_name and col_u.column_name=col.column_name'
    order = ' ORDER BY col.table_name, col.ordinal_position '
    #@conexion.query('SELECT '+select+' '+from+' WHERE col.table_schema =\''+bd_name+'\' '+order).each_hash{ |row|
=end

    select = ' sqlm.type, sqlm.tbl_name as table_name, sqlm.name, sqlm.rootpage '
    from = ' FROM sqlite_master as sqlm '
    where = ' WHERE sqlm.type =\'table\' '
    order = ' ORDER BY sqlm.tbl_name '
    
    # type = ( table, index, view, trigger )
    
    @conexion['SELECT '+select+' '+from+' '+where+' '+order].each{ |row|
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
      
      solo_texto = ['varchar', 'nchar', 'text', 'long_text', 
                    'CHARACTER', 'VARYING CHARACTER',
                    'NATIVE CHARACTER','NVARCHAR', 'CLOB']
      
      # =>  'CHARACTER(20)', 'VARCHAR(255)', 'VARYING CHARACTER(255)'
      #     'NCHAR(55)', 'NATIVE CHARACTER(70)',
      #     'NVARCHAR(100)', 'TEXT', 'CLOB'
      
      
      # => agregar las columnas
      
      @conexion[' PRAGMA table_info('+tablas+')'].each{ |cols|
      
        columna= {}
        columna[:position] = cols[:cid]
        columna[:default_value] = cols[:dflt_value]
        columna[:is_nullable] = cols[:notnull]
        
        # => "hello".partition("l")   #=> ["he", "l", "lo"]
        arrayDe3 = cols[:type].to_s.partition('(')
        
        columna[:data_type] = arrayDe3[0]   # varchar , char , text
        
        if (solo_texto.index { |x| columna[:data_type].include?(x) } )
          columna[:is_number] = 0   # solo texto
          
          columna[:length] = (arrayDe3[2] != '' ? arrayDe3[2].partition(')')[0] : nil)
        else
          columna[:is_number] = 1   # solo numero
          
          # => falta el Decimal(10,2)
          columna[:length] = nil    #row[:CHARACTER_MAXIMUM_LENGTH]
        end
        columna[:column_key] = nil #row[:COLUMN_KEY]      # ['PRI', 'UNI', 'MUL']
        columna[:comments] = '' #row[:COLUMN_COMMENT]
        
        # => datos sobre FK
        columna[:key_name] = nil #row[:CONSTRAINT_NAME]
        columna[:esquema_rel] = nil #row[:REFERENCED_TABLE_SCHEMA]
        columna[:tabla_rel] = nil #row[:REFERENCED_TABLE_NAME]
        columna[:column_rel] = nil #row[:REFERENCED_COLUMN_NAME]
        
        # => datos sobre FTP
        columna[:carpeta_ftp] = "/"
        columna[:es_archivo] = "0"  # 0=no 1=si
        
        # => configuración de vista
        columna[:vista_grid] = true
        columna[:texto_grid] = ''
        
        # => campos a mostrar en combo texto FK
        combo_string = @aplicacion[:tablas][tablas]['config'][:combo_string_fk]
        if ( (cols[:data_type].to_s=='varchar' || cols[:data_type].to_s=='char') )
          combo_string << cols[:name]
          #puts row[:column_name]
        end
              
        @aplicacion[:tablas][tablas]['config'][:referidas] = []
        
=begin
        if columna[:tabla_rel]
          @aplicacion[:tablas][tablas]['config'][:referencias][columna[:tabla_rel]] = columna[:column_rel]
          @aplicacion[:tablas][tablas]['config'][:detalle_de] = columna[:tabla_rel]
  
          referidas[columna[:tabla_rel]] = []   unless ( referidas[columna[:tabla_rel]] )
          referidas[columna[:tabla_rel]] << tablas
        end
=end
        row_name = cols[:name]
        
        @aplicacion[:tablas][tablas]['columnas'][row_name] = columna
      }
      
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

  def select_mysql(select, tabla, params, start_limit)
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
          filas[value[:tabla_rel]] = simple_select( combo_string+value[:column_rel], value[:tabla_rel],'','','')
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
      unless(filas[:filas_detalle][key])
        filas[:filas_detalle][key] = select_mysql('*', key, sub_params, 0)
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