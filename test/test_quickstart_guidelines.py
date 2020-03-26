import re
from templates import MASTER, CLUSTER, SCHEDULER, WEBSERVER


def test_if_vpc_configuration_comes_first():
    # TODO: add workerset
    for template in [MASTER, CLUSTER, SCHEDULER, WEBSERVER]:
        interface = template["Metadata"]["AWS::CloudFormation::Interface"]
        groups = [group["Label"]["default"] for group in interface["ParameterGroups"]]
        assert "VPC" in groups[0]


def test_if_quickstart_configuration_comes_first():
    # TODO: add workerset
    for template in [MASTER, CLUSTER, SCHEDULER, WEBSERVER]:
        interface = template["Metadata"]["AWS::CloudFormation::Interface"]
        groups = [group["Label"]["default"] for group in interface["ParameterGroups"]]
        assert "Quick Start" in groups[-1]


def test_if_parameters_are_pascal_case():
    # TODO: add workerset
    for template in [MASTER, CLUSTER, SCHEDULER, WEBSERVER]:
        params = list(template["Parameters"].keys())
        for param in params:
            assert param[0] == param[0].upper()


def test_if_labels_include_punctuation():
    # TODO: add workerset
    for template in [MASTER, CLUSTER, SCHEDULER, WEBSERVER]:
        interface = template["Metadata"]["AWS::CloudFormation::Interface"]
        labels = list(interface.keys())
        for label in labels:
            assert re.match(r"[a-zA-Z0-9]", label)


# TODO: continue implementing https://aws-quickstart.github.io/naming-parms.html
