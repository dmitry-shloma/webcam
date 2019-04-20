TEMPLATE = app

CONFIG += console
CONFIG -= qt

SOURCES = \
    main.c

QMAKE_CFLAGS += -std=c99

LIBS += -lvfw32
