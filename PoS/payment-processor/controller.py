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
import sys, pcos, datetime, time
from decimal import Decimal
from PySide.QtCore import *
import settings as const

class AppController(QObject):
	'''Handles data events, communicates with the PushCoin backend'''

	onRenderData = Signal(object)
	onStatus = Signal(object)

	pta_with_tip_tmpl = '''<center><h2><hr />Payment Authorization<hr /></h2></center>
<table align="right">
<tr><td align="right">Limit: </td><td align="right"><font size="12" color="black"><strong>{limit}</strong></font></td></tr>
<tr><td align="right">Tip: </td><td align="right"><font size="12" color="blue"><strong>{tip}</strong></font></td></tr>
<tr><td align="right" colspan="2"><br />{expiry}</td></tr>
</table>
'''

	pta_no_tip_tmpl = '''<center><h2><hr />Payment Authorization<hr /></h2></center>
<table align="right">
<tr><td align="right">Limit: </td><td align="right"><font size="12" color="black"><strong>{limit}</strong></font></td></tr>
<tr><td align="right" colspan="2"><br />{expiry}</td></tr>
</table>
'''

	def error(self, txt):
		self.onStatus.emit('<font color="red">%s</font>' % txt)

	def on_payment_authorization(self):
		'''Handles PTA'''

		# public block of PTA
		p1 = self.doc.block( 'P1' )
		
		self.pta = Segment()

		# parse PTA's public members
		self.pta.ctime = p1.read_int64() # create time
		self.pta.expiry = p1.read_int64() # expiry
		
		# payment limit
		self.pta.payment_limit = decimal_from_parts(p1.read_int64(), p1.read_int16())
		
		# optional gratuity
		self.pta.has_tip = bool( p1.read_byte() ) # has tip?
		self.pta.tip = Decimal("0.00")
		if self.pta.has_tip:
			# gratuity type
			self.pta.tip_type = p1.read_fixed_string(1)
			if self.pta.tip_type not in ('A', 'P'):
				raise pcos.PcosError( const.ERR_INVALID_GRATUITY_TYPE, "PTA: '%s' is not a supported gratuity type" % self.pta.tip_type)
			
			# gratuity amount
			self.pta.tip = decimal_from_parts(p1.read_int64(), p1.read_int16())
			if self.pta.tip < 0:
				raise pcos.PcosError( const.ERR_VALUE_OUT_OF_RANGE, "PTA: gratuity cannot be negative")

		# currency
		self.pta.currency = p1.read_fixed_string(3).upper()
		# presently we only deal with US dollars
		if self.pta.currency != 'USD':
			raise pcos.PcosError( const.ERR_INVALID_CURRENCY, "PTA: '%s' is not a supported currency" % self.pta.currency)

		# private key identifier, not used here
		keyid = p1.read_fixed_string(4)

		self.pta.receiver = p1.read_short_string() # email of the payment receiver
		self.pta.note = p1.read_short_string() # note

		# make PTA data pretty
		ctime_prt = time.strftime("%x %X", time.localtime(self.pta.ctime))
		now = long( time.time() + 0.5 )
		seconds = self.pta.expiry - now
		if seconds < 0:
			expiry_prt = '<font color="red"><strong>PAYMENT EXPIRED</strong></font>'
		else:
			expiry_prt = '<i>Expires in %s</i>' % str(datetime.timedelta(seconds=seconds))
		payment_limit_prt = '$' + str(self.pta.payment_limit.quantize(Decimal('0.01')))

		tip_prt = ''
		if self.pta.has_tip:
			if self.pta.tip_type == 'A':
				tip_prt = '$' + str(self.pta.tip.quantize(Decimal('0.01')))
			else:
				tip_prt = '%' + str(self.pta.tip.quantize(Decimal('0.01')))
			html = self.pta_with_tip_tmpl.format(
				ctime = ctime_prt, 
				expiry = expiry_prt, 
				limit = payment_limit_prt, 
				tip = tip_prt)
		else:
			html = self.pta_no_tip_tmpl.format(
				ctime = ctime_prt, 
				expiry = expiry_prt, 
				limit = payment_limit_prt)
		return html


	#-------------------------------
	#  register handlers here
	#-------------------------------
	def __init__(self):
		QObject.__init__(self)

		self.lookup = {
			'Pa': self.on_payment_authorization,
		}


	def parse_pcos(self, data):
		self.doc = pcos.Doc( data )
		# find the message handler
		handler = self.lookup.get( self.doc.message_id, None )
		if handler:
			# handler found, process the message
			html = handler()
			self.onRenderData.emit(html)

		else: # unknown request
			self.error("unknown message: %s" % doc.message_id)


	def reset(self):
		self.pta = None
		self.onRenderData.emit('')


def decimal_to_parts(value):
	'''Breaks down the decimal into a tuple of value and scale'''
	value = value.normalize()
	exp = int( value.as_tuple()[2] )
	# if scale is negative, we have to shift to preserve precision
	if exp < 0:
		return (long(value.shift(-(exp))), exp)
	else:
		return (long(value), 0)


def decimal_from_parts(value, scale):
	'''Returns Decimal from value and scale'''
	if scale > const.MAX_SCALE_VAL:
		raise pcos.PcosError( const.ERR_VALUE_OUT_OF_RANGE, "scale cannot exceed %s" % const.MAX_SCALE_VAL )
	return Decimal( value ).scaleb( scale )


class Segment():
	'''Holds data'''
	pass
	
