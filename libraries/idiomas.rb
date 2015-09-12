class App < Sinatra::Application
  
  @@idiomas = Hash.new
  @@idiomas = {'es'=>{},  'en'=>{},  'fr'=>{},  'de'=>{},  'it'=>{},  'pr'=>{}}
  
  # => en = INGLES /  es = ESPAÑOL / fr = FRANCES / de = ALEMAN  / it =ITALIANO / pr =PORTUGUES
  
# => ESPAÑOL  
  
  @@idiomas['es'][:config] = { :btn_guardar => '',        :btn_cancelar => '',
                             :btn_editar => '',         :btn_conectar => ''   }

  @@idiomas['es'][:menu] = { :crudig => 'CRUDig v0.1',
                           :mejoras=> 'Mejoras',   :config => 'Config', 
                           :configuraciones => 'Configuraciones',
                           :nueva_config => 'Nueva Configuración',
                     
                     :info => 'Info',             :ayuda => 'Ayuda',    :caract => 'Características',
                     :versiones => 'Versiones',   :demos => 'Demos',
                     
                     :graficos => 'Gráficos',             :chart_area => 'Áreas',
                     :chart_circulo => 'Círculos',        :chart_barras => 'Barras',
                     :chart_columnas => 'Columnas',       :chart_combo  => 'Combos',
                     :chart_lineas => 'Líneas',           :mis_graficos => 'Mis Gráficos',
                   }
  
  @@idiomas['es'][:mensajes] = { :config => '', :config => ''}
  
  @@idiomas['es'][:ayuda_menu] = { :empezando => 'Empezando', 
                                   :conectar_BD => 'Conectar BD', :conectar_FTP => 'Conectar FTP',
                                   :config_tablas => 'Configurar Tablas', :config_cols => 'Configurar Columnas',
                                   :demos => 'Demos', 
                                   
                     :formularios => 'Formularios y Tablas',
                     :insercion => 'Inserción', :edicion => 'Edición', :busquedas => 'Busquedas', 
                     :autorecargas => 'Autorecargar', :informes => 'Informes', 
                     
                     :graficos => 'Gráficos',
                     :areas => 'Áreas', :circulos => 'Círculos', :barras => 'Barras', 
                     :columnas => 'Columnas', :combos => 'Combos', :lineas => 'Líneas',
                     :mis_graficos=> 'Mis gráficos', 
                     
                     :config => 'Config', :configuraciones=> 'Configuraciones', :usuarios => 'Usuarios'}

  @@idiomas['es'][:ayuda_secciones] = { :empezando_h2 => 'Empezando',
                                       :conectar_BD_h4 => 'Conectar BD', :conectar_FTP_h4 => 'Conectar FTP',
                                       :config_tablas_h4 => 'Configurar Tablas', :config_cols_h4 => 'Configurar Columnas',
                                       :demos_h4 => 'Demos',
                     
                     :formularios_h2 => 'Formularios y Tablas',
                     :insercion_h4 => 'Inserción', :edicion_h4 => 'Edición', :busquedas_h4 => 'Busquedas', 
                     :autorecargas_h4 => 'Autorecargar', :informes_h4 => 'Informes', 
                     
                     :graficos_h2 => 'Gráficos',
                     :areas_h4 => 'Áreas', :circulos_h4 => 'Círculos', :barras_h4 => 'Barras', 
                     :columnas_h4 => 'Columnas', :combos_h4 => 'Combos', :lineas_h4 => 'Líneas',
                     :mis_graficos_h4 => 'Mis gráficos', 
                     
                     :config_h2 => 'Config', :configuraciones_h4 => 'Configuraciones', :usuarios_h4 => 'Usuarios'}                

  @@idiomas['es'][:ayuda_textos] = {:empezando_text => 'texto',
                                    :conectar_BD_text => 'texto BD', :conectar_FTP_text => 'texto FTP',
                                    :config_tablas_text => 'texto Tablas', :config_cols_text => 'texto Columnas',
                                    :demos_text => 'texto',
                                    
                     :formularios_text => 'Formularios y Tablas',
                     :insercion_text => 'Inserción', :edicion_text => 'Edición', :busquedas_text => 'Busquedas', 
                     :autorecargas_text => 'Autorecargar', :informes_text => 'Informes', 
                     
                     :graficos_text => 'Gráficos',
                     :areas_text => 'Áreas', :circulos_text => 'Círculos', :barras_text => 'Barras', 
                     :columnas_text => 'Columnas', :combos_text => 'Combos', :lineas_text => 'Líneas',
                     :mis_graficos_text => 'Mis gráficos', 
                     
                     :config_text => 'Config', :configuraciones_text => 'Configuraciones', :usuarios_text => 'Usuarios'} 

# => INGLES  

  @@idiomas['en'][:config] = { :btn_guardar => '',        :btn_cancelar => '',
                             :btn_editar => '',         :btn_conectar => ''   }

  @@idiomas['en'][:menu] = { :crudig => 'CRUDig v0.1',
                           :mejoras=> 'Mejoras',   :config => 'Config',
                           :configuraciones => 'Configurations',
                           :nueva_config => 'New Configuration',
                     
                     :info => 'Info',             :ayuda => 'Help',    :caract => 'Characteristics',
                     :versiones => 'Versions',   :demos => 'Demos',
                     
                     :graficos => 'Graphics',             :chart_area => 'Areas',
                     :chart_circulo => 'Circles',        :chart_barras => 'Barras',
                     :chart_columnas => 'Columns',       :chart_combo  => 'Combos',
                     :chart_lineas => 'Lines',           :mis_graficos => 'My Grafics',
                   }
  
  @@idiomas['en'][:mensajes] = { :config => '', :config => ''}  
  
  @@idiomas['en'][:ayuda_menu] = { :empezando => 'Get starting',
                                   :conectar_BD => 'Conect BD', :conectar_FTP => 'Conect FTP',
                                   :config_tablas => 'Configurate Tables', :config_cols => 'Configurate Columns',
                                   :demos => 'Demos', 
                                   
                     :formularios => 'Forms and Tables',
                     :insercion => 'Inserts', :edicion => 'Editions', :busquedas => 'Searchs', 
                     :autorecargas => 'Autorecargar', :informes => 'Informes', 
                     
                     :graficos => 'Graphics',
                     :areas => 'Areas', :circulos => 'Circles', :barras => 'Barras', 
                     :columnas => 'Columns', :combos => 'Combos', :lineas => 'Lines',
                     :mis_graficos=> 'My Grafics', 
                     
                     :config => 'Config', :configuraciones=> 'Configurations', :usuarios => 'Users'}

  @@idiomas['en'][:ayuda_secciones] = { :empezando_h2 => 'Empezando',
                                       :conectar_BD_h4 => 'Conectar BD', :conectar_FTP_h4 => 'Conectar FTP',
                                       :config_tablas_h4 => 'Configurar Tablas', :config_cols_h4 => 'Configurar Columnas',
                                       :demos_h4 => 'Demos',
                     
                     :formularios_h2 => 'Formularios y Tablas',
                     :insercion_h4 => 'Inserción', :edicion_h4 => 'Edición', :busquedas_h4 => 'Busquedas', 
                     :autorecargas_h4 => 'Autorecargar', :informes_h4 => 'Informes', 
                     
                     :graficos_h2 => 'Gráficos',
                     :areas_h4 => 'Áreas', :circulos_h4 => 'Círculos', :barras_h4 => 'Barras', 
                     :columnas_h4 => 'Columnas', :combos_h4 => 'Combos', :lineas_h4 => 'Líneas',
                     :mis_graficos_h4 => 'Mis gráficos', 
                     
                     :config_h2 => 'Config', :configuraciones_h4 => 'Configuraciones', :usuarios_h4 => 'Usuarios'}                

  @@idiomas['en'][:ayuda_textos] = {:empezando_text => 'texto',
                                    :conectar_BD_text => 'texto BD', :conectar_FTP_text => 'texto FTP',
                                    :config_tablas_text => 'texto Tablas', :config_cols_text => 'texto Columnas',
                                    :demos_text => 'texto',
                                    
                     :formularios_text => 'Formularios y Tablas',
                     :insercion_text => 'Inserción', :edicion_text => 'Edición', :busquedas_text => 'Busquedas', 
                     :autorecargas_text => 'Autorecargar', :informes_text => 'Informes', 
                     
                     :graficos_text => 'Gráficos',
                     :areas_text => 'Áreas', :circulos_text => 'Círculos', :barras_text => 'Barras', 
                     :columnas_text => 'Columnas', :combos_text => 'Combos', :lineas_text => 'Líneas',
                     :mis_graficos_text => 'Mis gráficos', 
                     
                     :config_text => 'Config', :configuraciones_text => 'Configuraciones', :usuarios_text => 'Usuarios'} 


# => fr = FRANCES 


  @@idiomas['fr'][:config] = { :btn_guardar => '',        :btn_cancelar => '',
                             :btn_editar => '',         :btn_conectar => ''   }

  @@idiomas['fr'][:menu] = { :crudig => 'CRUDig v0.1',
                           :mejoras=> 'Mejoras',   :config => 'Config',
                           :configuraciones => 'Configurations',
                           :nueva_config => 'Nouvelle Configuration',
                     
                     :info => 'Info',             :ayuda => 'Aide',    :caract => 'Caractéristiques',
                     :versiones => 'Versions',   :demos => 'Demos',
                     
                     :graficos => 'Graphics',             :chart_area => 'Zones',
                     :chart_circulo => 'Cercles',        :chart_barras => 'Barras',
                     :chart_columnas => 'Colonnes',       :chart_combo  => 'Combos',
                     :chart_lineas => 'Lignes',           :mis_graficos => 'Mes Graphques',
                   }
  
  @@idiomas['fr'][:mensajes] = { :config => '', :config => ''}  
  
  @@idiomas['fr'][:ayuda_menu] = { :empezando => 'Get starting',
                                   :conectar_BD => 'Conect BD', :conectar_FTP => 'Conect FTP',
                                   :config_tablas => 'Configurate Tables', :config_cols => 'Configurate Columns',
                                   :demos => 'Demos', 
                                   
                     :formularios => 'Forms and Tables',
                     :insercion => 'Inserts', :edicion => 'Editions', :busquedas => 'Searchs', 
                     :autorecargas => 'Autorecargar', :informes => 'Informes', 
                     
                     :graficos => 'Graphics',
                     :areas => 'Areas', :circulos => 'Circles', :barras => 'Barras', 
                     :columnas => 'Columns', :combos => 'Combos', :lineas => 'Lines',
                     :mis_graficos=> 'My Grafics', 
                     
                     :config => 'Config', :configuraciones=> 'Configurations', :usuarios => 'Users'}

  @@idiomas['fr'][:ayuda_secciones] = { :empezando_h2 => 'Empezando',
                                       :conectar_BD_h4 => 'Conectar BD', :conectar_FTP_h4 => 'Conectar FTP',
                                       :config_tablas_h4 => 'Configurar Tablas', :config_cols_h4 => 'Configurar Columnas',
                                       :demos_h4 => 'Demos',
                     
                     :formularios_h2 => 'Formularios y Tablas',
                     :insercion_h4 => 'Inserción', :edicion_h4 => 'Edición', :busquedas_h4 => 'Busquedas', 
                     :autorecargas_h4 => 'Autorecargar', :informes_h4 => 'Informes', 
                     
                     :graficos_h2 => 'Gráficos',
                     :areas_h4 => 'Áreas', :circulos_h4 => 'Círculos', :barras_h4 => 'Barras', 
                     :columnas_h4 => 'Columnas', :combos_h4 => 'Combos', :lineas_h4 => 'Líneas',
                     :mis_graficos_h4 => 'Mis gráficos', 
                     
                     :config_h2 => 'Config', :configuraciones_h4 => 'Configuraciones', :usuarios_h4 => 'Usuarios'}                

  @@idiomas['fr'][:ayuda_textos] = {:empezando_text => 'texto',
                                    :conectar_BD_text => 'texto BD', :conectar_FTP_text => 'texto FTP',
                                    :config_tablas_text => 'texto Tablas', :config_cols_text => 'texto Columnas',
                                    :demos_text => 'texto',
                                    
                     :formularios_text => 'Formularios y Tablas',
                     :insercion_text => 'Inserción', :edicion_text => 'Edición', :busquedas_text => 'Busquedas', 
                     :autorecargas_text => 'Autorecargar', :informes_text => 'Informes', 
                     
                     :graficos_text => 'Gráficos',
                     :areas_text => 'Áreas', :circulos_text => 'Círculos', :barras_text => 'Barras', 
                     :columnas_text => 'Columnas', :combos_text => 'Combos', :lineas_text => 'Líneas',
                     :mis_graficos_text => 'Mis gráficos', 
                     
                     :config_text => 'Config', :configuraciones_text => 'Configuraciones', :usuarios_text => 'Usuarios'} 


# => de = ALEMAN  


  @@idiomas['de'][:config] = { :btn_guardar => '',        :btn_cancelar => '',
                             :btn_editar => '',         :btn_conectar => ''   }

  @@idiomas['de'][:menu] = { :crudig => 'CRUDig v0.1',
                           :mejoras=> 'Mejoras',   :config => 'Config',
                           :configuraciones => 'Konfigurationen',
                           :nueva_config => 'Neue Konfiguration',
                     
                     :info => 'Info',             :ayuda => 'Aid',    :caract => 'Features',
                     :versiones => 'Versionen',   :demos => 'Demos',
                     
                     :graficos => 'Graphics',             :chart_area => 'Bereichen',
                     :chart_circulo => 'Circles',        :chart_barras => 'Barras',
                     :chart_columnas => 'Spalten',       :chart_combo  => 'Combos',
                     :chart_lineas => 'Lines',           :mis_graficos => 'Meine Grafik',
                   }
  
  @@idiomas['de'][:mensajes] = { :config => '', :config => ''}  
  
  @@idiomas['de'][:ayuda_menu] = { :empezando => 'Get starting',
                                   :conectar_BD => 'Conect BD', :conectar_FTP => 'Conect FTP',
                                   :config_tablas => 'Configurate Tables', :config_cols => 'Configurate Columns',
                                   :demos => 'Demos', 
                                   
                     :formularios => 'Forms and Tables',
                     :insercion => 'Inserts', :edicion => 'Editions', :busquedas => 'Searchs', 
                     :autorecargas => 'Autorecargar', :informes => 'Informes', 
                     
                     :graficos => 'Graphics',
                     :areas => 'Areas', :circulos => 'Circles', :barras => 'Barras', 
                     :columnas => 'Columns', :combos => 'Combos', :lineas => 'Lines',
                     :mis_graficos=> 'My Grafics', 
                     
                     :config => 'Config', :configuraciones=> 'Configurations', :usuarios => 'Users'}

  @@idiomas['de'][:ayuda_secciones] = { :empezando_h2 => 'Empezando',
                                       :conectar_BD_h4 => 'Conectar BD', :conectar_FTP_h4 => 'Conectar FTP',
                                       :config_tablas_h4 => 'Configurar Tablas', :config_cols_h4 => 'Configurar Columnas',
                                       :demos_h4 => 'Demos',
                     
                     :formularios_h2 => 'Formularios y Tablas',
                     :insercion_h4 => 'Inserción', :edicion_h4 => 'Edición', :busquedas_h4 => 'Busquedas', 
                     :autorecargas_h4 => 'Autorecargar', :informes_h4 => 'Informes', 
                     
                     :graficos_h2 => 'Gráficos',
                     :areas_h4 => 'Áreas', :circulos_h4 => 'Círculos', :barras_h4 => 'Barras', 
                     :columnas_h4 => 'Columnas', :combos_h4 => 'Combos', :lineas_h4 => 'Líneas',
                     :mis_graficos_h4 => 'Mis gráficos', 
                     
                     :config_h2 => 'Config', :configuraciones_h4 => 'Configuraciones', :usuarios_h4 => 'Usuarios'}                

  @@idiomas['de'][:ayuda_textos] = {:empezando_text => 'texto',
                                    :conectar_BD_text => 'texto BD', :conectar_FTP_text => 'texto FTP',
                                    :config_tablas_text => 'texto Tablas', :config_cols_text => 'texto Columnas',
                                    :demos_text => 'texto',
                                    
                     :formularios_text => 'Formularios y Tablas',
                     :insercion_text => 'Inserción', :edicion_text => 'Edición', :busquedas_text => 'Busquedas', 
                     :autorecargas_text => 'Autorecargar', :informes_text => 'Informes', 
                     
                     :graficos_text => 'Gráficos',
                     :areas_text => 'Áreas', :circulos_text => 'Círculos', :barras_text => 'Barras', 
                     :columnas_text => 'Columnas', :combos_text => 'Combos', :lineas_text => 'Líneas',
                     :mis_graficos_text => 'Mis gráficos', 
                     
                     :config_text => 'Config', :configuraciones_text => 'Configuraciones', :usuarios_text => 'Usuarios'} 


# => it =ITALIANO 



  @@idiomas['it'][:config] = { :btn_guardar => '',        :btn_cancelar => '',
                             :btn_editar => '',         :btn_conectar => ''   }

  @@idiomas['it'][:menu] = { :crudig => 'CRUDig v0.1',
                           :mejoras=> 'Mejoras',   :config => 'Config',
                           :configuraciones => 'Configurazioni',
                           :nueva_config => 'Nuova Configurazione',
                     
                     :info => 'Info',             :ayuda => 'Aiuti',    :caract => 'Caratteristiche',
                     :versiones => 'Versioni',   :demos => 'Demos',
                     
                     :graficos => 'Grafica',             :chart_area => 'Aree',
                     :chart_circulo => 'Circles',        :chart_barras => 'Barras',
                     :chart_columnas => 'Colonne',       :chart_combo  => 'Combo',
                     :chart_lineas => 'Linee',           :mis_graficos => 'Miei grafica',
                   }
  
  @@idiomas['it'][:mensajes] = { :config => '', :config => ''}  
  
  @@idiomas['it'][:ayuda_menu] = { :empezando => 'Get starting',
                                   :conectar_BD => 'Conect BD', :conectar_FTP => 'Conect FTP',
                                   :config_tablas => 'Configurate Tables', :config_cols => 'Configurate Columns',
                                   :demos => 'Demos', 
                                   
                     :formularios => 'Forms and Tables',
                     :insercion => 'Inserts', :edicion => 'Editions', :busquedas => 'Searchs', 
                     :autorecargas => 'Autorecargar', :informes => 'Informes', 
                     
                     :graficos => 'Graphics',
                     :areas => 'Areas', :circulos => 'Circles', :barras => 'Barras', 
                     :columnas => 'Columns', :combos => 'Combos', :lineas => 'Lines',
                     :mis_graficos=> 'My Grafics', 
                     
                     :config => 'Config', :configuraciones=> 'Configurations', :usuarios => 'Users'}

  @@idiomas['it'][:ayuda_secciones] = { :empezando_h2 => 'Empezando',
                                       :conectar_BD_h4 => 'Conectar BD', :conectar_FTP_h4 => 'Conectar FTP',
                                       :config_tablas_h4 => 'Configurar Tablas', :config_cols_h4 => 'Configurar Columnas',
                                       :demos_h4 => 'Demos',
                     
                     :formularios_h2 => 'Formularios y Tablas',
                     :insercion_h4 => 'Inserción', :edicion_h4 => 'Edición', :busquedas_h4 => 'Busquedas', 
                     :autorecargas_h4 => 'Autorecargar', :informes_h4 => 'Informes', 
                     
                     :graficos_h2 => 'Gráficos',
                     :areas_h4 => 'Áreas', :circulos_h4 => 'Círculos', :barras_h4 => 'Barras', 
                     :columnas_h4 => 'Columnas', :combos_h4 => 'Combos', :lineas_h4 => 'Líneas',
                     :mis_graficos_h4 => 'Mis gráficos', 
                     
                     :config_h2 => 'Config', :configuraciones_h4 => 'Configuraciones', :usuarios_h4 => 'Usuarios'}                

  @@idiomas['it'][:ayuda_textos] = {:empezando_text => 'texto',
                                    :conectar_BD_text => 'texto BD', :conectar_FTP_text => 'texto FTP',
                                    :config_tablas_text => 'texto Tablas', :config_cols_text => 'texto Columnas',
                                    :demos_text => 'texto',
                                    
                     :formularios_text => 'Formularios y Tablas',
                     :insercion_text => 'Inserción', :edicion_text => 'Edición', :busquedas_text => 'Busquedas', 
                     :autorecargas_text => 'Autorecargar', :informes_text => 'Informes', 
                     
                     :graficos_text => 'Gráficos',
                     :areas_text => 'Áreas', :circulos_text => 'Círculos', :barras_text => 'Barras', 
                     :columnas_text => 'Columnas', :combos_text => 'Combos', :lineas_text => 'Líneas',
                     :mis_graficos_text => 'Mis gráficos', 
                     
                     :config_text => 'Config', :configuraciones_text => 'Configuraciones', :usuarios_text => 'Usuarios'} 


# => pr =PORTUGUES



  @@idiomas['pr'][:config] = { :btn_guardar => '',        :btn_cancelar => '',
                             :btn_editar => '',         :btn_conectar => ''   }

  @@idiomas['pr'][:menu] = { :crudig => 'CRUDig v0.1',
                           :mejoras=> 'Mejoras',   :config => 'Config',
                           :configuraciones => 'Configuração',
                           :nueva_config => 'Nova Configuração',
                     
                     :info => 'Info',             :ayuda => 'Ajuda',    :caract => 'Caracteristicas',
                     :versiones => 'Versões',   :demos => 'Demos',
                     
                     :graficos => 'Graficos',             :chart_area => 'Áreas',
                     :chart_circulo => 'Circulos',        :chart_barras => 'Barras',
                     :chart_columnas => 'Colunas',       :chart_combo  => 'Combos',
                     :chart_lineas => 'Linhas',           :mis_graficos => 'Meus Gráficos',
                   }
  
  @@idiomas['pr'][:mensajes] = { :config => '', :config => ''}  
  
  @@idiomas['pr'][:ayuda_menu] = { :empezando => 'Get starting',
                                   :conectar_BD => 'Conect BD', :conectar_FTP => 'Conect FTP',
                                   :config_tablas => 'Configurate Tables', :config_cols => 'Configurate Columns',
                                   :demos => 'Demos', 
                                   
                     :formularios => 'Forms and Tables',
                     :insercion => 'Inserts', :edicion => 'Editions', :busquedas => 'Searchs', 
                     :autorecargas => 'Autorecargar', :informes => 'Informes', 
                     
                     :graficos => 'Graphics',
                     :areas => 'Areas', :circulos => 'Circles', :barras => 'Barras', 
                     :columnas => 'Columns', :combos => 'Combos', :lineas => 'Lines',
                     :mis_graficos=> 'My Grafics', 
                     
                     :config => 'Config', :configuraciones=> 'Configurations', :usuarios => 'Users'}
 
  @@idiomas['pr'][:ayuda_secciones] = { :empezando_h2 => 'Empezando',
                                       :conectar_BD_h4 => 'Conectar BD', :conectar_FTP_h4 => 'Conectar FTP',
                                       :config_tablas_h4 => 'Configurar Tablas', :config_cols_h4 => 'Configurar Columnas',
                                       :demos_h4 => 'Demos',
                     
                     :formularios_h2 => 'Formularios y Tablas',
                     :insercion_h4 => 'Inserción', :edicion_h4 => 'Edición', :busquedas_h4 => 'Busquedas', 
                     :autorecargas_h4 => 'Autorecargar', :informes_h4 => 'Informes', 
                     
                     :graficos_h2 => 'Gráficos',
                     :areas_h4 => 'Áreas', :circulos_h4 => 'Círculos', :barras_h4 => 'Barras', 
                     :columnas_h4 => 'Columnas', :combos_h4 => 'Combos', :lineas_h4 => 'Líneas',
                     :mis_graficos_h4 => 'Mis gráficos', 
                     
                     :config_h2 => 'Config', :configuraciones_h4 => 'Configuraciones', :usuarios_h4 => 'Usuarios'}                

  @@idiomas['pr'][:ayuda_textos] = {:empezando_text => 'texto',
                                    :conectar_BD_text => 'texto BD', :conectar_FTP_text => 'texto FTP',
                                    :config_tablas_text => 'texto Tablas', :config_cols_text => 'texto Columnas',
                                    :demos_text => 'texto',
                                    
                     :formularios_text => 'Formularios y Tablas',
                     :insercion_text => 'Inserción', :edicion_text => 'Edición', :busquedas_text => 'Busquedas', 
                     :autorecargas_text => 'Autorecargar', :informes_text => 'Informes', 
                     
                     :graficos_text => 'Gráficos',
                     :areas_text => 'Áreas', :circulos_text => 'Círculos', :barras_text => 'Barras', 
                     :columnas_text => 'Columnas', :combos_text => 'Combos', :lineas_text => 'Líneas',
                     :mis_graficos_text => 'Mis gráficos', 
                     
                     :config_text => 'Config', :configuraciones_text => 'Configuraciones', :usuarios_text => 'Usuarios'} 

  
end
