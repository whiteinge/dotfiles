#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""Fetch the weather RSS from Yahoo! for display in Conky."""

import urllib
import string
from xml.etree import cElementTree as ET

# TODO: take input params from the shell
RSS_URL = "http://weather.yahooapis.com/forecastrss?p=84401&u=c"

MAIN_NS = "http://xml.weather.yahoo.com/ns/rss/1.0"

# ConkyWeather.ttf based output
conditions_weather_font = {
    "0": "1", #Tornado
    "1": "2", #Tropical Storm
    "2": "3", #Hurricane
    "3": "n", #Severe Thunderstorms
    "4": "m", #Thunderstorms
    "5": "x", #Mixed Rain and Snow
    "6": "x", #Mixed Rain and Sleet
    "7": "y", #Mixed Precipitation
    "8": "s", #Freezing Drizzle
    "9": "h", #Drizzle
    "10": "t", #Freezing Rain
    "11": "h", #Light Rain
    "12": "i", #Rain
    "13": "p", #Snow Flurries
    "14": "p", #Light Snow Showers
    "15": "8", #Drifting Snow
    "16": "q", #Snow
    "17": "", #Hail
    "18": "w", #Sleet
    "19": "7", #Dust
    "20": "0", #Fog
    "21": "9", #Haze
    "22": "4", #Smoke
    "23": "6", #Blustery 
    "24": "6", #Windy
    "25": "-", #Cold
    "26": "f", #Cloudy
    "27": "D", #Mostly Cloudy - night
    "28": "d", #Mostly Cloudy - day
    "29": "C", #Partly Cloudy - night
    "30": "c", #Partly Cloudy - day
    "31": "A", #Clear - night
    "32": "a", #Clear - day
    "33": "B", #Fair - night
    "34": "b", #Fair - day
    "35": "v", #Mixed Rain and Hail
    "36": "5", #Hot
    "37": "k", #Isolated Thunderstorms - day
    "38": "k", #Scattered Thunderstorms - day
    "39": "g", #Scattered Showers - day
    "40": "j", #Heavy Rain
    "41": "o", #Scattered Snow Showers - day
    "42": "r", #Heavy Snow
    "43": "r", #Heavy Snow
    "44": "-", #N/A
    "45": "G", #Scattered Showers - night
    "46": "O", #Scattered Snow Showers - night
    "47": "K", #Isolated Thunderstorms - night
    "3200": "-", #N/A
    "na": "-", #N/A
    "-": "-" #N/A
}

# ConkyWindN based output
bearing_arrow_font = {
    "S": 0x31,
    "SSW": 0x32,
    "SW": 0x33,
    "WSW": 0x34,
    "W": 0x35,
    "WNW": 0x36,
    "NW": 0x37,
    "NNW": 0x38,
    "N": 0x39,
    "NNE": 0x3a,
    "NE": 0x3b,
    "ENE": 0x3c,
    "E": 0x3d,
    "ESE": 0x3e,
    "SE": 0x3f,
    "SSE": 0x40,
}


def main():
    # TODO: add local caching and etag conditional fetching
    data = urllib.urlopen(RSS_URL)
    tree = ET.parse(data).getroot()

    # temperature, distance, speed
    units = tree.find("channel/{%s}units" % MAIN_NS)

    # city, region
    location = tree.find("channel/{%s}location" % MAIN_NS)

    # chill, direction, speed
    wind = tree.find("channel/{%s}wind" % MAIN_NS)

    # sunrise, sunset
    astronomy = tree.find("channel/{%s}astronomy" % MAIN_NS)

    # temp, text, code
    condition = tree.find("channel/item/{%s}condition" % MAIN_NS)

    # day, low, high, text, code
    forecast = tree.findall("channel/item/{%s}forecast" % MAIN_NS)

    data_dict = {}
    data_dict.update(dict(units.items()))
    data_dict.update(dict(location.items()))
    data_dict.update(dict(wind.items()))
    data_dict.update(dict(astronomy.items()))
    data_dict.update(dict(condition.items()))

    output = """%(city)s, %(region)s
%(temp)s° %(text)s
""" % data_dict

    for i in forecast:
        output += """%(day)s: %(text)s\n""" % dict(i.items())

    return output

if __name__ == '__main__':
    print main()
