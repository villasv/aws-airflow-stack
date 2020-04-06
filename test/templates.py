from cfn_tools import load_yaml

with open("./templates/turbine-master.template") as f:
    MASTER = load_yaml(f.read())
with open("./templates/turbine-cluster.template") as f:
    CLUSTER = load_yaml(f.read())
with open("./templates/turbine-scheduler.template") as f:
    SCHEDULER = load_yaml(f.read())
with open("./templates/turbine-webserver.template") as f:
    WEBSERVER = load_yaml(f.read())
with open("./templates/turbine-workerset.template") as f:
    WORKERSET = load_yaml(f.read())

ALL = [MASTER, CLUSTER, SCHEDULER, WEBSERVER, WORKERSET]
