import urllib.request
import json

class Prometheus:
    def __init__(self) -> None:
        pass

    def get(self, command, additional_args=None, time=None):
        '''
        time is given in seconds

        Example 
        get('up')
        get('up', {'instance':'aseb03.lbdaq.cern.ch'}, 5)
        '''
        additional_args = self._format_additional_args(additional_args)
        url = f"http://prometheus02.lbdaq.cern.ch:9090/api/v1/query?query={command}{additional_args}"
        if time:
            url += f"[{time}s]"
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