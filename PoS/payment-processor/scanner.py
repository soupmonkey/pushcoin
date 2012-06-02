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
import sys, usb.core, usb.util, struct, binascii
from PySide.QtCore import *

class QrCodeScanner (QThread):
	'''Scans QR-Codes from a USB-connected scanner'''

	onData = Signal(object)
	onStatus = Signal(object)

	_LINE_HEADER_PARSER = struct.Struct('<B3s')

	def error(self, txt):
		self.onStatus.emit('<font color="red">%s</font>' % txt)

	def progress(self, txt):
		self.onStatus.emit(txt)

	def stop(self):
		self.__mtx.lock()
		self.__exiting = True
		self.__mtx.unlock()

	def __init__(self, model, vendor_id, product_id, end_tag):
		QThread.__init__( self )
		self.model = model
		self.vendor_id = vendor_id
		self.product_id = product_id
		self.end_tag = end_tag
		self.scanner_dev = None
		self.endpoint = None
		self.data = ''
		self.__exiting = False
		self.__mtx = QMutex()

	def __is_exiting(self):
		self.__mtx.lock()
		exiting = self.__exiting
		self.__mtx.unlock()
		return exiting

	def __present(self):
		if not self.scanner_dev:
			self.scanner_dev = usb.core.find(idVendor=self.vendor_id, idProduct=self.product_id)
			if not self.scanner_dev:
				self.error(self.model + " not found")
			else:
				self.progress(self.model + " found")
		return ( self.scanner_dev != None )

	def __release(self):
		if self.scanner_dev and self.endpoint:
			usb.util.claim_interface(self.scanner_dev, 0)

	def __claimed(self):
		assert self.scanner_dev
		if not self.endpoint:
			# detach all interfaces of this device
			id = 0
			for usb_ifce in self.scanner_dev[0]:
				if self.scanner_dev.is_kernel_driver_active(id):
					self.scanner_dev.detach_kernel_driver(id)
				id += 1

			# reset the configuration, claim ownership
			self.scanner_dev.reset()
			self.scanner_dev.set_configuration()
			usb.util.claim_interface(self.scanner_dev, 0)

			# obtain the endpoint
			self.endpoint = self.scanner_dev[0][(0,0)][0]
			self.progress(self.model + " is ready")
		return ( self.endpoint != None )


	def __read_data(self):
		data = ''
		while True:
			try:
				chunk_list = self.scanner_dev.read(self.endpoint.bEndpointAddress, 0x40, 0, 100)
				chunk = ''.join([chr(x) for x in chunk_list])
				data += chunk
				print ("read %s of data" % len(chunk))
			except usb.core.USBError as e:
				if e.args == ('Operation timed out',):
					if len(data) < 100:
						data = ''
				break
		return data


	def __process_data(self, data):
			# first byte tells you how much payload arrived
			cursor = 0
			extract = ''
			while cursor < len(data):
				(size, front_magic) = self._LINE_HEADER_PARSER.unpack_from( data[cursor:cursor+4] )
				if size == 0:
					break
				# determine if this is the last chunk
				if data[cursor+size-3:cursor+size] == self.end_tag:
					extract += data[cursor+4:cursor+size-5]			
					# last chunk!
					break
				else:
					# mid chunk...
					extract += data[cursor+4:cursor+size-3]
				cursor += size
			return extract


	def run(self):
		# Give the app some time before emitting status
		QThread.sleep(2)
		while True:
			if self.__is_exiting():
				break
			pcos = ''
			if self.__present() and self.__claimed():
				data = self.__read_data()
				if data:
					self.progress("Scanned %s bytes." % len(self.data) )
					pcos = self.__process_data(data)
			else:
				QThread.sleep(2)

			# simulate arrival of data
			if pcos:
				self.progress("PCOS %s bytes" % len(pcos))

		# release resources prior to exiting
		self.__release()
