class App < Sinatra::Application
  
  idiomas = Hash.new
  
  # => en = INGLES /  es = ESPAÑOL / fr = FRANCES / de = ALEMAN  
  idiomas[:config] = {:en=>'',:es=>'',:fr=>'',:de=>''}
  
  idiomas[:btn_guardar] = {:en=>'',:es=>'',:fr=>'',:de=>''}
  idiomas[:btn_cancelar] = {:en=>'',:es=>'',:fr=>'',:de=>''}
  idiomas[:btn_editar] = {:en=>'',:es=>'',:fr=>'',:de=>''}
  idiomas[:btn_conectar] = {:en=>'',:es=>'',:fr=>'',:de=>''}

  
end