import re
from templates import MASTER, CLUSTER


def strip_warning(description):
    return re.sub(r"\*\*WARNING\*\*.*QS\(0027\)", "", description)


def test_nesting_consistency():
    master_desc = strip_warning(MASTER["Description"])
    cluster_desc = strip_warning(CLUSTER["Description"]).replace(
        "This template", "The Turbine-Airflow cluster stack"
    )
    assert cluster_desc in master_desc
