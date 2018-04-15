#!/usr/bin/python
"""Convert equations to LaTeX"""
import base64
# import string
import json
# from subprocess import call
import os
from sys import argv

# import random
# import pyperclip
from requests import post

app_id = 'viv_mendozagenevieve_com'
# app_id = os.environ["MATHPIX_ID"]
app_key = 'd8b9378102eb2e3b533b'
# app_key = os.environ["MATHPIX_KEY"]

if not (app_id and app_key):
    print("abort: account details")
    exit()
# RAND_NAME = ''.join(random.choices(string.ascii_lowercase, k=5))
# file_path = "/tmp/" + RAND_NAME + ".png"
file_path = str(argv[1])
# if call(["gnome-screenshot", "-a", "-f", file_path]) != 0:
#     print("abort: error taking screenshot")
#     exit()
if not os.path.exists(file_path):
    print("abort: screenshot not found")
    exit()

img_uri = "data:image/jpg;base64," + base64.b64encode(
    open(file_path, "rb").read()).decode("utf-8")

req = post(
    "https://api.mathpix.com/v3/latex",
    data=json.dumps({
        'src': img_uri,
        'formats': ['latex_normal', 'latex_styled']
    }),
    headers={
        "app_id": app_id,
        "app_key": app_key,
        "Content-type": "application/json"
    })
print(json.dumps(json.loads(req.text), indent=4, sort_keys=True))

latex = json.loads(req.text).get("latex_normal", "not recognized")

print(latex)
# pyperclip.copy(LATEX)
