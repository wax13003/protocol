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
These are the basic functions for using a `Limit Order <../basics/orders.html#limit-orders>`_.

fillLimitOrder
--------------

Limit orders can be filled with the ``fillLimitOrder()`` or ``fillOrKillLimitOrder()`` functions on the Exchange Proxy. The address calling these function will be considered the "taker" of the order.


``fillLimitOrder()`` fills a single limit order for **up to** ``takerTokenFillAmount``:

.. code-block:: solidity

    function fillLimitOrder(
        // The order
        LimitOrder calldata order,
        // The signature
        Signature calldata signature,
        // How much taker token to fill the order with
        uint128 takerTokenFillAmount
    )
        external
        payable
        // How much maker token from the order the taker received.
        returns (uint128 takerTokenFillAmount, uint128 makerTokenFillAmount);

fillOrKillLimitOrder
--------------------

``fillOrKillLimitOrder()`` fills a single limit order for **exactly** ``takerTokenFillAmount``:

.. code-block:: solidity

    function fillOrKillLimitOrder(
        // The order
        LimitOrder calldata order,
        // The signature
        Signature calldata signature,
        // How much taker token to fill the order with
        uint128 takerTokenFillAmount
    )
        external
        payable
        // How much maker token from the order the taker received.
        returns (uint128 makerTokenFillAmount);

cancelLimitOrder
----------------

Because there is no way to un-sign an order that has been distributed, limit orders must be cancelled on-chain through one of several functions. They can only be called by the order's maker.

``cancelLimitOrder()`` cancels a single limit order created by the caller:

.. code-block:: solidity

    function cancelLimitOrder(
        // The order
        LimitOrder calldata order
    )
        external;

batchCancelLimitOrders
----------------------

``batchCancelLimitOrders()`` cancels multiple limit orders created by the caller:

.. code-block:: solidity

    function batchCancelLimitOrders(
        // The orders
        LimitOrder[] calldata orders
    )
        external;

cancelLimitPairOrders
---------------------

``cancelLimitPairOrders()`` will cancel all limit orders created by the caller with with a maker and taker token pair and a ``salt`` field < the ``salt`` provided. Subsequent calls to this function with the same tokens must provide a ``salt`` >= the last call to succeed.

.. code-block:: solidity

    function cancelLimitPairLimitOrders(
        address makerToken,
        address takerToken,
        uint256 salt;
    )
        external;

batchCancelLimitPairOrders
--------------------------

``batchCancelLimitPairOrders()`` performs multiple ``cancelLimitPairOrders()`` at once. Each respective index across arrays is equivalent to a single call.

.. code-block:: solidity

    function batchCancelLimitPairOrders(
        address[] makerTokens,
        address[] takerTokens,
        uint256[] salts;
    )
        external;

getLimitOrderInfo
-----------------

The Exchange Proxy exposes a function ``getLimitOrderInfo()`` to query information about a limit order, such as its fillable state and how much it has been filled by.

.. code-block:: solidity

    enum OrderStatus {
        INVALID,
        FILLABLE,
        FILLED,
        CANCELLED,
        EXPIRED
    }

    struct OrderInfo {
        // The order hash.
        bytes32 orderHash;
        // Current state of the order.
        OrderStatus status;
        // How much taker token has been filled in the order.
        uint128 takerTokenFilledAmount;
    }

    function getLimitOrderInfo(
        // The order
        LimitOrder calldata order
    )
        external
        view
        returns (OrderInfo memory orderInfo);

getLimitOrderHash
-----------------

The hash of the order is used to uniquely identify an order inside the protocol. It is computed following the `EIP712 spec <https://github.com/ethereum/EIPs/blob/master/EIPS/eip-712.md>`_ standard. In solidity, the hash is computed as:


.. code-block:: solidity

    /// @dev Get the canonical hash of a limit order.
    /// @param order The limit order.
    /// @return orderHash The order hash.
    function getLimitOrderHash(LibNativeOrder.LimitOrder calldata order)
        external
        view
        returns (bytes32 orderHash);

The simplest way to generate an order hash is by calling this function, ex:

.. code-block:: solidity

    bytes32 orderHash = IZeroEx(0xDef1C0ded9bec7F1a1670819833240f027b25EfF).getLimitOrderHash(order);

The hash can be manually generated using the following code:

.. code-block:: solidity

    bytes32 orderHash = keccak256(abi.encodePacked(
        '\x19\x01',
        // The domain separator.
        keccak256(abi.encode(
            // The EIP712 domain separator type hash.
            keccak256(abi.encodePacked(
                'EIP712Domain(',
                'string name,',
                'string version,',
                'uint256 chainId,',
                'address verifyingContract)'
            )),
            // The EIP712 domain separator values.
            'ZeroEx',
            '1.0.0',
            1, // For mainnet
            0xDef1C0ded9bec7F1a1670819833240f027b25EfF, // Address of the Exchange Proxy
        )),
        // The struct hash.
        keccak256(abi.encode(
            // The EIP712 type hash.
            keccak256(abi.encodePacked(
                'LimitOrder(',
                'address makerToken,',
                'address takerToken,',
                'uint128 makerAmount,',
                'uint128 takerAmount,',
                'uint128 takerTokenFeeAmount,',
                'address taker,',
                'address maker,',
                'address sender,',
                'address feeRecipient,',
                'bytes32 pool,',
                'uint64 expiry,',
                'uint256 salt)'
            )),
            // The struct values.
            order.makerToken,
            order.takerToken,
            order.makerAmount,
            order.takerAmount,
            order.takerTokenFeeAmount,
            order.maker,
            order.taker,
            order.sender,
            order.feeRecipient,
            order.pool,
            order.expiry,
            order.salt
        ))
    ));


RFQ Orders
==========

These are the basic functions for using an `RFQ Order <../basics/orders.html#rfq-orders>`_.

fillRfqOrder
------------

RFQ orders can be filled with the ``fillRfqOrder()`` or ``fillOrKillRfqOrder()`` functions on the Exchange Proxy. The address calling this function will be considered the "taker" of the order.

``fillRfqOrder()`` fills a single RFQ order for **up to** ``takerTokenFillAmount``:

.. code-block:: solidity

    function fillRfqOrder(
        // The order
        RfqOrder calldata order,
        // The signature
        Signature calldata signature,
        // How much taker token to fill the order with
        uint128 takerTokenFillAmount
    )
        external
        payable
        // How much maker token from the order the taker received.
        returns (uint128 takerTokenFillAmount, uint128 makerTokenFillAmount);

fillOrKillRfqOrder
------------------

``fillOrKillRfqOrder()`` fills a single RFQ order for **exactly** ``takerTokenFillAmount``:

.. code-block:: solidity

    function fillOrKillRfqOrder(
        // The order
        RfqOrder calldata order,
        // The signature
        Signature calldata signature,
        // How much taker token to fill the order with
        uint128 takerTokenFillAmount
    )
        external
        payable
        // How much maker token from the order the taker received.
        returns (uint128 makerTokenFillAmount);

cancelRfqOrder
--------------

Similar to limit orders, RFQ orders can be cancelled on-chain through a variety of functions, which can only be called by the order's maker.

``cancelRfqOrder()`` cancels a single RFQ order created by the caller:

.. code-block:: solidity

    function cancelRfqOrder(
        // The order
        RfqOrder calldata order
    )
        external;

batchCancelRfqOrders
--------------------

``batchCancelRfqOrders()`` cancels multiple RFQ orders created by the caller:

.. code-block:: solidity

    function batchCancelRfqOrders(
        // The orders
        RfqOrder[] calldata orders
    )
        external;

cancelPairRfqOrders
-------------------

``cancelPairRfqOrders()`` will cancel all RFQ orders created by the caller with with a maker and taker token pair and a ``salt`` field < the ``salt`` provided. Subsequent calls to this function with the same tokens must provide a ``salt`` >= the last call to succeed.

.. code-block:: solidity

    function cancelPairRfqOrders(
        address makerToken,
        address takerToken,
        uint256 salt;
    )
        external;

batchCancelPairRfqOrders
------------------------

``batchCancelPairRfqOrders()`` performs multiple ``cancelPairRfqOrders()`` at once. Each respective index across arrays is equivalent to a single call.

.. code-block:: solidity

    function batchCancelPairRfqOrders(
        address[] makerTokens,
        address[] takerTokens,
        uint256[] salts;
    )
        external;

getRfqOrderInfo
---------------

The Exchange Proxy exposes a function ``getRfqOrderInfo()`` to query information about an RFQ order, such as its fillable state and how much it has been filled by.

.. code-block:: solidity

    enum OrderStatus {
        INVALID,
        FILLABLE,
        FILLED,
        CANCELLED,
        EXPIRED
    }

    struct OrderInfo {
        // The order hash.
        bytes32 orderHash;
        // Current state of the order.
        OrderStatus status;
        // How much taker token has been filled in the order.
        uint128 takerTokenFilledAmount;
    }

    function getRfqOrderInfo(
        // The order
        RfqOrder calldata order
    )
        external
        view
        returns (OrderInfo memory orderInfo);

getRfqOrderHash
---------------

The hash of the order is used to uniquely identify an order inside the protocol. It is computed following the `EIP712 spec <https://github.com/ethereum/EIPs/blob/master/EIPS/eip-712.md>`_ standard. In solidity, the hash is computed as:

.. code-block:: solidity
    /// @dev Get the canonical hash of an RFQ order.
    /// @param order The RFQ order.
    /// @return orderHash The order hash.
    function getRfqOrderHash(LibNativeOrder.RfqOrder calldata order)
        external
        view
        returns (bytes32 orderHash);


The simplest way to generate an order hash is by calling this function, ex:

.. code-block:: solidity

    bytes32 orderHash = IZeroEx(0xDef1C0ded9bec7F1a1670819833240f027b25EfF).getRfqOrderHash(order);

The hash can be manually generated using the following code:

.. code-block:: solidity

    bytes32 orderHash = keccak256(abi.encodePacked(
        '\x19\x01',
        // The domain separator.
        keccak256(abi.encode(
            // The EIP712 domain separator type hash.
            keccak256(abi.encodePacked(
                'EIP712Domain(',
                'string name,',
                'string version,',
                'uint256 chainId,',
                'address verifyingContract)'
            )),
            // The EIP712 domain separator values.
            'ZeroEx',
            '1.0.0',
            1, // For mainnet
            0xDef1C0ded9bec7F1a1670819833240f027b25EfF, // Address of the Exchange Proxy
        )),
        // The struct hash.
        keccak256(abi.encode(
            // The EIP712 type hash.
            keccak256(abi.encodePacked(
                'RfqOrder(',
                'address makerToken,',
                'address takerToken,',
                'uint128 makerAmount,',
                'uint128 takerAmount,',
                'address maker,'
                'address txOrigin,'
                'bytes32 pool,',
                'uint64 expiry,',
                'uint256 salt)'
            )),
            // The struct values.
            order.makerToken,
            order.takerToken,
            order.makerAmount,
            order.takerAmount,
            order.maker,
            order.txOrigin,
            order.pool,
            order.expiry,
            order.salt
        ))
    ));


Protocol Fees
=============

getProtocolFeeMultiplier
------------------------

transferProtocolFeesForPools
----------------------------
