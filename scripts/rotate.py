from PIL import image
import os
for filename in os.listdir(os.getcwd()):
    img = image.open(filename)
    img2 = img.rotate(-90)
    img2.save("rot_" + filename)
