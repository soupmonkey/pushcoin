#!/usr/bin/python
# -*- coding: utf-8 -*-
import sys, urllib2, time
import logging as log
import pcos
from config import *
from optparse import OptionParser,OptionError
from pyparsing import *

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

		req = pcos.Doc( name="Pi" )
		res = self.send( req )
		# jump to the block of interest
		tm = res.block( 'Tm' )

		# read block field(s)
		tm_epoch = tm.read_int64();
		server_time = time.strftime("%a, %d %b %Y %H:%M:%S +0000", time.gmtime(tm_epoch))
		log.info('RETN %s', server_time )

	def __init__(self, options, cmd, args):
		# store the cmd and args for the command-handler
		self.options = options
		self.cmd = cmd
		self.args = args

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
	def send(self, req):

		# Get encoded PCOS data 	
		encoded = req.encoded()

		# For debugging, we write request and response
		if self.options.is_writing_io:
			reqf = open('request.pcos', 'w')
			reqf.write( encoded )
			reqf.close()

		log.info('CALL %s%s', self.cmd, str(self.args) )
		remote_call = urllib2.urlopen(self.options.url, encoded )
		response = remote_call.read()

		if self.options.is_writing_io:
			reqf = open('response.pcos', 'w')
			reqf.write( response )
			reqf.close()

		# return a lightweight PCOS document 
		return pcos.Doc( response )

if __name__ == "__main__":
	# start with basic logger configuration
	log.basicConfig(level=log.INFO, format='%(asctime)s %(levelname)s %(message)s')
	
	# program arguments
	usage = "usage: %prog [options] <command> [args]"
	version = "PushCoin IceBreaker v1.0"
	parser = OptionParser(usage, version = version)
	parser.add_option("-C", "--url", dest="url", action="store", default="https://api.pushcoin.com:20001/pcos/", help="server URL")
	parser.add_option("-S", "--save-io", dest="is_writing_io", action="store_true", default=False, help="save request and response to files")
	
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
