#!/usr/bin/python
# -*- coding: utf-8 -*-
import sys, urllib2, time, struct
import logging as log
from config import *
from optparse import OptionParser,OptionError
from pyparsing import *

PCOS_MIN_MESSAGE_LENGTH = 10                                                                           
PCOS_BLOCK_META_LENGTH = 4
PCOS_HEADER_MAGIC = 'PCOS'  

class BlockMeta:
	pass;

class RmoteCall:
#	# CMD: `register'
#	def register(self):
#		# validate input
#		self.require('aid')
#		self.require('iid')
#		self.require('pkey')
#		msg = {
#				u"mid": u"register",
#				u"aid": unicode(self.args['aid']), 
#				u"iid": unicode(self.args['iid']), 
#				u"pkey": self.args['pkey'], 
#				u"agent": unicode(self.args.get('agent', 'cli_sim')), 
#			}
#		print self.send( msg )

	# CMD: `ping'
	def ping(self):
		(msg_id, blocks) = self.send( 'Pi', [] )
		tm_block = blocks['Tm']
		(tm,) = self.pong.unpack_from( tm_block )
		server_time = time.strftime("%a, %d %b %Y %H:%M:%S +0000", time.gmtime(tm))
		log.info('RETN %s', server_time )

	def __init__(self, options, cmd, args):
		# store the cmd and args for the command-handler
		self.options = options
		self.cmd = cmd
		self.args = args

		# PCOS structs
		self.header = struct.Struct('<4s2shh')
		self.block_meta = struct.Struct('<2sh')
		self.pong = struct.Struct('<q')

		# list of commands (PushCoin requests) we are supporting:
		self.lookup = {
#		"register": self.register,
			"ping": self.ping,
		}		

	# invoked if user asks for an unknown command
	def unknown_command(self):
		raise RuntimeError("'%s' is not a recognized command" % self.cmd)

	# helper in checking required input param 
	def require(self, name):
		if name not in self.args:
			raise RuntimeError("CMD '%s': missing argument '%s'" % (self.cmd, name))		

	# entry point to call out to the server
	def call(self):
		# lookup the command and invoke it
		cmd = self.lookup.get(self.cmd, self.unknown_command)
		cmd();
		
	# sends request to the server, returns result
	def send(self, msg_id, blocks):
		if len(msg_id) != 2:
			raise RuntimeError("Invalid message-id '%s' -- must be two characters" % (msg_id))		

		# write block enumeration, compute total length
		total_length = PCOS_MIN_MESSAGE_LENGTH
		block_enum = ''
		block_data = ''
		for b in blocks:
			block_length = len(b.data)
			block_value = (b.identifier, block_length)
			block_enum += self.block_meta.pack( *block_value );
			block_data += b.data;
			total_length += block_length + PCOS_BLOCK_META_LENGTH

		hdr_values = (PCOS_HEADER_MAGIC, msg_id, total_length, len(blocks) )
		hdr = self.header.pack( *hdr_values );
		payload = ''.join( (hdr, block_enum, block_data) )

		reqf = open('request.pcos', 'w')
		reqf.write( payload )
		reqf.close()

		log.info('CALL %s%s sz=%s', self.cmd, str(self.args), total_length )
		remote_call = urllib2.urlopen(self.options.url, payload )
		response = remote_call.read()

		reqf = open('response.pcos', 'w')
		reqf.write( response )
		reqf.close()

    # determine length of the response
		if len( response ) < PCOS_MIN_MESSAGE_LENGTH:
			raise RuntimeError('response payload too short')
		
		# parse the message header
		(magic, message_id, length, block_count) = self.header.unpack_from(response)
		log.info("RCV '%s' sz=%s blocks=%s", message_id, length, block_count )

		res = { }
		# create map of blocks
		meta_offset = PCOS_MIN_MESSAGE_LENGTH
		block_offset = PCOS_MIN_MESSAGE_LENGTH + block_count * PCOS_BLOCK_META_LENGTH
		for i in range(0, block_count):
			(block_id, block_length) = self.block_meta.unpack_from(response, meta_offset)
			res[block_id] = response[ block_offset : block_offset + block_length]
			block_offset += block_length
			meta_offset += PCOS_BLOCK_META_LENGTH

		return (message_id, res)

if __name__ == "__main__":
	# start with basic logger configuration
	log.basicConfig(level=log.INFO, format='%(asctime)s %(levelname)s %(message)s')
	
	# program arguments
	usage = "usage: %prog [options] <command> [args]"
	version = "PushCoin IceBreaker v1.0"
	parser = OptionParser(usage, version = version)
	parser.add_option("-C", "--url", dest="url", action="store", default="https://api.pushcoin.com:20001/pcos/", help="server URL")
	
	if len(sys.argv) == 0:
		parser.print_help()
		exit(1)
	
	(options, args) = parser.parse_args()
	
	if len(args) < 1: 
		raise RuntimeError('missing command argument') 

	cmd = args[0]
	cmd_args = { }
	if len(args) > 1: 
		# define basic elements - use re's for numerics, faster and easier than 
		# composing from pyparsing objects
		integer = Regex(r'[+-]?\d+')
		real = Regex(r'[+-]?\d+\.\d*')
		ident = Word(alphanums)
		value = real | integer | quotedString.setParseAction(removeQuotes)

		# define a key-value pair, and a configline as one or more of these
		configline = dictOf(ident + Suppress('='), value + Suppress(Optional(':')))
		cmd_args = configline.parseString(args[1]).asDict()

	print version
	
	pushCoin = RmoteCall(options, cmd, cmd_args)
	pushCoin.call()
	
	log.info('Bye.')
	exit(0)
