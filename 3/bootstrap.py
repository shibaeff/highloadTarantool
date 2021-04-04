import json
from subprocess import Popen, PIPE

kwargs = {}
kwargs.update(start_new_session=True)

with  open("ini_config.json") as config:
    config_data = json.load(config)
    for key, item in config_data.items():
        uuid, port = key, item
        Popen(["nohup", "tarantool", "server.lua", str(port), str(uuid), "&"])
        # p = Popen(["tarantool", "server.lua", str(port), str(uuid)], stdin=PIPE,
        #       stdout=PIPE, stderr=PIPE, **kwargs)
        # assert not p.poll()
