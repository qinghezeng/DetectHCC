import win32clipboard   as w
from ctypes import *
from PIL import Image
from PIL import ImageWin
from cStringIO import StringIO

w.OpenClipboard()
#w.EmptyClipboard()
formats = []
lastFormat = 0
while 1:
    nextFormat = w.EnumClipboardFormats(lastFormat)
    if 0 == nextFormat:
         # all done -- get out of the loop
         break
    else:
         formats.append(nextFormat)
         lastFormat = nextFormat
         
print formats

#w.EmptyClipboard()
buff=create_string_buffer(512*512*4)
im =  Image.frombuffer('RGB', [512,512], buff,'raw', 'RGB', 0,1)

output = StringIO()
im.convert("RGB").save(output, "BMP")
data = output.getvalue()[14:]
output.close()

w.SetClipboardData( w.CF_DIB,data )

w.CloseClipboard()


