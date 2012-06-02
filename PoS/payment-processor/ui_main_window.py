# -*- coding: utf-8 -*-

import sys
from PySide.QtGui import *
from gen_ui_main import Ui_MainWindow

class MainWindow(QMainWindow, Ui_MainWindow):
	def __init__(self, parent=None):
		'''Mandatory initialisation of a class.'''
		super(MainWindow, self).__init__(parent)
		self.setupUi(self)
		self.view_display.setReadOnly(True)

		self.scannerStatus = QLabel()
		self.statusbar.addPermanentWidget(self.scannerStatus)
