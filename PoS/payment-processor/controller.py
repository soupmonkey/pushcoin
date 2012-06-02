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
import sys, pcos, datetime
from decimal import Decimal
from PySide.QtCore import *


class AppController(QObject):
	'''Handles data events, communicates with the PushCoin backend'''

	onRenderData = Signal(object)
	onStatus = Signal(object)

	def error(self, txt):
		self.onStatus.emit('<font color="red">%s</font>' % txt)

	def on_payment_authorization(self):
		'''Handles PTA'''

		# public block of PTA
		p1 = self.doc.block( 'P1' )

		# parse PTA's public members
		ctime = p1.read_int64() # create time
		expiry = p1.read_int64() # expiry
		
		# payment limit
		payment_limit = decimal_from_parts(p1.read_int64(), p1.read_int16())
		
		# optional gratuity
		has_tip = bool( p1.read_byte() ) # has tip?
		if has_tip:
			# gratuity type
			tip_type = p1.read_fixed_string(1)
			if tip_type not in ('A', 'P'):
				raise pcos.PcosError( consts.ERR_INVALID_GRATUITY_TYPE, "PTA: '%s' is not a supported gratuity type" % tip_type)
			
			# gratuity amount
			tip = decimal_from_parts(p1.read_int64(), p1.read_int16())
			if tip < 0:
				raise pcos.PcosError( consts.ERR_VALUE_OUT_OF_RANGE, "PTA: gratuity cannot be negative")

		# currency
		currency = p1.read_fixed_string(3).upper()
		# presently we only deal with US dollars
		if currency != 'USD':
			raise pcos.PcosError( consts.ERR_INVALID_CURRENCY, "PTA: '%s' is not a supported currency" % currency)

		# private key identifier, not used here
		keyid = p1.read_fixed_string(4)

		receiver = p1.read_short_string() # email of the payment receiver
		note = p1.read_short_string() # note

		return { 'Created': ctime, 'Expires': expiry, 'Payment': payment_limit, 'Tip': tip, 'Currency': currency, 'Recipient': receiver, 'Note': note }

	#-------------------------------
	#  register handlers here
	#-------------------------------
	def __init__(self):
		QObject.__init__(self)

		self.lookup = {
			'Pa': self.on_payment_authorization,
		}

	@Slot(str)
	def parse_pcos(self, data):
		self.doc = pcos.Doc( data )
		# find the message handler
		handler = self.lookup.get( self.doc.message_id, None )
		if handler:
			# handler found, process the message
			kvs = handler()
			# format into a table
			body = '<table>'
			for k, v in kvs.items():
				body += ''.join('<tr><th>', k, '</th><td>', v, '</td></tr>')
			body += '</table>'
			onRenderData.emit(body)

		else: # unknown request
			self.error("unknown message: %s" % doc.message_id)


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
	if scale > consts.MAX_SCALE_VAL:
		raise pcos.PcosError( consts.ERR_VALUE_OUT_OF_RANGE, "scale cannot exceed %s" % consts.MAX_SCALE_VAL )
	return Decimal( value ).scaleb( scale )


