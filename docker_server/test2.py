from dimbrowser import DimBrowser
import pydim
import time
import sys
from threading import Thread


#Class that defines a DIM Server
class Server(Thread):
    def __init__(self):
        Thread.__init__(self)
        self.stopped = False
        self.create_time_service()
        self.startServer()

    #callback executed when dis_update_service is called
    def server_service_time_callback(self,tag):
        now = time.strftime("%X")

        # Remember, the callback function must return a tuple
        return ("Hello! The time is %s" % now,)

    #Create a service that gives the time
    def create_time_service(self):
        self.time_svc = pydim.dis_add_service("time-service","C",self.server_service_time_callback,0)
        if not self.time_svc:
            sys.exit(1)
        pydim.dis_update_service(self.time_svc)

    #Start the DIM Server
    def startServer(self):
        pydim.dis_start_serving("TimeService-server")

    #Stop the DIM Server
    def stop(self):
        self.stopped = True
        self.join()

    # Method that runs when server.start() is called
    def run(self):
        while not self.stopped:
            time.sleep(5)
            pydim.dis_update_service(self.time_svc)

# define a simple client
class Client():
    #callback executed when the time service returns a value
    def time_service_callback(self,value):
        print(value)

    # subscribe to the time-service
    def subscribe_to_time_service_once(self):
            pydim.dic_info_service("time-service",self.time_service_callback,pydim.ONCE_ONLY)

def create_server():
    return Server()


def stop_server(server):
    print("Server is stopping...")
    server.stop()
    print("Server stopped")


def menu():
    print("------ DIMBROWSER Example ------")
    print("1. Print all services known by the DNS")
    print("2. Print all servers known by the DNS")
    print("3. Print all services provided by the TimeService-server")
    print("4. Get time from time-service service")
    print("5. Print all clients connected to the TimeService-server")
    print("6. Exit")
    print("--------------------------------")

def print_all_services_known_by_dns(dbr):
    '''
    dbr.getServices(wildcard) returns the number of services known by the DNS
    dbr.getNextService() can be called after this call
    '''
    nb_services_known_by_DNS = dbr.getServices("*")
    print(("There are {0} services known by the DNS".format(nb_services_known_by_DNS)))
    for i in range(nb_services_known_by_DNS):
        #getNextService().next() returns a tuple
        service_tuple = next(dbr.getNextService())
        print(("Service {0} : Type of service = {1} name = {2}, format = {3}".format(i+1,service_tuple[0],service_tuple[1],service_tuple[2])))
    print("")

def print_all_servers_known_by_dns(dbr):
    '''
    dbr.getServers() returns the number of servers known by the DNS
    dbr.getNextServer() can be called after this call
    '''
    nb_servers_known_by_DNS = dbr.getServers()
    print(("There are {0} servers known by the DNS".format(nb_servers_known_by_DNS)))
    for i in range(nb_servers_known_by_DNS):
        #getNextServer().next() returns a tuple
        server_tuple = next(dbr.getNextServer())
        print(("Server {0}, name = {1}, Node name = {2}".format(i+1,server_tuple[0],server_tuple[1])))
    print("")

def print_all_services_provided_by_server(dbr):
    '''
    dbr.getServerServices("TimeService-server") returns the number of services
    provided by the TimeService-server.
    dbr.getNextServerService() can be called after this call
    '''
    nb_services_on_server = dbr.getServerServices("TimeService-server")
    for i in range(nb_services_on_server):
        #getNextServerServices().next() returns a tuple
        service_server_tuple = next(dbr.getNextServerService())
        print(("Service {0} Type of service {1}, service name = {2}, format = {3}".format(i+1,service_server_tuple[0],service_server_tuple[1], service_server_tuple[2])))
    print("")

def print_all_clients_connected_to_server(dbr):
    '''
    dbr.getServerClients("TimeService-server") returns the number of clients
    connected to the server
    dbr.getNextServerClient() can be called after this call
    '''
    nb_clients_on_server = dbr.getServerClients("TimeService-server")
    #getNextServerClient() is a generator that generates a tuple or None if no Clients are found
    #this is another way to use the getNext*** functions
    for client_tuple in dbr.getNextServerClient():
        if client_tuple is not None:
            print(("Client name = {0}, node name = {1}".format(client_tuple[0],client_tuple[1])))
    print("")


def main():
    #Check if DIM_DNS_NODE variable has been set
    if not pydim.dis_get_dns_node():
        print("No Dim DNS node found. Please set the environment variable DIM_DNS_NODE")
        sys.exit(1)

    exited = False

    print("Instanciating dimbrowser...")
    #dimbrowser has to be instanciated
    dbr = DimBrowser()

    print("Creating server...")
    server = create_server()

    print("Starting server...")
    server.start()
    print("Server started")

    client = Client()

    while not exited:
        menu()
        choice = input("Choice : ")
        if choice == "1":
            print_all_services_known_by_dns(dbr)
        elif choice == "2":
            print_all_servers_known_by_dns(dbr)
        elif choice == "3":
            print_all_services_provided_by_server(dbr)
        elif choice == "4":
            client.subscribe_to_time_service_once()
            time.sleep(1)
        elif choice == "5":
            print_all_clients_connected_to_server(dbr)
        elif choice == "6":
            stop_server(server)
            exited = True
        else:
            print("Wrong input !")

    del dbr
    print("Goodbye")

if __name__=="__main__":
    main()
