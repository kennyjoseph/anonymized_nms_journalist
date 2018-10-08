#!/usr/bin/env python


##============================================================================== 
# File:         newspaper.py
# Date:         Wed Apr 19 15:50:47 EDT 2017
# Author(s):    Thalita Coleman  <thalitaneu@gmail.com>
# Abstract:	Reads csv files that contains article's title and url
#		and retrieves article text from the web using goose.      
# Usage:	Takes file path, output directory, empty directory (for empty urls)
#		and scraped directory (to store scraped urls) as arguments
#		e.g.: ./newspaper.py /home/authorsConsidered_urls /homeoutDir /home/emptyDir /home/scraped
#------------------------------------------------------------------------------ 
# Requirements: Python 2.7, BeautifulSoup, Chromedriver, Selenium, Goose 
#------------------------------------------------------------------------------ 
# Notes:         
#               
#============================================================================== 

from goose import Goose
import os
import codecs
import re
import sys
import time
import shutil

reload(sys)
sys.setdefaultencoding('utf8')

sys.setrecursionlimit(10**5)

filePath = sys.argv[1] #Path to directory with csv files with author's urls
outDir = sys.argv[2] #Path to directory where txt files with articles will be stored
emptyDir = sys.argv[3] #Path to directory where empty urls are stored
scraped = sys.argv[4] #Path to directory where scraped urls are moved to

def mkdir_no_err(dir_name):
    try:
        os.mkdir(dir_name)
    except:
        pass


mkdir_no_err(outDir)
mkdir_no_err(scraped)
mkdir_no_err(emptyDir)

for files in os.walk(filePath):
	for f in files[2]:
		input_file = codecs.open(filePath + '/' + f)
		lines = input_file.readlines()
		count = 0

		for line in lines:
			# create emptyDir
			if not os.path.exists(emptyDir):
			       os.makedirs(emptyDir)
			emptyfileName = emptyDir + '/' + f
			print emptyfileName
			emptyFile = open(emptyfileName, "a")

			try:
				count = count + 1
				
				# parse url
				url = line.replace('\n', '')
				url = line.split('", ')
				url = url[-1]
				print url

				# retrieve text using goose
				g = Goose()
				raw_article = g.extract(url=url)
				title = raw_article.title
				article = raw_article.cleaned_text


				if article == '':
					print "empty url :" + str(count)
					emptyFile.write(title + ',' + url + '\n')
					emptyFile.close()
				else:
					# create outDir
					if not os.path.exists(outDir + f.replace('.csv', '')):
					       os.makedirs(outDir + f.replace('.csv', ''))
					outfileName = outDir + '/' + f.replace('.csv', '') + '_' + str(count) + '.txt'
					print outfileName
					outFile = open(outfileName, "w")
					outFile.write(title + '\n\n' + article)
					outFile.close()
			except IndexError:
				print "IndexError :" + str(count)
				emptyFile.write(title + ',' + url + '\n')
				emptyFile.close()
				continue
			except KeyboardInterrupt:
				raise
			# except:
			# 	print "Unexpected error:", sys.exc_info()[0]
			# 	emptyFile.write(title + ',' + url + '\n')
			# 	emptyFile.close()
			# 	continue

		# move original file to 'alreadyScraped' directory
		if not os.path.exists(scraped):
                        os.makedirs(scraped)
		shutil.move(filePath + '/' + f, scraped)








