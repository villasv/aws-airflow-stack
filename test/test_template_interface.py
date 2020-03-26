from templates import ALL


def test_if_all_parameters_are_grouped():
    for template in ALL:
        interface = template["Metadata"]["AWS::CloudFormation::Interface"]
        grouped = [
            param
            for group in interface["ParameterGroups"]
            for param in group["Parameters"]
        ]
        for param in template["Parameters"]:
            assert param in grouped


def test_if_parameters_in_groups_are_ordered():
    for template in ALL:
        interface = template["Metadata"]["AWS::CloudFormation::Interface"]
        grouped = [
            param
            for group in interface["ParameterGroups"]
            for param in group["Parameters"]
        ]
        params = list(template["Parameters"].keys())
        assert grouped == params


def test_if_all_parameters_are_labeled():
    for template in ALL:
        interface = template["Metadata"]["AWS::CloudFormation::Interface"]
        labeled = list(interface["ParameterLabels"].keys())
        for param in template["Parameters"]:
            assert param in labeled


def test_if_parameters_labels_are_ordered():
    for template in ALL:
        interface = template["Metadata"]["AWS::CloudFormation::Interface"]
        labeled = list(interface["ParameterLabels"].keys())
        params = list(template["Parameters"].keys())
        assert labeled == params
