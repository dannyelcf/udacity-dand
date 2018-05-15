#!/usr/bin/env python
#coding: utf-8

from collections import OrderedDict
from difflib import SequenceMatcher
from xml.sax.saxutils import escape
import os
import json
import codecs
import xml.etree.cElementTree as ET
import matplotlib.pyplot as plt


"""
Class for accumulating strings before writing to a file (IO). 
Thus, the number of IOs is reduced. 
"""
class _ChunkWritter(object):
    def __init__(self, file):
        self.file = file
        self.chunk = ""
        self.count = 0

    def write(self, line):
        if (self.count != 0) and (self.count % 1000 == 0):
            self.flush()
        self.count += 1
        self.chunk += line

    def flush(self):
        self.file.write(self.chunk)
        self.chunk = ""
        self.count = 0


"""
Private function that perform cleaning 'element.clear()' of memory
after XML element processing. This evict memory leak for huge XML files.abs
"""
def __wrap_function(function):
    def wrapped_function(accumulator, next_value):
        event, element = next_value
        if event == "start":
            accumulator = function(accumulator, element, event)
        elif event == "end":
            accumulator = function(accumulator, element, event)
            element.clear()
        return accumulator
    return wrapped_function


"""
Function to perform functional XML processing. 
It abstracts the handling of the XML file. The programmer just
"""
def proccess_xml(xml_file_path, function, accumulator=None):
    with open(xml_file_path, "rb") as xml_file:
        xml_iterable = ET.iterparse(xml_file, events=("start", "end"))
        wrapped_function = __wrap_function(function)
        result = reduce(wrapped_function, xml_iterable, accumulator)
    return result

"""
Function to perform functional XML processing. 
It abstracts the way XML is processed and persisted in the file system.
"""
def modify_xml(in_xml_file_path, function, out_xml_file_path):
    with codecs.open(out_xml_file_path, "wb", encoding="utf-8") as xml_output:
        xml_writter = _ChunkWritter(xml_output)
        xml_writter.write('<?xml version="1.0" encoding="UTF-8"?>\n')
        # Invokes 'function' function for every element in XML.
        xml_writter = proccess_xml(in_xml_file_path, function, accumulator=xml_writter)
        xml_writter.flush()

"""
Function to perform functional export XML to Json.
It abstracts the way XML is processed and the Json is persisted in the file system.
"""
def xml_to_json(in_xml_file_path, function, out_json_file_path):
    with codecs.open(out_json_file_path, "wb", encoding="utf-8") as json_output:
        for event, element in ET.iterparse(in_xml_file_path, events=("start", "end")):
            if event == "start":
                obj = function(element)
                if obj:
                    json_output.write(json.dumps(obj) + "\n")
            else:
                element.clear()

"""
Private function that perform escape of XML especial characters (&, <, >, ', ")
"""
def __escape(value):
    return escape(u'{}'.format(value), {"'": "&apos;", '"': "&quot;"})

"""
Function that returns a string representation of start XML tag.
"""
def start_element_to_string(element):
    attributes = [u'{}="{}"'.format(k, __escape(v)) for (k, v) in element.attrib.items()]
    return u'<{} {}>\n'.format(element.tag, ' '.join(attributes))

"""
Function that returns a string representation of end XML tag.
"""
def end_element_to_string(element):
    return u'</{}>\n'.format(element.tag)


"""
Based on https://stackoverflow.com/a/39988702/8645131
Private function that convert a number in file size representation.
"""
def __convert_bytes(num):
    """
    this function will convert bytes to MB.... GB... etc
    """
    for x in ['bytes', 'KB', 'MB', 'GB', 'TB']:
        if num < 1000.0:
            return "%3.2f %s" % (num, x)
        num /= 1000.0


"""
Based on https://stackoverflow.com/a/39988702/8645131
Function that convert a number in file size representation.
"""
def file_size(file_path):
    """
    this function will return the file size
    """
    if os.path.isfile(file_path):
        file_info = os.stat(file_path)
        return __convert_bytes(file_info.st_size)


"""
Private function that return a sorted copy of a dict.
"""
def __sort_dict(dict_, sort_function, reverse):
    dict_copy = dict_.copy()
    return OrderedDict(sorted(dict_copy.iteritems(), 
                       key=sort_function, 
                       reverse=reverse))


"""
Private function that return a deep, sorted copy of a dict. 
That is, it sorts nested dicts.
"""
def __deep_sort_dict(dict_, sort_function, reverse):
    if isinstance(dict_, dict):
        dict_copy = dict()
        for key in dict_.keys():
            dict_copy[key] = __deep_sort_dict(dict_[key], 
                                              sort_function=sort_function, 
                                              reverse=reverse)
        
        return OrderedDict(sorted(dict_copy.iteritems(), 
                           key=sort_function, 
                           reverse=reverse))
    else:
        return dict_


"""
Function that dispatches the invocation of sort_dict to flat sort or deep sort.
"""
def sort_dict(dict_, sort_function=(lambda (k, v): k), reverse=False, deep=False):
    if deep:
        return __deep_sort_dict(dict_, sort_function=sort_function, reverse=reverse)
    else:
        return __sort_dict(dict_, sort_function=sort_function, reverse=reverse)


"""
Function that filter a dict by keys and/or values.
"""
def filter_dict(dict_, filter_function):
    return {k:v for k,v in dict_.iteritems() if filter_function((k,v))}


"""
Private util function that converts set() type to list() type.
The reason for this is that the json.dump function does not accept the set() type.
"""
def __set_default(obj):
    if isinstance(obj, set):
        return list(obj)
    raise TypeError


"""
Function that converts a dict to Json.
"""
def print_dict(dict_, indent=4):
    print(json.dumps(dict_, indent=indent, default=__set_default))


"""
Function that calculates the similarity between two strings.
"""
def similarity(text_1, text_2):
    return SequenceMatcher(None, text_1, text_2).ratio()        


"""
Private function that render labels on top of bars in bar chart.
"""
def __bar_autolabel(rects, ax):
    """
    Attach a text label above each bar displaying its height
    """
    for rect in rects:
        height = rect.get_height()
        ax.text(rect.get_x() + rect.get_width()/2., 1.05*height,
                '%d' % int(height),
                ha='center', va='bottom')

"""
Function that render a bar chart of top 5 contributing users.
"""
def plot_top5(list_top5):
    x = []
    y = []
    for elem in list_top5:
        x.append(elem['_id'])
        y.append(elem['count'])
    
    x_pos = [0, 1, 2, 3, 4]
    fig, ax = plt.subplots(figsize=(12, 6))
    rect = ax.bar(x_pos , y, align='center', alpha=0.5)
    ax.set_xticks(x_pos)
    ax.set_xticklabels(x, rotation=45)
    ax.set_xlabel('Users')
    ax.set_ylabel('Number of occurrences')
    ax.set_ylim([0,5000000])
    ax.set_title('Top 5 contributing users')
    ax.grid(True)
    __bar_autolabel(rect, ax)
    plt.show()

"""
Based on https://matplotlib.org/examples/pylab_examples/subplots_demo.html
Function that render a scatter chart of top 5 contributing users but showing
the locations (latitude and longitude) of data created by them.
"""
def plot_dist_top5(loc_contrib_by_user):
    dict_ = {}
    for elem in loc_contrib_by_user:
        user = dict_.get(elem['user'], {'lat': [], 'lon': []})
        lat = user['lat']
        lat.append(elem['lat'])
        lon = user['lon']
        lon.append(elem['lon'])
        dict_[elem['user']] = user
    
    f, (ax1, ax2, ax3, ax4, ax5) = plt.subplots(5, sharex=True, sharey=True, figsize=(12, 10))
    
    user = u'Marcos Medeiros'
    ax1.scatter(dict_[user]['lon'] , dict_[user]['lat'], label=user, alpha=0.3)
    ax1.scatter([-49.2532691], [-16.6808820], label=u"Goiânia", marker=(5, 1), s=80)
    ax1.scatter([-47.8823172], [-15.7934036], label=u"Brasília", marker=(5, 1), s=80)
    ax1.scatter([-48.2767837], [-18.9188041], label=u"Uberlândia", marker=(5, 1), s=80)
    ax1.legend(loc='upper right')
    
    user = u'street0501'
    ax2.scatter(dict_[user]['lon'] , dict_[user]['lat'], label=user, alpha=0.3)
    ax2.scatter([-49.2532691], [-16.6808820], label=u"Goiânia", marker=(5, 1), s=80)
    ax2.scatter([-47.8823172], [-15.7934036], label=u"Brasília", marker=(5, 1), s=80)
    ax2.scatter([-48.2767837], [-18.9188041], label=u"Uberlândia", marker=(5, 1), s=80)
    ax2.legend(loc='upper right')
    
    user = u'Linhares'
    ax3.scatter(dict_[user]['lon'] , dict_[user]['lat'], label=user, alpha=0.3)
    ax3.scatter([-49.2532691], [-16.6808820], label=u"Goiânia", marker=(5, 1), s=80)
    ax3.scatter([-47.8823172], [-15.7934036], label=u"Brasília", marker=(5, 1), s=80)
    ax3.scatter([-48.2767837], [-18.9188041], label=u"Uberlândia", marker=(5, 1), s=80)
    ax3.legend(loc='upper right')
    
    user = u'erickdeoliveiraleal'
    ax4.scatter(dict_[user]['lon'] , dict_[user]['lat'], label=user, alpha=0.3)
    ax4.scatter([-49.2532691], [-16.6808820], label=u"Goiânia", marker=(5, 1), s=80)
    ax4.scatter([-47.8823172], [-15.7934036], label=u"Brasília", marker=(5, 1), s=80)
    ax4.scatter([-48.2767837], [-18.9188041], label=u"Uberlândia", marker=(5, 1), s=80)
    ax4.legend(loc='upper right')
    
    user = u'patodiez'
    ax5.scatter(dict_[user]['lon'] , dict_[user]['lat'], label=user, alpha=0.3)
    ax5.scatter([-49.2532691], [-16.6808820], label=u"Goiânia", marker=(5, 1), s=80)
    ax5.scatter([-47.8823172], [-15.7934036], label=u"Brasília", marker=(5, 1), s=80)
    ax5.scatter([-48.2767837], [-18.9188041], label=u"Uberlândia", marker=(5, 1), s=80)
    ax5.legend(loc='upper right')
    
    ax5.set_xlabel('Longitude')
    ax3.set_ylabel('Latitude')
    ax1.set_title('Distribution of top 5 contributing users')
    
    # Fine-tune figure; make subplots close to each other and hide x ticks for
    # all but bottom plot.
    f.subplots_adjust(hspace=0)
    plt.setp([a.get_xticklabels() for a in f.axes[:-1]], visible=False)
    plt.show()