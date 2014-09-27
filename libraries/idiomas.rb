class App < Sinatra::Application
  
  @@idiomas = Hash.new
  @@idiomas = {:ES=>{},  :EN=>{},  :FR=>{},  :DE=>{},  :IT=>{},  :PR=>{}}
  
  # => en = INGLES /  es = ESPAÑOL / fr = FRANCES / de = ALEMAN  / it =ITALIANO / pr =PORTUGUES
  
  @@idiomas[:ES][:config] = { :btn_guardar => '',        :btn_cancelar => '',
                             :btn_editar => '',         :btn_conectar => ''   }

  @@idiomas[:ES][:menu] = { :crudig => 'CRUDig v0.1',
                           :config => 'Config',
                           :configuraciones => 'Configuraciones',
                           :nueva_config => 'Nueva Configuración',
                     
                     :info => 'Info',             :ayudua => 'Ayuda',    :caracteristicas => 'Características',
                     :versiones => 'Versiones',   :demos => 'Demos',
                     
                     :graficos => 'Gráficos',             :chart_area => 'Áreas',
                     :chart_circulo => 'Circulos',        :chart_barras => 'Barras',
                     :chart_columnas => 'Columnas',       :chart_combo  => 'Combos',
                     :chart_lineas => 'Líneas',           :mis_graficos => 'Mis Gráficos',
                   }
  
  @@idiomas[:ES][:mensajes] = { :config => '', :config => ''}
  
  

  @@idiomas[:EN][:config] = { :btn_guardar => '',        :btn_cancelar => '',
                             :btn_editar => '',         :btn_conectar => ''   }

  @@idiomas[:EN][:menu] = { :crudig => 'CRUDig v0.1',
                           :config => 'Config',
                           :configuraciones => 'Configurations',
                           :nueva_config => 'New Configuration',
                     
                     :info => 'Info',             :ayudua => 'Help',    :caracteristicas => 'Características',
                     :versiones => 'Versions',   :demos => 'Demos',
                     
                     :graficos => 'Grafics',             :chart_area => 'Áreas',
                     :chart_circulo => 'Circulos',        :chart_barras => 'Barras',
                     :chart_columnas => 'Columnas',       :chart_combo  => 'Combos',
                     :chart_lineas => 'Línes',           :mis_graficos => 'My Grafics',
                   }
  
  @@idiomas[:EN][:mensajes] = { :config => '', :config => ''}  
end

