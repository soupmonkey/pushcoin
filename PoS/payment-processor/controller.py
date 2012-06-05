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
import sys, pcos, urllib2, binascii, time
from decimal import Decimal
from PySide.QtCore import *
import settings as const

class AppController(QObject):
	'''Handles data events, communicates with the PushCoin backend'''

	onDataArrived = Signal(object)
	onStatus = Signal(object)
	def error(self, txt):
		self.onStatus.emit('<font color="red">%s</font>' % txt)

	def on_payment_authorization(self):
		'''Handles PTA'''

		# public block of PTA
		p1 = self.payload.doc.block( 'P1' )
		
		self.payload.pta = Segment('PTA')

		# parse PTA's public members
		self.payload.pta.ctime = p1.read_int64() # create time
		self.payload.pta.expiry = p1.read_int64() # expiry
		
		# payment limit
		self.payload.pta.payment_limit = decimal_from_parts(p1.read_int64(), p1.read_int16())
		
		# optional gratuity
		self.payload.pta.has_tip = bool( p1.read_byte() ) # has tip?
		self.payload.pta.tip = Decimal("0.00")
		if self.payload.pta.has_tip:
			# gratuity type
			self.payload.pta.tip_type = p1.read_fixed_string(1)
			if self.payload.pta.tip_type not in ('A', 'P'):
				raise pcos.PcosError( const.ERR_INVALID_GRATUITY_TYPE, "PTA: '%s' is not a supported gratuity type" % self.payload.pta.tip_type)
			
			# gratuity amount
			self.payload.pta.tip = decimal_from_parts(p1.read_int64(), p1.read_int16())
			if self.payload.pta.tip < 0:
				raise pcos.PcosError( const.ERR_VALUE_OUT_OF_RANGE, "PTA: gratuity cannot be negative")

		# currency
		self.payload.pta.currency = p1.read_fixed_string(3).upper()
		# presently we only deal with US dollars
		if self.payload.pta.currency != 'USD':
			raise pcos.PcosError( const.ERR_INVALID_CURRENCY, "PTA: '%s' is not a supported currency" % self.payload.pta.currency)

		# private key identifier, not used here
		keyid = p1.read_fixed_string(4)

		self.payload.pta.receiver = p1.read_short_string() # email of the payment receiver
		self.payload.pta.note = p1.read_short_string() # note

		# return PTA object (acutally, just the public segment of it)
		return self.payload.pta


	#-------------------------------
	#  register handlers here
	#-------------------------------
	def __init__(self):
		QObject.__init__(self)

		# empty payload
		self.payload = None

		# payload handlers
		self.lookup = {
			'Pa': self.on_payment_authorization,
		}


	def parse_pcos(self, data):
		try:
			self.payload = Segment('Body')
			self.payload.data = data
			self.payload.doc = pcos.Doc( data )
			# find the message handler
			handler = self.lookup.get( self.payload.doc.message_id, None )
			if handler:
				# handler found, process the message and emit results
				self.onDataArrived.emit( handler() )

			else: # unknown request
				raise RuntimeError("Unsupported PTA message: %s" % payload.doc.message_id)

		except Exception, e:
			err = Segment('Er')
			err.what = str(e)
			self.onDataArrived(err)


	def submit(self, form):
		'''Submits PTA to the server'''
		try:
			if not (self.payload and hasattr(self.payload, 'pta')):
				raise RuntimeError("No Payment Certificate")

			# package PTA into a block
			pta = pcos.Block( 'Pa', 512, 'O' )
			pta.write_fixed_string(self.payload.data, size=len(self.payload.data))

			# create payment-request block
			r1 = pcos.Block( 'R1', 1024, 'O' )
			r1.write_fixed_string( binascii.unhexlify( const.MERCHANT_MAT ), size=20 ) # mat
			r1.write_short_string( '', max=127 ) # ref_data
			r1.write_int64( long( time.time() + 0.5 ) ) # request create-time

			# charge amount
			(charge_value, charge_scale) = decimal_to_parts(form.charge)
			r1.write_int64( charge_value ) # value
			r1.write_int16( charge_scale ) # scale

			# tax: basic terminal app doesn't expect user to enter this
			r1.write_byte(0) # no tax info

			# tip
			if form.tip:
				r1.write_byte(1) # has tip info
				(tip_value, tip_scale) = decimal_to_parts(form.tip)
				r1.write_int64( tip_value ) # value
				r1.write_int16( tip_scale ) # scale
			else:
				r1.write_byte(0) # no tip info

			r1.write_fixed_string( const.CURRENCY_CODE, size=3 ) # currency
			r1.write_short_string( form.order_id, max=24 ) # invoice ID
			r1.write_short_string( form.note, max=127 ) # note
			r1.write_int16(0) # list of purchased goods

			# package everything and ship out
			req = pcos.Doc( name="Pt" )
			req.add( pta )
			req.add( r1 )

			res = self.send( req )
			self.expect_success( res, form.charge, form.order_id, form.note )

		except Exception, e:
#TODO			log.error('Success (tx_id: %s, ref_data: %s)', binascii.hexlify( transaction_id ), binascii.hexlify( ref_data ))
			err = Segment('Er')
			err.what = str(e)

			# emit the message
			self.onDataArrived.emit(err)


	def reset(self):
		self.payload = None
		self.onDataArrived.emit( Segment('Clear') )


	def expect_success( self, res, charge, order_id, note ):
		'''Shows details of Success PCOS message'''
		if res.message_id == "Ok":
			bo = res.block( 'Bo' )
			ref_data = bo.read_short_string() # ref_data
			transaction_id = bo.read_short_string() # tx-id

			ok = Segment('Ok')
			time_prt = time.strftime("%x %X", time.localtime(time.time()))
			ok.what = '<p align="right">%s</p><center><h1><font color="#90ff90"><strong>Approved</strong></font></h1></center><center><h2>$%s</h2></center>' % (time_prt, charge)
			ok.what += '<br /><font size="2">ID: %s</font>' % binascii.hexlify( transaction_id )
			if order_id:
				ok.what += '<br /><font size="2">Order: %s</font>' % order_id
			if note:
				ok.what += '<br /><font size="2">Note: %s</font>' % note

			# after submission and successful return, reset state
			self.payload = None

			# emit the message
			self.onDataArrived.emit(ok)

#TODO			log.info('Success (tx_id: %s, ref_data: %s)', binascii.hexlify( transaction_id ), binascii.hexlify( ref_data ))
		else:
			raise RuntimeError("'%s' not a Success message" % res.message_id)


	def send(self, req):
		'''Sends request to the server, returns result'''
		# Get encoded PCOS data 	
		encoded = req.encoded()

		remote_call = urllib2.urlopen(const.PUSHCOIN_SERVER_URL, encoded )
		response = remote_call.read()

		res = pcos.Doc( response )
		# check if response is not an error
		if res.message_id == 'Er':
			# jump to the block of interest
			er = res.block( 'Bo' )
			if er:
				ref_data = er.read_short_string();
				transaction_id = er.read_short_string();
				code = er.read_int32();
				what = er.read_short_string();
				raise RuntimeError('%s\nCode # %s\nTransaction ID:\n %s' % (what, code, binascii.hexlify( transaction_id ))) 
			else:
				raise RuntimeError('ERROR -- cause unknown') 

		# return a lightweight PCOS document 
		return res



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
	'''Named data chunk'''

	def __init__(self, name):
		self.msgid = name

