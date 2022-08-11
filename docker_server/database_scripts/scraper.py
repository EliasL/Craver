from time import time
from traceback import print_last
from lblogbookInterface import Prometheus
from dbInterface import Database
from config import admin_user
from datetime import datetime, timezone
from tables import Tables as T
import sched, time

seconds_between_pull = 30
priority = 1

commands_to_pull = ['up', 'cpu_usage_system', 'mem_free', 'diskio_reads']

p = Prometheus()
db = Database(admin_user)
db.enable_manual_commit = True

def pull():
    # By using list(), we see how much time it takes to pull
    return list(map(p.get, commands_to_pull)) 

def push(all_data):
    '''
    Pushes data into database.

    BUT ALSO! runs checks for uniqueness over instance names.
    This much faster to do here, but it is a bit annoying that
    this is so specific for this table setup. I suppose one could make
    a more general system that would check for what kind of
    restrictions are set on the database, but for this case,
    it will be hardcoded.

    Also note that this implementation assumes that instances on the 
    database have a different date. If they don't, this code will
    CRASH when the database complains about uniqueness. 
    (It seems as though even with a 3 second update time, the timestamps
    are )
    '''

    instance_ids = {}

    for command_data in all_data:
        result = command_data['data']['result']
        for data in result:
            #print(data)
            timestamp, value = data['value']

            json_data = data['metric']
            key = json_data['__name__']
            del json_data['__name__']
            instance = json_data['instance']

            # Check uniqueness

            if instance not in instance_ids:
                # Create a new instance
                db.insert_data([instance, datetime.fromtimestamp(timestamp)], T.instance_snapshots)
                # Find instance ID
                instance_id = db.get_current_auto_increment_value(T.instance_snapshots)
                # Store instance ID for later
                instance_ids[instance] = instance_id
                # Add datum associated with instance
                db.insert_data([instance_id, key, value, str(json_data), datetime.fromtimestamp(timestamp)], T.datum)
            else:
                # Add datum associated with instance
                db.insert_data([instance_ids[instance], key, value, str(json_data), datetime.fromtimestamp(timestamp)], T.datum)
    db.manual_commit()


def scrape():
    start = datetime.now(timezone.utc)
    print(f'Started pull at {start}')

    data = pull()

    end_pull = datetime.now(timezone.utc)
    print(f'Completed pull in {(end_pull-start).total_seconds()} seconds.')

    push(data)
    
    end_push= datetime.now(timezone.utc)
    print(f'Completed push in {(end_push-end_pull).total_seconds()} seconds.')
    print(f'Total duration: {(end_push-start).total_seconds()} seconds.')
    print()


s = sched.scheduler(time.time, time.sleep)
def do_something(sc):
    scrape()

    sc.enter(seconds_between_pull, priority, do_something, (sc,))




scrape() # It first waits, and then runs, so I just run it first and then start the loop 
s.enter(seconds_between_pull, priority, do_something, (s,))
s.run()