#!/usr/bin/python
# -*- coding: utf-8 -*-
import sys, urllib2, time
import logging as log
import pcos, time, binascii
from optparse import OptionParser,OptionError
from pyparsing import *

# The transaction key and the key-ID where obtained from:
#   https://pushcoin.com/Pub/SDK/TransactionKeys
#
API_TRANSACTION_KEY_ID = 'ead13769'
API_TRANSACTION_KEY_PEM = '''-----BEGIN PUBLIC KEY-----
MFwwDQYJKoZIhvcNAQEBBQADSwAwSAJBALCxeCUEY06dbOBqlnf7pKDv8bIyz7wp
NtvPhjOcbovESqkjrR+fHawGccev96V4hLXB+0wPG6eTrfh4ryZBq0kCAwEAAQ==
-----END PUBLIC KEY-----'''

# Below, the DSA keys were generated as follows:
#   1. generate param file
#      openssl dsaparam 512 < /dev/random > dsa_param.pem
#   
#   2. generating DSA key, 512 bits
#      openssl gendsa dsa_param.pem -out dsa_priv.pem
#   
#   2b. optionally encrypt the key
#       openssl dsa -in dsa_priv.pem -des3 -out dsa_safe_priv.pem
#   
#   3. extract public key out of private, write in DER format
#      openssl dsa -in dsa_priv.pem -outform DER -pubout -out dsa_pub.der

TEST_DSA_KEY_PUB_PEM = '''-----BEGIN PUBLIC KEY-----
MIHxMIGoBgcqhkjOOAQBMIGcAkEA6DCdaRYmSb4vQUAkaqsR+Ph2aprcMAlDkRGL
Vc1N8Hi3sm97xR+b3IYTHRuYaSEyaWKvuByjbFnJRjyYBpTKqwIVAObFswWoV2wl
LoUs3//+1kRFOHY/AkADEXixNnXLQp3dDapOb57uM+6/TH4mZJizpvCqpVaonIz2
ZGzB+ws/EU7fmitScho04EJg+1xBbLsMbJ1lMxaoA0QAAkEAgnL2PItRT0fn8GJ4
YygfEG1wUMaW9YrkRNWuNtOBtw3WERn8fa+6VeTKujSfDcnnpj6mnyqusPhA4Ek6
iYVpxw==
-----END PUBLIC KEY-----'''

TEST_DSA_KEY_PRV_PEM = '''-----BEGIN DSA PRIVATE KEY-----
MIH3AgEAAkEAjfeT35NuNNXa9J6WFRGkbLFPbMjTvfBwBmlIBxkn5C7P7tbrSKX2
v4kkNOxaSoL1IbAcIsRfLAQONhu5OypILwIVAKPptYe+gRwRHTd47lSliZcv6HXx
AkASAkNvUTHAAayp1ozyEa42u/9el+r5ffTGK1VH9VYgCc3dcUHOxGl3gXl2KQfN
Pt6owQKKsZnrpgO1v1N+ciLWAkA9jERRrih0tMqrqBq3iRmpqQXFQhsy+oyPST9v
+KiP+POtARwoOToKJw8Ub8o3EdjoXWobCvDbxTMPP447uJkTAhR5+vvpezohpW2r
WBKhBPOqvJ8X+w==
-----END DSA PRIVATE KEY-----'''

class RmoteCall:

	# CMD: `payment'
	def payment(self):
		'''This command generates the Payment Transaction Authorization, or PTA. It does not communicate with the server, only produces a file.'''

		#------------------
		# PTA public-block
		#------------------
		p1 = pcos.Block( 'P1', 512, 'O' )
		now = long( time.time() + 0.5 )
		p1.write_int64( now ) # certificate create-time
		p1.write_int64( now + 24 * 3600 ) # certificate expiry (in 24 hrs)

		p1.write_int64( long( self.args['scaled-payment'] ) ) # payment
		p1.write_byte( int( self.args['scale'] ) ) # scale

		p1.write_fixed_string( "USD" ) # currency
		p1.write_fixed_string( binascii.unhexlify( API_TRANSACTION_KEY_ID ) ) # key-ID

		p1.write_short_string( '' ) # receiver
		p1.write_short_string( '' ) # note

		#-------------------
		# PTA private-block
		#-------------------
		s1 = pcos.Block( 'S1', 512, 'O' )

		# member authentication token
		mat = self.args['mat'] 
		if len( mat ) != 40:
			raise RuntimeError("MAT must be 40-characters long" % self.cmd)
		s1.write_fixed_string( binascii.unhexlify( self.args['mat'] ) )
		
		# signature of the public-block
		#   -checksum the public-block
		#   -sign the checksum

		p1.write_short_string( '' ) # empty user data, max=20
		p1.write_short_string( '' ) # empty reserved field, max 26
	
	def check_payment(self):
		'''Verifies if the PTA is valid. In particular, it checks if the account is valid and if the balance can cover the payment limit in the PTA.'''
		
	# CMD: `register'
	def register(self):
		req = pcos.Doc( name="Re" )
		bo = pcos.Block( 'Bo', 512, 'O' )
		bo.write_short_string( self.args['registration_id'] )
		bo.write_long_string( TEST_DSA_KEY_PUB )
		bo.write_short_string( ';'.join( ('IceBreaker/1.0', sys.platform, sys.byteorder, sys.version) ) )
		req.add( bo )

		res = self.send( req )

		# jump to the block of interest

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
			"register": self.register,
		}		

	# invoked if user asks for an unknown command
	def unknown_command(self):
		raise RuntimeError("'%s' is not a recognized command" % self.cmd)

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

		log.info('CALL %s %s', self.cmd, str(self.args) )
		remote_call = urllib2.urlopen(self.options.url, encoded )
		response = remote_call.read()

		if self.options.is_writing_io:
			reqf = open('response.pcos', 'w')
			reqf.write( response )
			reqf.close()

		res = pcos.Doc( response )
		# check if response is not an error
		if res.message_id == 'Er':
			# jump to the block of interest
			er = res.block( 'Bo' )
			if er:
				code = er.read_int32();
				what = er.read_short_string();
				log.error( '%s (#%s)', what, code )
			else:
				log.error( 'ERROR -- cause unknown' )
			raise RuntimeError('error result') 

		# return a lightweight PCOS document 
		return res

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

	print version

	cmd = args[0]
	cmd_args = { }
	if len(args) > 1: 
		# define basic elements - use re's for numerics, faster and easier than 
		# composing from pyparsing objects
		integer = Regex(r'[+-]?\d+')
		real = Regex(r'[+-]?\d+\.\d*')
		ident = Regex(r'\w+')
		value = real | integer | quotedString.setParseAction(removeQuotes)

		# define a key-value pair, and a configline as one or more of these
		configline = dictOf(ident + Suppress('='), value + Suppress(Optional(':')))
		cmd_args = configline.parseString(args[1]).asDict()
		print ("Parsed arguments: " + str(cmd_args))
	
	pushCoin = RmoteCall(options, cmd, cmd_args)
	pushCoin.call()
	
	log.info('Bye.')
	exit(0)
