class App < Sinatra::Application
  
  @@idiomas = Hash.new
  @@idiomas = {'es'=>{},  'en'=>{},  'fr'=>{},  'de'=>{},  'it'=>{},  'pr'=>{}}
  
  # => en = INGLES /  es = ESPAÑOL / fr = FRANCES / de = ALEMAN  / it =ITALIANO / pr =PORTUGUES
  
# => ESPAÑOL  
  
  @@idiomas['es'][:config] = { :btn_guardar => '',        :btn_cancelar => '',
                             :btn_editar => '',         :btn_conectar => ''   }

  @@idiomas['es'][:menu] = { :crudig => 'CRUDig v0.1',
                           :config => 'Config',
                           :configuraciones => 'Configuraciones',
                           :nueva_config => 'Nueva Configuración',
                     
                     :info => 'Info',             :ayuda => 'Ayuda',    :caracteristicas => 'Características',
                     :versiones => 'Versiones',   :demos => 'Demos',
                     
                     :graficos => 'Gráficos',             :chart_area => 'Áreas',
                     :chart_circulo => 'Circulos',        :chart_barras => 'Barras',
                     :chart_columnas => 'Columnas',       :chart_combo  => 'Combos',
                     :chart_lineas => 'Líneas',           :mis_graficos => 'Mis Gráficos',
                   }
  
  @@idiomas['es'][:mensajes] = { :config => '', :config => ''}
  
  
# => INGLES  

  @@idiomas['en'][:config] = { :btn_guardar => '',        :btn_cancelar => '',
                             :btn_editar => '',         :btn_conectar => ''   }

  @@idiomas['en'][:menu] = { :crudig => 'CRUDig v0.1',
                           :config => 'Config',
                           :configuraciones => 'Configurations',
                           :nueva_config => 'New Configuration',
                     
                     :info => 'Info',             :ayuda => 'Help',    :caracteristicas => 'Characteristics',
                     :versiones => 'Versions',   :demos => 'Demos',
                     
                     :graficos => 'Graphics',             :chart_area => 'Areas',
                     :chart_circulo => 'Circulos',        :chart_barras => 'Barras',
                     :chart_columnas => 'Columnas',       :chart_combo  => 'Combos',
                     :chart_lineas => 'Lines',           :mis_graficos => 'My Grafics',
                   }
  
  @@idiomas['en'][:mensajes] = { :config => '', :config => ''}  
  


# => fr = FRANCES 


  @@idiomas['fr'][:config] = { :btn_guardar => '',        :btn_cancelar => '',
                             :btn_editar => '',         :btn_conectar => ''   }

  @@idiomas['fr'][:menu] = { :crudig => 'CRUDig v0.1',
                           :config => 'Config',
                           :configuraciones => 'Configurations',
                           :nueva_config => 'Nouvelle Configuration',
                     
                     :info => 'Info',             :ayuda => 'Aide',    :caracteristicas => 'Caractéristiques',
                     :versiones => 'Versions',   :demos => 'Demos',
                     
                     :graficos => 'Graphics',             :chart_area => 'Zones',
                     :chart_circulo => 'Cercles',        :chart_barras => 'Barras',
                     :chart_columnas => 'Colonnes',       :chart_combo  => 'Combos',
                     :chart_lineas => 'Lignes',           :mis_graficos => 'Mes Graphques',
                   }
  
  @@idiomas['fr'][:mensajes] = { :config => '', :config => ''}  



# => de = ALEMAN  


  @@idiomas['de'][:config] = { :btn_guardar => '',        :btn_cancelar => '',
                             :btn_editar => '',         :btn_conectar => ''   }

  @@idiomas['de'][:menu] = { :crudig => 'CRUDig v0.1',
                           :config => 'Config',
                           :configuraciones => 'Konfigurationen',
                           :nueva_config => 'Neue Konfiguration',
                     
                     :info => 'Info',             :ayuda => 'Aid',    :caracteristicas => 'Features',
                     :versiones => 'Versionen',   :demos => 'Demos',
                     
                     :graficos => 'Graphics',             :chart_area => 'Bereichen',
                     :chart_circulo => 'Circles',        :chart_barras => 'Barras',
                     :chart_columnas => 'Spalten',       :chart_combo  => 'Combos',
                     :chart_lineas => 'Lines',           :mis_graficos => 'Meine Grafik',
                   }
  
  @@idiomas['de'][:mensajes] = { :config => '', :config => ''}  


# => it =ITALIANO 



  @@idiomas['it'][:config] = { :btn_guardar => '',        :btn_cancelar => '',
                             :btn_editar => '',         :btn_conectar => ''   }

  @@idiomas['it'][:menu] = { :crudig => 'CRUDig v0.1',
                           :config => 'Config',
                           :configuraciones => 'Configurazioni',
                           :nueva_config => 'Nuova Configurazione',
                     
                     :info => 'Info',             :ayuda => 'Aiuti',    :caracteristicas => 'Caratteristiche',
                     :versiones => 'Versioni',   :demos => 'Demos',
                     
                     :graficos => 'Grafica',             :chart_area => 'Aree',
                     :chart_circulo => 'Circles',        :chart_barras => 'Barras',
                     :chart_columnas => 'Colonne',       :chart_combo  => 'Combo',
                     :chart_lineas => 'Linee',           :mis_graficos => 'Miei grafica',
                   }
  
  @@idiomas['it'][:mensajes] = { :config => '', :config => ''}  



# => pr =PORTUGUES



  @@idiomas['pr'][:config] = { :btn_guardar => '',        :btn_cancelar => '',
                             :btn_editar => '',         :btn_conectar => ''   }

  @@idiomas['pr'][:menu] = { :crudig => 'CRUDig v0.1',
                           :config => 'Config',
                           :configuraciones => 'Configuração',
                           :nueva_config => 'Nova Configuração',
                     
                     :info => 'Info',             :ayuda => 'Ajuda',    :caracteristicas => 'Caracteristicas',
                     :versiones => 'Versões',   :demos => 'Demos',
                     
                     :graficos => 'Graficos',             :chart_area => 'Áreas',
                     :chart_circulo => 'Circulos',        :chart_barras => 'Barras',
                     :chart_columnas => 'Colunas',       :chart_combo  => 'Combos',
                     :chart_lineas => 'Linhas',           :mis_graficos => 'Meus Gráficos',
                   }
  
  @@idiomas['pr'][:mensajes] = { :config => '', :config => ''}  





  
  
  
end

