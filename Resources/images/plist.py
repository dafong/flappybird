# coding=utf-8
# rszip.py
# @author yin.li
# @date 2013-05-14
# @update henry.sha 2013-05-14

# -*- coding:utf-8 -*-




import os, json, zipfile, datetime, shutil, hashlib, ConfigParser,codecs,sys,re


if __name__ == '__main__':
    basedir = os.path.split(os.path.realpath(__file__))[0]
    f = codecs.open(os.path.join(basedir,"atlas.plist"), 'w', 'utf-8')
    f.write('''<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
    <dict>
        <key>frames</key>
        <dict>
    ''')
    txt = codecs.open(os.path.join(basedir,"atlas.txt"))
    while 1:
        line = txt.readline()
        if not line:
            break
        p = line.split(" ")
        f.write("<key>"+p[0]+"</key>")
        f.write("<dict>")
        f.write("<key>frame</key>")
        f.write("<string>{{"+str(int(float(p[3])*1024))+","+str(int(float(p[4])*1024))+"},{"+p[1]+","+p[2]+"}}</string>")
        f.write("<key>offset</key>")
        f.write("<string>{0,0}</string>")
        f.write("<key>rotated</key>")
        f.write("<false/>")
        f.write("<key>sourceColorRect</key>")
        f.write("<string>{{0,0},{"+p[1]+","+p[2]+"}}</string>")
        f.write("<key>sourceSize</key>")
        f.write("<string>{"+p[1]+","+p[2]+"}</string>")
        f.write("</dict>")
    
    
    
    f.write('''
                </dict>
                <key>metadata</key>
                <dict>
                    <key>format</key>
                    <integer>2</integer>
                    <key>realTextureFileName</key>
                    <string>atlas.png</string>
                    <key>size</key>
                    <string>{1024,1024}</string>
                    <key>smartupdate</key>
                    <string>$TexturePacker:SmartUpdate:e56ec5b51d77aa8dc4c5dcb4e2c3295f:1/1$</string>
                    <key>textureFileName</key>
                    <string>atlas.png</string>
                </dict>
            </dict>
        </plist>
        
        ''')