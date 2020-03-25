from templates import MASTER, CLUSTER


def test_if_all_parameters_are_grouped():
    # TODO: add scheduler, webserver, workerset
    for template in [MASTER, CLUSTER]:
        interface = template["Metadata"]["AWS::CloudFormation::Interface"]
        grouped = [
            param
            for group in interface["ParameterGroups"]
            for param in group["Parameters"]
        ]
        for param in template["Parameters"]:
            assert param in grouped


def test_if_all_parameters_are_labeled():
    # TODO: add scheduler, webserver, workerset
    for template in [MASTER, CLUSTER]:
        interface = template["Metadata"]["AWS::CloudFormation::Interface"]
        labeled = list(interface["ParameterLabels"].keys())
        for param in template["Parameters"]:
            assert param in labeled
