TEMPLATE = app

QT = core gui

CONFIG -= console

HEADERS  = \
    mainwindow.h

SOURCES = \
    main.cpp \
    mainwindow.cpp

FORMS = \
    mainwindow.ui

LIBS += -L./../v4l2grab -lv4l2grab

RESOURCES += \
    videocam-318.qrc
