from cmath import inf
from traceback import print_last
import mysql.connector
from tables import Table, Tables
from tabulate import tabulate
import sys
import textwrap
import ast

class Database:

    # Gives a warning if user attempts to delete more
    # than this number of rows
    warning_limit = 100000

    # Sets a limit to how many rows are printed
    max_rows = 10000

    # Cuts of strings when printing table if they are long
    max_char_length = 80

    def __init__(self, user) -> None:
        self.user = user
        self.database_name = user['database']
        self.db = mysql.connector.connect(**user)
        self.cursor = self.db.cursor()
        self.enable_manual_commit = False

        # This storage accumulates data of the same type
        self.data_insertion_storage = {}
        # This keeps track of autoincrementing ids
        self.auto_increment_tracker = {}
        self._init_auto_increment_counters()


    #<-- EXPORT FUNCTIONS -->

    def get_data_by_instance(self):
        pass

    def get_latest_data_by_command(self, command):

        self.cursor.execute(f"SELECT result_value, json FROM {Tables.datum.name} WHERE key = {command} ORDER BY date_recorded DESC LIMIT 1")
        rv = self.cursor.fetchall() #TODO NOT WORKING POSSIBLY NO LONGER RELEVANT
        #json_data=[]
        #for result in rv:
        #        json_data.append(dict(zip(row_headers,result)))
        #return json.dumps(json_data, default=str)

    def view_tables(self):
        print(f'\nShowing tables from {self.database_name}:')
        
        tables = [['Table name', 'Rows']]
        for table_name in self._get_tables():
            tables.append([table_name, self._count_rows_in(Table(table_name))])
        print(tabulate(tables, headers='firstrow', tablefmt='fancy_grid'))
    
    def view_table(self, table, rows=inf):
        table = table.name
        
        print(f'\nShowing {table}:')

        self._execute(f'SELECT * FROM {table} LIMIT {min(rows,Database.max_rows)}')
        result = self.cursor.fetchall()
        # Shortens long strings
        result = [map(lambda s:textwrap.shorten(str(s), width=Database.max_char_length, placeholder=" ..."), r) for r in result]
        # We want the headers to be on the first row
        field_names = [i[0] for i in self.cursor.description]
        result.insert(0,field_names)
        print(tabulate(result, headers='firstrow', tablefmt='fancy_grid'))
        if len(result)-1 == min(rows,Database.max_rows):
            print('\t.\n\t.\n\t.')
    
    def get_current_auto_increment_value(self, table, increase=True):
        """
        WARNING: This function increments the auto increment value by defult. In
        order to only view the value, set increase to False
        TODO auto_increment functionality has not been tested with tables without autoincrementation yet
        """
        if increase:
            self.auto_increment_tracker[table.name] += 1
            return self.auto_increment_tracker[table.name] -1
        else: 
            return self.auto_increment_tracker[table.name]



    #<-- DELETE/CREATION FUNCTIONS -->

    def delete_data(self, table):
        '''
        Deletes all rows in a table.
        (Without droping the table itself)
        '''
            
        # Check if the user wants to delete the table
        nr_of_rows = self._count_rows_in(table)
        if self._confirm_action(table, f"Are you sure you want to remove"+\
                            f" {nr_of_rows} rows from '{table.name}'? (y/n): "):
            # Actually delete the data
            self._execute(f'DELETE FROM {table.name}')
            print(f"All rows in {table.name} were deleted!")

    def insert_data(self, data, table):
        '''
        Data should be a single row. Data is automatically
        collected and uploaded in bulk

        NB: data must be in the same order as columns!
        '''
        # Move data from table into columns
        for key, value in list(table.columns.items()):
            if 'AUTO_INCREMENT' in value:
                del table.columns[key]
                
        columns = table.columns.keys()

        
        if self.enable_manual_commit:
            self._store_data(data, table, columns)
        else:
            self._insert_data(data, table, columns)

    
    def create_table(self, table):
        assert isinstance(table, Table), f'Argument is not of type Table but of type:{type(table)}.'
        assert len(table.columns) > 0, 'The table must be given at least one column.' 
        assert '|' not in table.name, "Don't use '|' in the table name." # See func _store_data and manual_commit

        # Construct the command string
        command = f"CREATE TABLE `{table.name}` ("
        # Add columns
        for key, value in table.columns.items():
            command += f"`{key}` {value},"
        # Remove last comma and add the end
        command = command[:-1] + ")"
        print(f"Creating Table '{table.name}'")
        self._execute(command)
        if not self.enable_manual_commit: self._commit()
    
    def delete_table(self, table):
        nr_of_rows = self._count_rows_in(table)
        if self._confirm_action(table, f"Are you sure you want to remove"+\
                            f" '{table.name}' with {nr_of_rows} rows? (y/n): "):

            # Actually delete the table
            self._execute(f'DROP TABLE {table.name};')
            if not self.enable_manual_commit: self._commit()
            print(f"'{table.name}' was deleted!")

    def add_forign_fields(self, tableA, keyA, tableB, keyB):
        '''
        A > B
        Many A to few B
        ''' 
        tableA = tableA.name
        tableB = tableB.name

        command = f"ALTER TABLE `{tableA}` ADD FOREIGN KEY (`{keyA}`) REFERENCES `{tableB}` (`{keyB}`)"
        self._execute(command)
        # TODO Or maybe it is the other way around??? D: 
        print(f"Assigned '{keyA}' from '{tableA}' as a foreign key to '{keyB}' in '{tableB}'")
    
    def add_unique(self, table, *keys, column_name='unique_index'):
        command = f"ALTER TABLE `{table.name}` ADD UNIQUE `{column_name}`("
        for key in keys:
            command += f"`{key}`,"
        # Remove last comma and add the end
        command = command[:-1] + ")"
        self._execute(command)
        if not self.enable_manual_commit: self._commit()
        print(f"Added unique column in '{table.name}' constraining " + ', '.join(keys[:-1]) + f' and {keys[-1]}')

    def manual_commit(self):
        assert self.enable_manual_commit == True, 'You have not enabled manual committing'

        # Dump insert_data_storage
        print('Starting upload...')
        for datatype, data in self.data_insertion_storage.items():
            table_name, str_columns = datatype.split(' | ', 1)
            columns = ast.literal_eval(str_columns)
            self._insert_data(data, Table(table_name), columns)
        
        self.data_insertion_storage={} # Delete storage

        self._commit()

    #<-- PRIVATE FUNCTIONS -->

    
    def _store_data(self, data, table, columns):
        data_type = table.name + ' | ' + str(list(columns))
        if data_type not in self.data_insertion_storage:
            self.data_insertion_storage[data_type] = []
        self.data_insertion_storage[data_type].append(data)

    def _insert_data(self, data, table, columns):
        # Prepare insert command
        command = f"INSERT INTO `{table.name}` ("
        command2 = ""
        for column_name in columns:
            command += f"{column_name}, "
            command2 += "%s, "
        command = command[:-2] + ") VALUES (" + command2[:-2] + ")"
        
        # Execute command
        #print(data[:10])
        #self._commit()
        #self.view_table(Tables.instance_snapshots)
        
        if hasattr(data[0], '__iter__') and not isinstance(data[0], str): #Check if it is a nested list (Could be list list, or list tuple)
            self._execute_many(command, data)
            print(f'{len(data)} rows of data was added to {table.name} in {self.database_name}.')
        else:
            self._execute(command, data)
        if not self.enable_manual_commit: self._commit()
    
    def _init_auto_increment_counters(self):
        # TODO For many tables, this should be optimized to remove loop
        self.auto_increment_tracker = {}
        for table_name in self._get_tables():
            self.auto_increment_tracker[table_name] = self._get_auto_increment_value(table_name)

    def _get_auto_increment_value(self, table_name):
        command = "SELECT `AUTO_INCREMENT` FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA"+\
            f"= '{self.database_name}' AND TABLE_NAME = '{table_name}'"
        self._execute(command)
        result = self.cursor.fetchall()
        return result[0][0]

    def _confirm_action(self, table, promt):
        nr_of_rows = self._count_rows_in(table)
        if nr_of_rows > Database.warning_limit:
            confirmation = input(promt)
            if confirmation.lower() != 'y':
                print('Action aborted!')
                return False
        return True
    
    def _execute(self, command, values=None):
        self.cursor.execute(command, params=values)
    
    def _execute_many(self, command, values):
        self.cursor.executemany(command, values)
    
    def _commit(self):
        self.db.commit()
        self._init_auto_increment_counters()
    
    def _get_tables(self):
        self._execute('SHOW TABLES')
        result = self.cursor.fetchall()
        return map(lambda a:a[0], result) # removes an unnecessary list layer
    
    def _count_rows_in(self, table):
        self._execute(f'SELECT COUNT(*) FROM {table.name}')
        return self.cursor.fetchall()[0][0]