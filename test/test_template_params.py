import re
from cfn_tools import dump_yaml
from templates import ALL, MASTER, CLUSTER, SCHEDULER, WEBSERVER, WORKERSET


def test_if_important_properties_are_specified():
    for template in ALL:
        for specs in template["Parameters"].values():
            assert "Description" in specs
            assert "Type" in specs
            if "AllowedPattern" in specs:
                assert "ConstraintDescription" in specs
            if "MinValue" in specs or "MaxValue" in specs:
                assert "ConstraintDescription" in specs


def test_if_properties_are_in_order():
    def is_ordered(left, right, array):
        left_index = array.index(left) if left in array else None
        right_index = array.index(right) if right in array else None
        if left_index is None or right_index is None:
            return True
        return left_index < right_index

    for template in ALL:
        for spec in template["Parameters"].values():
            props = list(spec.keys())

            assert is_ordered("Description", "ConstraintDescription", props)
            assert is_ordered("ConstraintDescription", "AllowedPattern", props)
            assert is_ordered("AllowedPattern", "Default", props)
            assert is_ordered("Default", "Type", props)

            assert is_ordered("Description", "AllowedValues", props)
            assert is_ordered("AllowedValues", "Default", props)

            assert is_ordered("ConstraintDescription", "MinValue", props)
            assert is_ordered("MinValue", "MaxValue", props)
            assert is_ordered("MaxValue", "Default", props)


def test_if_default_value_satisfies_pattern():
    for template in ALL:
        for specs in template["Parameters"].values():
            if "AllowedPattern" in specs and "Default" in specs:
                assert re.match(specs["AllowedPattern"], specs["Default"])


def test_if_description_ends_in_dot():
    for template in ALL:
        for specs in template["Parameters"].values():
            assert specs["Description"].endswith(".")


def test_if_constraint_description_ends_in_dot():
    for template in ALL:
        for specs in template["Parameters"].values():
            if "ConstraintDescription" in specs:
                assert specs["ConstraintDescription"].endswith(".")


def test_consistency():
    pairs = [
        (MASTER, CLUSTER),
        (CLUSTER, SCHEDULER),
        (CLUSTER, WEBSERVER),
        (CLUSTER, WORKERSET),
    ]
    for (t_outer, t_inner) in pairs:
        for param1, specs1 in t_outer["Parameters"].items():
            for param2, specs2 in t_inner["Parameters"].items():
                if param1 == param2:
                    assert (param1, dump_yaml(specs1)) == (param2, dump_yaml(specs2))
