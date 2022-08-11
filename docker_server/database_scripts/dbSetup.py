from multiprocessing.sharedctypes import Value
from dbInterface import Database
from tables import Tables as T
from config import admin_user, client_user
from datetime import datetime
now = datetime.now


db = Database(admin_user)


db.view_tables()
'''
db.delete_table(T.datum)
db.delete_table(T.instance_snapshots)
db.create_table(T.instance_snapshots)
db.create_table(T.datum)
db.add_forign_fields(T.datum, 'instance_snapshot_id', T.instance_snapshots, 'id')
db.add_unique(T.instance_snapshots, 'name', 'date_recorded')
'''
#db.view_table(T.instance_snapshots, rows=100)
#db.view_table(T.datum, rows=100)