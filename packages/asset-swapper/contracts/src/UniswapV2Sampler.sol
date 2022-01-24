// SPDX-License-Identifier: Apache-2.0
/*

  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6;
pragma experimental ABIEncoderV2;

import "./interfaces/IUniswapV2Router01.sol";
import "./SamplerBase.sol";


contract UniswapV2Sampler
{
    /// @dev Gas limit for UniswapV2 calls.
    uint256 constant private UNISWAPV2_CALL_GAS = 150e3; // 150k

    /// @dev Sample sell quotes from UniswapV2.
    /// @param router Router to look up tokens and amounts
    /// @param path Token route. Should be takerToken -> makerToken
    /// @return makerTokenAmounts Maker amounts bought at each taker token
    ///         amount.
    function sampleSellsFromUniswapV2Global(
        address router,
        address[] memory path
    )
        public
        view
        returns (uint256[] memory makerTokenAmounts)
    {
        makerTokenAmounts = this.sampleSellsFromUniswapV2(
            router,
            path,
            SamplerBase(address(this)).getSampleValues()
        );
    }

    /// @dev Sample sell quotes from UniswapV2.
    /// @param router Router to look up tokens and amounts
    /// @param path Token route. Should be takerToken -> makerToken
    /// @param takerTokenAmounts Taker token sell amount for each sample.
    /// @return makerTokenAmounts Maker amounts bought at each taker token
    ///         amount.
    function sampleSellsFromUniswapV2(
        address router,
        address[] memory path,
        uint256[] memory takerTokenAmounts
    )
        public
        view
        returns (uint256[] memory makerTokenAmounts)
    {
        uint256 numSamples = takerTokenAmounts.length;
        makerTokenAmounts = new uint256[](numSamples);
        for (uint256 i = 0; i < numSamples; i++) {
            try
                IUniswapV2Router01(router).getAmountsOut
                    {gas: UNISWAPV2_CALL_GAS}
                    (takerTokenAmounts[i], path)
                returns (uint256[] memory amounts)
            {
                makerTokenAmounts[i] = amounts[path.length - 1];
                // Break early if there are 0 amounts
                if (makerTokenAmounts[i] == 0) {
                    break;
                }
            } catch (bytes memory) {
                // Swallow failures, leaving all results as zero.
                break;
            }
        }
    }

    /// @dev Sample buy quotes from UniswapV2.
    /// @param router Router to look up tokens and amounts
    /// @param path Token route. Should be takerToken -> makerToken.
    /// @param makerTokenAmounts Maker token buy amount for each sample.
    /// @return takerTokenAmounts Taker amounts sold at each maker token
    ///         amount.
    function sampleBuysFromUniswapV2(
        address router,
        address[] memory path,
        uint256[] memory makerTokenAmounts
    )
        public
        view
        returns (uint256[] memory takerTokenAmounts)
    {
        uint256 numSamples = makerTokenAmounts.length;
        takerTokenAmounts = new uint256[](numSamples);
        for (uint256 i = 0; i < numSamples; i++) {
            try
                IUniswapV2Router01(router).getAmountsIn
                    {gas: UNISWAPV2_CALL_GAS}
                    (makerTokenAmounts[i], path)
                returns (uint256[] memory amounts)
            {
                takerTokenAmounts[i] = amounts[0];
                // Break early if there are 0 amounts
                if (takerTokenAmounts[i] == 0) {
                    break;
                }
            } catch (bytes memory) {
                // Swallow failures, leaving all results as zero.
                break;
            }
        }
    }
}
