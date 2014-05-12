class Aplicacion
  
  attr_reader :aplicacion
  attr_reader :conexion
  
  def initialize( args )
    @aplicacion = args
    @conexion = nil
  end
      
  def update_mysql(select, tabla, where)
    load_bd unless(@@conexion)
    filas = Hash.new
    cont = 0
    
    select = ''
    @aplicacion[:tablas].each {|key, value| select << "#{key}," if (value[:column_key] != 'PRI' )}
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
    @aplicacion[:tablas].each {|key, value| select << "#{key}," if (value[:column_key] != 'PRI' )}
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
      if (@aplicacion[:tablas][tabla]['columnas'][key])
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
  
end