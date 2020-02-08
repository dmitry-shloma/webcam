/***************************************************************************
 *   v4l2grab Version 0.3                                                  *
 *   Copyright (C) 2012 by Tobias Müller                                   *
 *   Tobias_Mueller@twam.info                                              *
 *                                                                         *
 *   based on V4L2 Specification, Appendix B: Video Capture Example        *
 *   (http://v4l2spec.bytesex.org/spec/capture-example.html)               *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.             *
 ***************************************************************************/
 
 /**************************************************************************
 *   Modification History                                                  *
 *                                                                         *
 *   Matthew Witherwax      21AUG2013                                      *
 *      Added ability to change frame interval (ie. frame rate/fps)        *
 * Martin Savc              7JUL2015
 *      Added support for continuous capture using SIGINT to stop.
 ***************************************************************************/
#ifndef V4L2GRAB_H
#define V4L2GRAB_H

void deviceOpen(const char *deviceName);
void deviceInit(const char *deviceName);

void captureStart();
void mainLoop(const char *jpegFilename);
void	captureStop();
 void deviceUninit();
 void	deviceClose();

#endif // V4L2GRAB_H
