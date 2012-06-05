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

# PushCoin Error Codes from 
# https://pushcoin.com/Pub/SDK/ErrorCodes
#
ERR_ACCOUNT_NOT_FOUND=201
ERR_INVALID_CURRENCY=202
ERR_PAYMENT_SIGNATURE_CHECK_FAILED=203
ERR_CRYPTO_FAILURE=204
ERR_INVALID_GRATUITY_TYPE=205
ERR_VALUE_OUT_OF_RANGE=206
ERR_INVALID_RECIPIENT=207
ERR_EXPIRED_PTA=208
ERR_DUPLICATE_PTA=209
ERR_INSUFFICIENT_FUNDS=300

MAX_SCALE_VAL = 6

MERCHANT_MAT = '5bf54dd118bc866567061a2be41860f7b5389f7c'
CURRENCY_CODE = 'USD'
PUSHCOIN_SERVER_URL = 'https://api.pushcoin.com:20001/pcos/'
