TEMPLATE = app

CONFIG += console
CONFIG -= qt

HEADERS =

SOURCES = \
    main.cpp

#QMAKE_CFLAGS += -std=c99

SDK_PATH = "C:/Program Files/Microsoft SDKs/Windows/v7.1"

INCLUDEPATH += $${SDK_PATH}/Include
LIBS += -L$${SDK_PATH}/Lib -lole32 -lstrmiids -loleaut32

#QMAKE_CFLAGS += -DUNICODE
