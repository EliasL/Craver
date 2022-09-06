from encodings import utf_8
import urllib.request
import xml.etree.ElementTree as ET
import re
import functools
import os


class LbLogbook:
    def __init__(self) -> None:
        if 'LBLOGBOOK_SOURCE' in os.environ:
            self.lblogbook_source = os.environ['LBLOGBOOK_SOURCE']
        else:
            self.lblogbook_source = 'http://10.128.97.87:8080'

    @functools.lru_cache(maxsize = None)
    def get(self, page):
        # Checks that all characters in page are numbers
        if(sum([char in '0123456789' for char in page]) != len(page)):
            return 'Not a number!'
        elif len(page)>3:
            return 'Number must be smaller than 1000!'
        url = f'{self.lblogbook_source}/Shift/page{page}/elog.rdf'
        # Perhaps this is silly, but I just prefer utf-8
        # There is some performance to be gained here, but I just want everyting
        # to be utf. TODO?
        xml = urllib.request.urlopen(url).read().decode('ISO-8859-1').encode('utf-8')
        return xml


if __name__ == '__main__':
    L = LbLogbook()
    s = L.get().decode('utf-8')
    #soup = BeautifulSoup('<div>a&nbsp;b</div>')
    #soup.prettify(formatter=lambda s: s.replace(u'\xa0', ' '))
    #u'<html>\n <body>\n  <div>\n   a b\n  </div>\n </body>\n</html>'
    l = re.split('<td class="list1"|<td class="list2"', s)
    result = re.search('<td class="summary">(.*)</td>', s)
    
    print(s)

