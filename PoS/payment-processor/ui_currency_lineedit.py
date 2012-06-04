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
from PySide.QtGui import QLineEdit, QValidator
from PySide.QtCore import Qt
from decimal import Decimal

class CurrencyValidator(QValidator):
	'''Takes integer input and returns currency formatted as N.NN'''

	def __init(self):
		QValidator.__init__(self)

	def validate(self, val, pos):
		# remove all non-digit characters
		digits = filter(lambda x: x.isdigit(), val)
		
		if not digits:
			return QValidator.Acceptable,digits,0
		else:
			# format as "N.FF"
			val = str(Decimal(digits).scaleb(-2).quantize(Decimal("0.01")))
			valsz = len(val)
			if pos == valsz-1:
				pos = valsz
			return QValidator.Acceptable,val,pos

	def fixup(self, val):
		if not val:
			val = "0.00"	


class PcCurrencyLineEdit(QLineEdit):

	def keyPressEvent(self, event):
		if event.key() == Qt.Key_Delete:
			self.setText("0.00")
		else:
			QLineEdit.keyPressEvent(self, event)

	def __init__(self, parent=None):
		QLineEdit.__init__(self, parent)

		# currency validator
		self.setValidator(CurrencyValidator())

