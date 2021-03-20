// SPDX-License-Identifier: MIT
pragma solidity >=0.5.16;

import "./interfaces/CarInterface.sol";
import "./BaseManager.sol";

contract ITVManager is BaseManager {
    enum ITVState {PASSED, NOT_PASSED, NEGATIVE}

    struct ITVInspection {
        ITVState state;
        uint256 date;
    }

    bytes32 public constant UPDATE_METHOD = "updateITV(uint256,uint256)";

    mapping(uint256 => ITVInspection[]) public ITVs;

    event ITVInspectionEvent(uint256 carID, ITVState state);

    constructor(
        address authorizerContractAddress,
        address carAssetContractAddress
    ) public BaseManager(authorizerContractAddress, carAssetContractAddress) {}

    function updateITV(uint256 carId, ITVState itvStateIndex)
        public
        onlyAuthorized(UPDATE_METHOD, msg.sender)
    {
        ITVs[carId].push(ITVInspection(itvStateIndex, now));

        emit ITVInspectionEvent(carId, itvStateIndex);
    }
}
