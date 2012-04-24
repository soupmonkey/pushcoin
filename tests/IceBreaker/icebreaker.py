#!/usr/bin/python
# -*- coding: utf-8 -*-
import sys, pymongo, urllib2, time
import logging as log
from config import *
from optparse import OptionParser,OptionError
from pyparsing import *

class RmoteCall:
	# CMD: `register'
	def register(self):
		# validate input
		self.require('aid')
		self.require('iid')
		self.require('pkey')
		msg = {
				u"mid": u"register",
				u"aid": unicode(self.args['aid']), 
				u"iid": unicode(self.args['iid']), 
				u"pkey": self.args['pkey'], 
				u"agent": unicode(self.args.get('agent', 'cli_sim')), 
			}
		print self.send( msg )

	# CMD: `ping'
	def ping(self):
		msg = {
				u"mid": u"ping",
			}
		res = self.send( msg )
		server_time = time.strftime("%a, %d %b %Y %H:%M:%S +0000", time.gmtime(res['tm']))
		log.info('RETN %s', server_time )

	def __init__(self, options, cmd, args):
		# store the cmd and args for the command-handler
		self.options = options
		self.cmd = cmd
		self.args = args

		# list of commands (PushCoin requests) we are supporting:
		self.lookup = {
			"register": self.register,
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
	def send(self, msg):
		bson_obj = pymongo.bson.BSON.from_dict( msg )
		log.info('CALL %s%s sz=%s', msg['mid'], str(self.args), len( bson_obj ) )
		remote_call = urllib2.urlopen(self.options.url, bson_obj )
		bin_res = remote_call.read()
		log.info('%s', bin_res.encode('hex') )
		return pymongo.bson.BSON( bin_res ).to_dict()

if __name__ == "__main__":
	# start with basic logger configuration
	log.basicConfig(level=log.INFO, format='%(asctime)s %(levelname)s %(message)s')
	
	# program arguments
	usage = "usage: %prog [options] <command> [args]"
	version = "PushCoin IceBreaker v1.0"
	parser = OptionParser(usage, version = version)
	parser.add_option("-C", "--url", dest="url", action="store", default="https://api.pushcoin.com:20001/bson/", help="server URL")
	
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
