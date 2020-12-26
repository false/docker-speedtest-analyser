#!/usr/bin/python

# Script originally provided by AlekseyP
# https://www.reddit.com/r/technology/comments/43fi39/i_set_up_my_raspberry_pi_to_automatically_tweet/
# modifications by roest - https://github.com/roest01

# updated by false to support ookla native cli

import os
import csv
import datetime
import time
import subprocess
import json

#static values
CSV_FIELDNAMES=["timestamp", "ping", "download", "upload"]
FILEPATH = os.path.dirname(os.path.abspath(__file__)) + '/../data/result.csv'

def runSpeedtest():
	# execute speedtest
	proc = subprocess.Popen(["/usr/local/bin/speedtest" , "-f", "json", "--accept-license", "--accept-gdpr"], stdout=subprocess.PIPE)
	output = proc.stdout.read()

	result = json.loads(output)

	ping = round(result['ping']['latency'], 2)
	byteToMbit = 0.000008
	download = round(result['download']['bandwidth'] * byteToMbit, 2)
	upload = round(result['upload']['bandwidth'] * byteToMbit, 2)
	timestamp = round(time.time() * 1000, 3)

	csv_data_dict = {
			CSV_FIELDNAMES[0]: timestamp,
			CSV_FIELDNAMES[1]: ping,
			CSV_FIELDNAMES[2]: download,
			CSV_FIELDNAMES[3]: upload}

	#write testdata to file
	isFileEmpty = not os.path.isfile(FILEPATH) or os.stat(FILEPATH).st_size == 0

	with open(FILEPATH, "a") as f:
			csv_writer = csv.DictWriter(f, delimiter=',', lineterminator='\n', fieldnames=CSV_FIELDNAMES)
			if isFileEmpty:
					csv_writer.writeheader()

			csv_writer.writerow(csv_data_dict)

	#print testdata
	print('--- Result ---')
	print("Timestamp: %s" %(timestamp))
	print("Ping: %f [ms]" %(ping))
	print("Download: %f [Mbit/s]" %(download))
	print("Upload: %f [Mbit/s]" %(upload))
	
if __name__ == '__main__':
	runSpeedtest()
	print('speedtest complete')
