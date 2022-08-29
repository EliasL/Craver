import urllib.request
import json
import functools
import time
import os

class Prometheus:
    def __init__(self) -> None:
        if 'PROMETHEUS_SOURCE' in os.environ:
            self.prometheus_source = os.environ['PROMETHEUS_SOURCE']
        else:
            self.prometheus_source = 'http://prometheus02.lbdaq.cern.ch:9090'
  
    @functools.lru_cache(maxsize = None)
    def get(self, command, time=None):
        '''
        time is given in seconds

        Example 
        get('up')
        get('up', {'instance':'aseb03.lbdaq.cern.ch'}, 5)
        '''

        allowed_commands = ['up', 'up!=1', 'up==1']
        if command not in allowed_commands:
            return {}
        # Additional args is a dict. Cache doesn't like dicts because they are not
        # hashable, so the simplest solution is to not have additional args
        #additional_args = self._format_additional_args(additional_args)
        url = f"{self.prometheus_source}/api/v1/query?query={command}"
        # time isn't used, so it is commented out
        #if time:
        #    url += f"[{time}s]"
        contents = urllib.request.urlopen(url)
        contents = json.load(contents)
        return contents

    def _format_additional_args(self, args):
        if not args:
            return ''
        # Changes 'a' : 'b'
        # to       a = 'b'
        formated_args = '{'
        for (key, value) in args.items():
            formated_args += f"{key}='{value}', "
        formated_args = formated_args[:-1]+'}' # Remove last ,
        return formated_args

if __name__ == '__main__':
    p = Prometheus()
    j=p.get('up')

    for d in j['data']['result']:
        print(d)