ActiveRecord::Base.establish_connection(
  :adapter => 'sqlite3',
  :database => 'entornos_xls.sqlite3.db'
)

class CreateEntornos < ActiveRecord::Migration
  def up
    create_table :entorno do |t|
      t.compania = params[:compania]
      t.bd = params[:bd]
      t.svn = params[:svn]
      t.url = params[:url]
      t.nombre = params[:nombre]
    end
  end
end