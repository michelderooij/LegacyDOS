@echo off
cl /c /AL /FPa /Ot /Gs optimize.c
clipper m
blinker fi m,optimize lib llibce stack 8192
