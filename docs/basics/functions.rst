###############################
Basic Functionality
###############################

Below is a catalog of basic Exchange functionality. For more advanced usage, like meta-transactions and dex aggregation, see the Advanced section. 

+---------------------------------+--------------------------------------------------------------------------+
| **Limit Orders**                | **Overview**                                                             |
+---------------------------------+--------------------------------------------------------------------------+
| `fillLimitOrder`_               | Fills a Limit Order up to the amount requested.                          |
+---------------------------------+--------------------------------------------------------------------------+
| `fillOrKillLimitOrder`_         | Fills exactly the amount requested or reverts.                           |
+---------------------------------+--------------------------------------------------------------------------+
| `cancelLimitOrder`_             | Cancels an order so that it can no longer be filled.                     |
+---------------------------------+--------------------------------------------------------------------------+
| `batchCancelLimitOrders`_       | A batch call to `cancelLimitOrder`.                                      |
+---------------------------------+--------------------------------------------------------------------------+
| `cancelLimitPairOrders`_        | Cancels orders in a specific market pair.                                |
|                                 | Ex: Cancel all orders selling WETH for USDC.                             |
+---------------------------------+--------------------------------------------------------------------------+
| `batchCancelLimitPairOrders`_   | A batch call to `cancelLimitPairOrders`.                                 |
+---------------------------------+--------------------------------------------------------------------------+
| `getLimitOrderInfo`_            | Returns the state of a given order.                                      |
+---------------------------------+--------------------------------------------------------------------------+
| `getLimitOrderHash`_            | Returns the EIP-712 hash for an order.                                   |
+---------------------------------+--------------------------------------------------------------------------+
| **RFQ Orders**                  | **Overview**                                                             |
+---------------------------------+--------------------------------------------------------------------------+
| `fillRfqOrder`_                 | These operate the same as the above functions, only for RFQ Orders.      |
+---------------------------------+                                                                          |
| `fillOrKillRfqOrder`_           |                                                                          |
+---------------------------------+                                                                          |
| `cancelRfqOrder`_               |                                                                          |
+---------------------------------+                                                                          |
| `batchCancelRfqOrders`_         |                                                                          |
+---------------------------------+                                                                          |
| `cancelPairRfqOrders`_          |                                                                          |
+---------------------------------+                                                                          |
| `batchCancelPairRfqOrders`_     |                                                                          |
+---------------------------------+                                                                          |
| `getRfqOrderInfo`_              |                                                                          |
+---------------------------------+                                                                          |
| `getRfqOrderHash`_              |                                                                          |
+---------------------------------+--------------------------------------------------------------------------+
| **Protocol Fees**               | **Overview**                                                             |
+---------------------------------+--------------------------------------------------------------------------+
| `getProtocolFeeMultiplier`_     | Takers of limit orders pay a protocol fee of `Multiplier * tx.gasprice`. |
|                                 | This returns the `Multiplier`.                                           |
+---------------------------------+--------------------------------------------------------------------------+
| `transferProtocolFeesForPools`_ | Transfers protocol fees from escrow to the 0x Staking System.            |
|                                 | This should be called near the end of each epoch.                        |
+---------------------------------+--------------------------------------------------------------------------+


Limit Orders
============


fillLimitOrder
--------------

fillOrKillLimitOrder
--------------

cancelLimitOrder
----------------

batchCancelLimitOrders
----------------------

cancelLimitPairOrders
---------------------

batchCancelLimitPairOrders
--------------------------

getLimitOrderInfo
-----------------

getLimitOrderHash
-----------------


RFQ Orders
==========

fillRfqOrder
------------

fillOrKillRfqOrder
------------------

cancelRfqOrder
--------------

batchCancelRfqOrders
--------------------

cancelPairRfqOrders
-------------------

batchCancelPairRfqOrders
------------------------

getRfqOrderInfo
---------------

getRfqOrderHash
---------------

Protocol Fees
=============

getProtocolFeeMultiplier
------------------------

transferProtocolFeesForPools
----------------------------
