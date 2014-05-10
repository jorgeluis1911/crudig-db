#class Entorno < ActiveRecord::Base
class Entorno < Object
  attr_accessor :id, :compania, :bd, :svn, :url, :nombre
  
  def initialize(params)
    $id_entorno += 1
    @id = $id_entorno
    @compania = params[:compania]
    @bd = params[:bd]
    @svn = params[:svn]
    @url = params[:url]
    @nombre = params[:nombre]
  end
  
  def update(params)
    @compania = params[:compania]
    @bd = params[:bd]
    @svn = params[:svn]
    @url = params[:url]
    @nombre = params[:nombre]
  end
  
end