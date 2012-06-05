#!/usr/bin/python
# -*- coding: utf-8 -*-
 
# Copyright (c) 2012 Slawomir Lisznianski <sl@minta.com>
#
# GNU General Public Licence (GPL)
# 
# This program is free software; you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
# details.
# You should have received a copy of the GNU General Public License along with
# this program; if not, write to the Free Software Foundation, Inc., 59 Temple
# Place, Suite 330, Boston, MA  02111-1307  USA
#
import sys
from PySide.QtCore import *
from PySide.QtGui import *
from ui_main_window import MainWindow
from scanner import QrCodeScanner
from controller import AppController
 
if __name__ == '__main__':
	# create Qt application
	app = QApplication(sys.argv)
	main = MainWindow()

	proc = AppController()

	# create the scanner and connect with its signals
	scanner = QrCodeScanner("Honeywell MS-4980", vendor_id = 0x0c2e, product_id = 0x0009, end_tag = '000a0b')

	# reset controller state when user hits 'clear'
	main.btn_clear.clicked.connect(proc.reset)
	# when user accepts payment, let controller handle it
	main.btn_accept.clicked.connect(lambda: proc.submit( main.form_fields() ) )

	# handle PTA from the scanner
	proc.onDataArrived.connect(main.process_data)
	proc.onStatus.connect(main.statusbar.showMessage)
	scanner.onData.connect(proc.parse_pcos)
	scanner.onStatus.connect(main.scannerStatus.setText)

	# show main window
	main.show()

	# start the scanner
	scanner.start()
	
	# enter Qt main loop
	rc = app.exec_()

	# exit workers
	scanner.stop()
	scanner.wait()

	sys.exit(rc)
