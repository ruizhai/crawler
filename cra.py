# -*- coding: UTF-8 -*-

from selenium import webdriver
import time
import sys
reload(sys)
sys.setdefaultencoding('utf-8')

driver = webdriver.Firefox()
city_code = {}
ch = open('./city_code.txt')
for line in ch.readlines():
    line = line.strip() 
    l = line.split('\t', 1 )
    city_code[l[0]] = l[1]
ch.close()


url = 'http://hotel.qunar.com/city/{c}/q-{q}#fromDate=2017-04-14&from=qunarHotel&toDate=2017-04-15'
fh = open('./hotel.txt')
for line in fh.readlines():
    line = line.strip() 
    l = line.split('\t')
    if not city_code.has_key(l[0]):
        print(l[0] + "无城市信息")
        continue
    c = city_code[l[0]]
    f = l[1]
    q = l[2]
    u = url.format(c=c, q=q)
    print(u)
    driver.get(u)
    html = driver.page_source
    print('write')
    wf = open('./html/' + f + '.html', 'w')
    wf.write(html)
    wf.close()
