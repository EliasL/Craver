class Table:
    def __init__(self, name, columns={}) -> None:
        self.name = name
        self.columns = columns

        
class Tables:
    instance_snapshots = Table('instance_snapshots', {
        'id'            : 'int PRIMARY KEY AUTO_INCREMENT',
        'name'          : 'varchar(255)',
        'date_recorded' : 'timestamp'
    })

    datum = Table('datum', {
        'id'                    : 'int PRIMARY KEY AUTO_INCREMENT',
        'instance_snapshot_id'  : 'int',
        'command'               : 'varchar(255)',
        'result_value'          : 'BIGINT',
        'raw_json'              : 'TEXT',
        'date_recorded' : 'timestamp'
    })