from pathlib import Path
from cfn_tools import load_yaml, dump_yaml

TEMPLATES = {}
for template in Path("./templates").iterdir():
    with template.open() as f:
        TEMPLATES[str(template)] = load_yaml(f.read())


def test_attributes():
    for f, yaml in TEMPLATES.items():
        for param, specs in yaml['Parameters'].items():
            keys = list(specs.keys())
            assert ((param, keys[0]) == (param, 'Description'))
            assert ((param, keys[1]) == (param, 'Type'))


def test_consistency():
    for f1, yaml1 in TEMPLATES.items():
        for param1, specs1 in yaml1['Parameters'].items():
            for f2, yaml2 in TEMPLATES.items():
                if (f1 == f2):
                    continue
                for param2, specs2 in yaml2['Parameters'].items():
                    if param1 == param2:
                        assert (
                            (param1, dump_yaml(specs1))
                            ==
                            (param2, dump_yaml(specs2))
                        )
