
select * from sys.objects

select * from sys.tables
select * from sys.columns

select * from sys.foreign_key_columns
select * from sys.foreign_keys

select * from sys.

select t.name, c.*, t2.name, c2.name
from sys.tables as t 
	inner join sys.columns as c on t.object_id=c.object_id
	inner join sys.foreign_key_columns as fkc 
		on fkc.parent_object_id=c.object_id and fkc.parent_column_id=c.column_id
	left join sys.tables as t2 on fkc.referenced_object_id=t2.object_id
	left join sys.columns as c2 
			on fkc.referenced_object_id=c2.object_id and fkc.parent_column_id=c2.column_id
order by t.name, c.column_id
