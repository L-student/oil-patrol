
import requests
import os

from datetime import datetime, timedelta

def get_currents(start_time, end_time, filename):
    # http://ncss.hycom.org/thredds/ncss/GLBy0.08/latest?var=water_u&var=water_v&north=-8.5&west=-36.5&east=-34&south=-9.5&disableProjSubset=on&horizStride=1&time_start=2021-03-17T12%3A00%3A00Z&time_end=2021-03-20T00%3A00%3A00Z&timeStride=1&vertCoord=0.0&accept=netcdf4
    # Building url string
    url = 'http://ncss.hycom.org/thredds/ncss/GLBy0.08/latest?var=water_u&var=water_v&'
    url += 'north=' + str(-8.5) + '&'
    url += 'west=' + str(-36.5) + '&'
    url += 'east=' + str(-34) + '&'
    url += 'south=' + str(-11) + '&'
    url += 'disableProjSubset=on&horizStride=1&'
    url += 'time_start=' + str(start_time.year) + '-' + str(start_time.month) + '-' + str(start_time.day)
    url += 'T' + str(start_time.hour) + '%3A' + str(start_time.minute) + '%3A' + str(start_time.second) + 'Z&'
    url += 'time_end=' + str(end_time.year) + '-' + str(end_time.month) + '-' + str(end_time.day)
    url += 'T' + str(end_time.hour) + '%3A' + str(end_time.minute) + '%3A' + str(end_time.second) + 'Z&'
    url += 'timeStride=1&vertCoord=0.0&accept=netcdf'

    print(url)

    # making request
    r = requests.get(url, allow_redirects=True)

    # Save file
    if os.path.exists(filename):
        os.remove(filename)

    with open(filename, 'wb') as currentsFile:
        currentsFile.write(r.content)
        currentsFile.close()

def get_wind( start_time, end_time, filename):
    url = 'https://thredds.ucar.edu/thredds/ncss/grib/NCEP/GFS/Global_0p25deg/Best?var=u-component_of_wind_height_above_ground&var=v-component_of_wind_height_above_ground&'
    url += 'north=' + str(-8.5) + '&'
    url += 'west=' + str(-36.5) + '&'
    url += 'east=' + str(-34) + '&'
    url += 'south=' + str(-11) + '&'
    url += 'disableProjSubset=on&horizStride=1&'
    url += 'time_start=' + str(start_time.year) + '-' + str(start_time.month) + '-' + str(start_time.day)
    url += 'T' + str(start_time.hour) + '%3A' + str(start_time.minute) + '%3A' + str(start_time.second) + 'Z&'
    url += 'time_end=' + str(end_time.year) + '-' + str(end_time.month) + '-' + str(end_time.day)
    url += 'T' + str(end_time.hour) + '%3A' + str(end_time.minute) + '%3A' + str(end_time.second) + 'Z&'
    url += 'timeStride=1&vertCoord=10.0&accept=netcdf'

    print(url)

    # making request
    r = requests.get(url, allow_redirects=True)

    # Save file
    if os.path.exists(filename):
        os.remove(filename)

    with open(filename, 'wb') as windFile:
        windFile.write(r.content)
        windFile.close()



# considering run step interval and 2 more days
time_step =  timedelta(days = 7) 

# First run
current_time = datetime.now().replace(hour=12, minute=0, second=0, microsecond=0) - timedelta(days = 7)
end_time = current_time + time_step

get_currents(current_time,end_time, 'current18_10_2024.nc' )

get_wind(current_time,end_time, 'wind18_10_2024.nc')