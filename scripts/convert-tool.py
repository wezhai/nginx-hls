#!/usr/bin/python
# -*- coding: utf-8 -*-
import os
import commands
import datetime

media_root_path = "/opt/media"
hls_root_path = "/opt/hls"

# Get Current Time
def current_time():
  nowTime=datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')
  return nowTime

# Get files
def getfiles(file_dir, file_type):  
  file_list = []  
  for root, dirs, files in os.walk(file_dir): 
    for file_name in files: 
      if os.path.splitext(file_name)[1] == file_type: 
        file_list.append(os.path.join(root, file_name)) 
  return file_list

# Get Existed
def getdirs(dir_path):
  for root, dirs, files in os.walk(dir_path): 
    if root == dir_path:
      dir_list = []
      for directory in dirs:
        hls_path = root + "/" + directory
        for r, d, f in os.walk(hls_path):
          if directory + ".m3u8" in f:
            dir_list.append(directory)
      return dir_list

# Create dir
def create_dir(path):
  isExists = os.path.exists(path)
  if not isExists:
    os.makedirs(path)
  else:
    cmd = "rm -rf " + path
    os.system(cmd)
    os.makedirs(path)

# Check Type
def check_type(file_path):
  command = "file " + file_path
  __, result = commands.getstatusoutput(command)
  if "ISO Media" not in result:
    time = current_time()
    print "[" + time + "] " + "Ignored inconformity file '" + file_path + "'" 
    return False
  else:
    return True

# Convert
def convert(input_file, basename):
  directory = hls_root_path + "/" + basename
  create_dir(directory)
  output_file = directory + "/" + basename + ".m3u8"
  if check_type(input_file):
    time = current_time()
    print "[" + time + "] " + "Execute convert: '" + input_file + "'"
    command = "ffmpeg -i " + input_file + " -codec: copy -level 3.0 -start_number 0 -hls_time 1 -hls_list_size 0 -f hls " + output_file
    status, result = commands.getstatusoutput(command)
    if status == 0:
      print "[" + time + "] " + "Execute result: Successful..."
      return True
  else:
    os.rmdir(directory)
    return False

videos = getfiles(media_root_path, file_type=".mp4")
existed = getdirs(hls_root_path)

for filename in videos:
  time = current_time()
  fullname = os.path.basename(filename)
  basename = os.path.splitext(fullname)[0]
  if basename in existed:
    #print "[" + time + "] " + "Ignored existed file '" + filename + "'" 
    pass
  else:
    status = convert(filename, basename)
