// SPDX-License-Identifier: MIT
pragma solidity >=0.5.16;

import {ECDSA} from "./libraries/ECDSA.sol";

import "./interfaces/CarInterface.sol";
import "./Authorizer.sol";
import "./BaseManager.sol";

contract CarManager is BaseManager {
    using ECDSA for bytes32;

    bytes32 public constant CREATE_CAR_METHOD = "create(bytes32,bytes,uint256)";
    bytes32 public constant DELIVER_CAR_METHOD = "deliverCar(address)";
    bytes32 public constant SELL_CAR_METHOD = "sellCar(address)";
    bytes32 public constant REGISTER_CAR_METHOD = "registerCar()";
    bytes32 public constant UPDATE_CAR_METHOD = "updateCarState(bytes,uint256)";

    enum CarState {SHIPPED, FOR_SALE, SOLD, REGISTERED}

    enum CarType {
        TWO_WHEEL,
        THREE_WHEEL,
        FOUR_WHEEL,
        HEAVY,
        AGRICULTURE,
        SERVICE
    }

    struct Car {
        string licensePlate;
        CarType carType;
        CarState carState;
    }

    mapping(address => Car) public trackedCars;
    uint256[] public registeredCars;

    event CarAdded(address indexed carAddress); // probably we need carOwner's address in the event
    event ITVInspection(uint256 indexed carID);
    event CarStateUpdated(address indexed carID, uint256 carState);

    constructor(
        address authorizerContractAddress,
        address carTokenContractAddress
    ) public BaseManager(authorizerContractAddress, carTokenContractAddress) {}

    function createCar(
        bytes32 carIdHash,
        bytes calldata signature,
        uint256 carTypeIndex
    ) external onlyAuthorized(CREATE_CAR_METHOD, msg.sender) {
        address carAddress = carIdHash.recover(signature);

        carToken.mint(msg.sender, carIdHash, carAddress);

        trackedCars[carAddress] = Car({
            licensePlate: "",
            carType: CarType(carTypeIndex),
            carState: CarState.SHIPPED
        });

        emit CarAdded(carAddress);
    }

    function deliverCar(address carAddress)
        public
        onlyAuthorized(DELIVER_CAR_METHOD, msg.sender)
    {
        require(
            CarState.SHIPPED == trackedCars[carAddress].carState,
            "This car is not shipped"
        );

        _updateCarState(carAddress, uint256(CarState.FOR_SALE));
    }

    function sellCar(address carAddress)
        public
        onlyAuthorized(SELL_CAR_METHOD, msg.sender)
        onlyAssetOwner(carAddress, msg.sender)
    {
        require(
            CarState.FOR_SALE == trackedCars[carAddress].carState,
            "This car is not for sale"
        );

        _updateCarState(carAddress, uint256(CarState.SOLD));
    }

    function registerCar(address carAddress, string memory licensePlate)
        public
        onlyAuthorized(REGISTER_CAR_METHOD, msg.sender)
        onlyAssetOwner(carAddress, msg.sender)
    {
        require(
            CarState.SOLD == trackedCars[carAddress].carState,
            "This car is not sold"
        );

        trackedCars[carAddress].licensePlate = licensePlate;

        _updateCarState(carAddress, uint256(CarState.REGISTERED));
    }

    function getCar(address carAddress)
        external
        view
        returns (
            address id,
            string memory licensePlate,
            uint256 carType,
            uint256 carState
        )
    {
        Car memory car = trackedCars[carAddress];

        return (
            carAddress,
            car.licensePlate,
            uint256(car.carType),
            uint256(car.carState)
        );
    }

    function _updateCarState(address carAddress, uint256 carStateIndex)
        internal
    {
        trackedCars[carAddress].carState = CarState(carStateIndex);

        emit CarStateUpdated(carAddress, carStateIndex);
    }
}
