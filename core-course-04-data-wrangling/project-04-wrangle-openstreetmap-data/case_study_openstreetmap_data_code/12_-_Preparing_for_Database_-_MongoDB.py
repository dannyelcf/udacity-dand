#!/usr/bin/env python
# -*- coding: utf-8 -*-
import xml.etree.cElementTree as ET
import pprint
import re
import codecs
import json
"""
Your task is to wrangle the data and transform the shape of the data
into the model we mentioned earlier. The output should be a list of dictionaries
that look like this:

{
"id": "2406124091",
"type: "node",
"visible":"true",
"created": {
          "version":"2",
          "changeset":"17206049",
          "timestamp":"2013-08-03T16:43:42Z",
          "user":"linuxUser16",
          "uid":"1219059"
        },
"pos": [41.9757030, -87.6921867],
"address": {
          "housenumber": "5157",
          "postcode": "60625",
          "street": "North Lincoln Ave"
        },
"amenity": "restaurant",
"cuisine": "mexican",
"name": "La Cabana De Don Luis",
"phone": "1 (773)-271-5176"
}

You have to complete the function 'shape_element'.
We have provided a function that will parse the map file, and call the function with the element
as an argument. You should return a dictionary, containing the shaped data for that element.
We have also provided a way to save the data in a file, so that you could use
mongoimport later on to import the shaped data into MongoDB. 

Note that in this exercise we do not use the 'update street name' procedures
you worked on in the previous exercise. If you are using this code in your final
project, you are strongly encouraged to use the code from previous exercise to 
update the street names before you save them to JSON. 

In particular the following things should be done:
- you should process only 2 types of top level tags: "node" and "way"
- all attributes of "node" and "way" should be turned into regular key/value pairs, except:
    - attributes in the CREATED array should be added under a key "created"
    - attributes for latitude and longitude should be added to a "pos" array,
      for use in geospacial indexing. Make sure the values inside "pos" array are floats
      and not strings. 
- if the second level tag "k" value contains problematic characters, it should be ignored
- if the second level tag "k" value starts with "addr:", it should be added to a dictionary "address"
- if the second level tag "k" value does not start with "addr:", but contains ":", you can
  process it in a way that you feel is best. For example, you might split it into a two-level
  dictionary like with "addr:", or otherwise convert the ":" to create a valid key.
- if there is a second ":" that separates the type/direction of a street,
  the tag should be ignored, for example:

<tag k="addr:housenumber" v="5158"/>
<tag k="addr:street" v="North Lincoln Avenue"/>
<tag k="addr:street:name" v="Lincoln"/>
<tag k="addr:street:prefix" v="North"/>
<tag k="addr:street:type" v="Avenue"/>
<tag k="amenity" v="pharmacy"/>

  should be turned into:

{...
"address": {
    "housenumber": 5158,
    "street": "North Lincoln Avenue"
}
"amenity": "pharmacy",
...
}

- for "way" specifically:

  <nd ref="305896090"/>
  <nd ref="1719825889"/>

should be turned into
"node_refs": ["305896090", "1719825889"]
"""


lower = re.compile(r'^([a-z]|_)*$')
lower_colon = re.compile(r'^([a-z]|_)*:([a-z]|_)*$')
problemchars = re.compile(r'[=\+/&<>;\'"\?%#$@\,\. \t\r\n]')

CREATED = [ "version", "changeset", "timestamp", "user", "uid"]
POS = ["lat", "lon"]


def shape_element(element):
    node = {}
    
    # you should process only 2 types of top level tags: "node" and "way"
    if element.tag == "node" or element.tag == "way" :
        node['type'] = element.tag
        
        # all attributes of "node" and "way" should be turned into regular key/value pairs
        for attr_key, attr_value in element.attrib.iteritems():
            
            # except: attributes in the CREATED array should be added under a key "created"
            if attr_key in CREATED:
                if 'created' not in node:
                    node['created'] = {}
                node['created'][attr_key] = attr_value
                    
            # attributes for latitude and longitude should be added to a "pos" array,
            elif attr_key in POS:
                if 'pos' not in node:
                    node['pos'] = [None, None]
                if attr_key == "lat":
                    node['pos'][0] = float(attr_value)
                elif attr_key == "lon":
                    node['pos'][1] = float(attr_value)
            else:
                # all attributes of "node" and "way" should be turned into regular key/value pairs
                node[attr_key] = attr_value
            
            for second_level_tag in element.iter("tag"):    
            
                # if the second level tag "k" value contains problematic characters, it should be ignored
                m = problemchars.search(second_level_tag.attrib['k'])
                if m:
                    continue

                # if there is a second ":" that separates the type/direction of a street,
                # the tag should be ignored
                key_levels = second_level_tag.attrib['k'].split(":")
                if len(key_levels) > 2:
                    continue

                if len(key_levels) == 1:
                    node[key_levels[0]] = second_level_tag.attrib['v']
                elif len(key_levels) == 2:
                    # if the second level tag "k" value starts with "addr:", it should be added to a dictionary "address"
                    if key_levels[0] == "addr":
                        if 'address' not in node:
                            node['address'] = {}
                        node['address'][key_levels[1]] = second_level_tag.attrib['v']
                            
                    # if the second level tag "k" value does not start with "addr:", but contains ":", you can
                    # process it in a way that you feel is best
                    else:
                        normalized_key = key_levels[0] + "_" + key_levels[1]
                        if normalized_key not in node:
                            node[normalized_key] = {}
                        node[normalized_key] = second_level_tag.attrib['v']
             
            # for "way" specifically:
            nd_list = [nd.attrib['ref'] for nd in element.iter("nd")]
            if nd_list:
                node['node_refs'] = nd_list
                
        return node
    else:
        return None


def process_map(file_in, pretty = False):
    # You do not need to change this file
    file_out = "{0}.json".format(file_in)
    data = []
    with codecs.open(file_out, "w") as fo:
        for _, element in ET.iterparse(file_in):
            el = shape_element(element)
            if el:
                data.append(el)
                if pretty:
                    fo.write(json.dumps(el, indent=2)+"\n")
                else:
                    fo.write(json.dumps(el) + "\n")
    return data

def test():
    # NOTE: if you are running this code on your computer, with a larger dataset, 
    # call the process_map procedure with pretty=False. The pretty=True option adds 
    # additional spaces to the output, making it significantly larger.
    data = process_map('example.osm', True)
    pprint.pprint(data)
    
    correct_first_elem = {
        "id": "261114295", 
        "visible": "true", 
        "type": "node", 
        "pos": [41.9730791, -87.6866303], 
        "created": {
            "changeset": "11129782", 
            "user": "bbmiller", 
            "version": "7", 
            "uid": "451048", 
            "timestamp": "2012-03-28T18:31:23Z"
        }
    }
    assert data[0] == correct_first_elem
    assert data[-1]["address"] == {
                                    "street": "West Lexington St.", 
                                    "housenumber": "1412"
                                      }
    assert data[-1]["node_refs"] == [ "2199822281", "2199822390",  "2199822392", "2199822369", 
                                    "2199822370", "2199822284", "2199822281"]

if __name__ == "__main__":
    test()
