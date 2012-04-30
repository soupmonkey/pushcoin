# Copyright (c) 2012 Minta, LLC.
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
__author__  = '''Slawomir Lisznianski <sl@minta.com>'''

import binascii, struct, ctypes

# This is an absolute minimum length (in bytes) for a PCOS serialized object.
MIN_MESSAGE_LENGTH = 10

# Block-meta record has a fixed size of 4 bytes
BLOCK_META_LENGTH = 4

# A four-byte identifier for PCOS protocol.
PROTOCOL_MAGIC = 'PCOS'

# PCOS parser error codes
PARSE_MESSAGE_TOO_SHORT = 1
PARSE_BAD_MAGIC = 2
PARSE_UNKNOWN_BLOCK_MODE = 3

class PcosError( Exception ):
	""" Basis for all exceptions thrown from the PCOS codec."""

	def __init__(self, code, what = ''):
		self.code = code
		self.what = what

	def __str__(self):
		return repr("(%s): %s" % (self.code, self. what) )

class BlockMeta:
	"""Stores meta information about a block found in the data-segment"""
	pass

class Doc:
	"""Parses binary data, presumably PCOS-encoded, and constructs a lightweight document."""

	# private PCOS header and block-meta parsers
	_HEADER_PARSER = struct.Struct('<4s2shh')
	_BLOCK_META = struct.Struct('<2sh')


	def __init__( self, data = None, name = None ): 
		"""Constructs PCOS from binary data."""

		# map of blocks, such that for a given block-name, we can quickly access its data
		self.blocks = { }
		self.message_id = name 

		if data:
			payload_length = len( data )
			if payload_length < MIN_MESSAGE_LENGTH:
				raise PcosError( PARSE_MESSAGE_TOO_SHORT )

			# parse the message header
			self.magic, self.message_id, self.length, self.block_count = Doc._HEADER_PARSER.unpack_from( data )

			# check if magic matches our encoding tag
			if self.magic != PROTOCOL_MAGIC:
				raise PcosError( PARSE_BAD_MAGIC )

			# check if payload is big enough to even hold block_count meta records
			# -- we could be lied!
			block_offset = MIN_MESSAGE_LENGTH + self.block_count * BLOCK_META_LENGTH

			if payload_length < block_offset:
				raise PcosError( PARSE_MESSAGE_TOO_SHORT )

			# data appears to be "one of ours", store it
			self.data = data
		
			# parse block-meta segment
			meta_offset = MIN_MESSAGE_LENGTH
			total_claimed_length = MIN_MESSAGE_LENGTH

			for i in range(0, self.block_count):
				blk = BlockMeta()
				blk.name, blk.length = Doc._BLOCK_META.unpack_from( data, meta_offset )
				blk.start = block_offset

				# store block meta-record
				self.blocks[blk.name] = blk

				# update running totals
				block_offset += blk.length
				meta_offset += BLOCK_META_LENGTH
				total_claimed_length += blk.length + BLOCK_META_LENGTH

			# all the block meta information collected -- check if payload's large enough
			# to hold all the "claimed" block-data
			if total_claimed_length < payload_length:
				raise PcosError( PARSE_MESSAGE_TOO_SHORT )


	def block( self, name ):
		"""Returns the block iterator for a given name."""

		meta = self.blocks.get( name, None )
		if not meta:
			return None # Oops, block not found!

		return Block(self, meta, 'I')


	def add( self, block ):
		"""Add a block to the data-segment."""

		self.blocks[ block.name() ] = block
		

	def encoded( self ):
		"""Returns encoded byte-stream."""

		write_offset = 0
		total_length = MIN_MESSAGE_LENGTH + BLOCK_META_LENGTH * len(self.blocks) + self._data_segment_size()
		payload = ctypes.create_string_buffer( total_length )
		Doc._HEADER_PARSER.pack_into( payload, write_offset, PROTOCOL_MAGIC, self.message_id, total_length, len(self.blocks) );
		write_offset += MIN_MESSAGE_LENGTH

		# write block enumeration
		for (name, b) in self.blocks.iteritems():
			Doc._BLOCK_META.pack_into( payload, write_offset, name, b.size() );
			write_offset += BLOCK_META_LENGTH

		# write block data
		for (name, b) in self.blocks.iteritems():
			ctypes.memmove( ctypes.byref( payload, write_offset ), b.data, b.size() )
			write_offset += b.size()

		return payload


	def _data_segment_size( self ):
		"""(Private) Returns size of all data blocks."""
		size = 0
		for (name, b) in self.blocks.iteritems():
			size += b.size()
		return size


class Block:
	"""Provides facilities for creating a new block or iterating over and parsing block data."""

	def __init__( self, v1, v2, mode ):
		if mode == 'I':
			self.init_as_input_block( v1, v2 ) 
		elif mode == 'O':
			self.init_as_output_block( v1, v2 ) 
		else:
			raise PcosError( PARSE_UNKNOWN_BLOCK_MODE )


	def init_as_output_block( self, name, size ):
		"""Initializes block in 'output' mode."""
		self.mode = "O"
		self.data = ctypes.create_string_buffer( size )
		self.meta = BlockMeta()
		self.meta.name = name
		self.meta.length = 0 # current writing cursor position
		self.meta.start = 0
		self.capacity = size # how much can we fit


	def init_as_input_block( self, doc, meta ):
		"""Initializes block in 'input' mode."""
		self.mode = "I"
		self.doc = doc
		self.meta = meta

		# current cursor position
		self.offset = 0 # current reading cursor position


	def size( self ):
		return self.meta.length


	def name( self ):
		return self.meta.name


	def remaining( self ):
		"""In input mode, returns how much data can be read. In output mode, returns remaining buffer capacity."""

		if self.mode == 'I':
			return self.meta.length - self.offset
		else:
			# output mode, tells how much room is left
			return self.capacity - self.meta.length


	def read_int64( self ):
		assert self.mode == 'I'
		if self.remaining() < 8:
			raise PcosError( PARSE_MESSAGE_TOO_SHORT )

		(val,) = struct.unpack_from("<q", self.doc.data, self.meta.start + self.offset)
		self.offset += 8
		return val


	def write_int64( self, val ):
		assert self.mode == 'O'
		if self.remaining() < 8:
			raise PcosError( PARSE_MESSAGE_TOO_SHORT )
		struct.pack_into("<q", self.data, self.meta.length, val)
		self.meta.length += 8
		

def _reading_test_pong():
	"""Tests if parser handles Pong message correctly"""

	# `Pong' message, normally arriving on the wire
	data = binascii.unhexlify( '50434f53506f16000100546d0800609d9e4f00000000' )

	# read message preamble, create a lightweight PCOS document 
	msg = Doc( data )

	# jump to the block of interest
	tm = msg.block( 'Tm' )

	# read block field(s)
	tm_epoch = tm.read_int64();

	assert tm_epoch == 1335795040

	
def _writing_test_pong():
	"""Tests if parser produces correct PCOS Pong message"""

	tm = Block( 'Tm', 20, 'O' )
	tm.write_int64( 1335795040 )

	msg = Doc( name="Po" )
	msg.add( tm )
	
	# Get encoded PCOS data 	
	generated_data = msg.encoded()

	# Comparison data
	sample_data = binascii.unhexlify( '50434f53506f16000100546d0800609d9e4f00000000' )

	assert str(generated_data.raw) == str(sample_data)

if __name__ == "__main__":
	"""Tests basic parser functionality."""

	# Reading test...
	_reading_test_pong()
	
	# Writing test...
	_writing_test_pong()

	print "Looks good."

