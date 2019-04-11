/*create database "CB" */
/*create database "ICAT"*/
/*create database "FED"*/

/*create role cb_usr login superuser inherit createdb createrole noreplication;*/
alter role cb_usr login superuser inherit createdb createrole noreplication;
grant all on database "CB" to cb_usr;
grant all on database "CB" to irods;
grant all on database "ICAT" to irods;
grant connect, temporary on database "CB" to public;
alter role cb_usr password 'vb9gpJq/TjrkFcJ0jaJu+w==';

