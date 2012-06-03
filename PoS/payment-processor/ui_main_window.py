# -*- coding: utf-8 -*-

import sys, time, datetime
from decimal import Decimal
from PySide.QtGui import *
from PySide.QtCore import *
from gen_ui_main import Ui_MainWindow

# Templates for rendering PTAs
PTA_WITH_TIP_TMPL = '''<center><h2><hr />Payment Authorization<hr /></h2></center>
<table align="right">
<tr><td align="right">Limit: </td><td align="right"><font size="12" color="white"><strong>{limit}</strong></font></td></tr>
<tr><td align="right">Tip: </td><td align="right"><font size="12" color="#9090ff"><strong>{tip}</strong></font></td></tr>
<tr><td align="right" colspan="2"><br />{expiry}</td></tr>
</table>
'''

PTA_NO_TIP_TMPL = '''<center><h2><hr />Payment Authorization<hr /></h2></center>
<table align="right">
<tr><td align="right">Limit: </td><td align="right"><font size="12" color="white"><strong>{limit}</strong></font></td></tr>
<tr><td align="right" colspan="2"><br />{expiry}</td></tr>
</table>
'''

def format_tip(tip_val, tip_type):
	if tip_type == 'A':
		return '$' + str(tip_val.quantize(Decimal("0.01")))
	else:
		tip_scaled = tip_val.shift(2)
		return str(tip_scaled.quantize(Decimal("1"))) + '%'
	
class MainWindow(QMainWindow, Ui_MainWindow):

	def __init__(self, parent=None):
		'''Mandatory initialisation of a class.'''
		super(MainWindow, self).__init__(parent)
		self.setupUi(self)
		self.view_display.setReadOnly(True)

		# status bar
		self.scannerStatus = QLabel()
		self.statusbar.addPermanentWidget(self.scannerStatus)
		self.pta = None

		# currency validator
		currency_regex = QRegExp("\\d+\.\\d{2}")
		currency_validator = QRegExpValidator(currency_regex, self)
		self.input_cost.setValidator(currency_validator)

		# when tip checkbox changes state, recalc
		self.chbox_tip.stateChanged.connect(self.__recalculate)

		# reset all UI states
		self.__reset();

	def __recalculate(self):
		'''Takes Cost and Tip and computes the Total'''
		if self.pta:
			# take charge, extract numbers only
			if self.input_cost.hasAcceptableInput():
				cost = Decimal(self.input_cost.text())
				total = cost
				if self.pta.has_tip:
					self.chbox_tip.setDisabled(False)
					if self.chbox_tip.isChecked():
						if self.pta.tip_type == 'A':
							total += self.pta.tip 
						else:
							total *= 1 + self.pta.tip
				else:
					self.chbox_tip.setDisabled(True)
				self.view_total.setText( str(total) )
			else: # unaccaptable input
				self.view_total.setText( "N/A" )

			if self.pta.has_tip:
				self.view_tip.setText(format_tip(self.pta.tip, self.pta.tip_type))
			else:
				self.view_tip.setText('N/A')
				self.chbox_tip.setChecked(False)


	def __reset(self):
		self.input_cost.clear()
		self.view_display.setText( 'Waiting...' )
		self.view_total.setText( "N/A" )
		self.view_tip.setText('N/A')
		

	def process_data(self, data):
		'''Displays data arriving from the controller -- today, only PTA can end up here'''

		if not data:
			self.__reset()
			return

		# store as PTA
		self.pta = data

		# make PTA data pretty
		ctime_prt = time.strftime("%x %X", time.localtime(data.ctime))
		now = long( time.time() + 0.5 )
		seconds = data.expiry - now
		if seconds < 0:
			expiry_prt = '<font color="red"><strong>PAYMENT EXPIRED</strong></font>'
		else:
			expiry_prt = '<i>Expires in %s</i>' % str(datetime.timedelta(seconds=seconds))
		payment_limit_prt = '$' + str(data.payment_limit.quantize(Decimal('0.01')))

		tip_prt = ''
		if data.has_tip:
			tip_prt = format_tip(data.tip, data.tip_type)
			html = PTA_WITH_TIP_TMPL.format(
				ctime = ctime_prt, 
				expiry = expiry_prt, 
				limit = payment_limit_prt, 
				tip = tip_prt)
		else:
			html = PTA_NO_TIP_TMPL.format(
				ctime = ctime_prt, 
				expiry = expiry_prt, 
				limit = payment_limit_prt)

		self.view_display.setHtml( html )
		
		# set tip to ON by default on each scan
		self.chbox_tip.setChecked(True)

		# recalculate total
		self.__recalculate()
		
