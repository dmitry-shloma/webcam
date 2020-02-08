TEMPLATE = lib

CONFIG -= qt
CONFIG += shared

HEADERS = \
    yuv.h \
    config.h \
    v4l2grab.h

SOURCES = \
    yuv.c \
    v4l2grab.c

LIBS += -lv4l2
