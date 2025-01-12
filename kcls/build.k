import .wf_publish
import infra.kcls.common.workflow

import yaml

_workflows = [
    wf_publish._workflow
]

_run = [yaml.dump_to_file(a, ".github/workflows/${a._filename}", ignore_private=True, ignore_none=True) for a in _workflows]
