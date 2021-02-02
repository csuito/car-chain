pragma solidity >=0.5.16;

contract Authorizer {
    address public owner;

    mapping(address => mapping(bytes32 => mapping(address => bool)))
        public permissions;

    event PermissionAdded(
        address indexed _contract,
        address indexed _to,
        string _method
    );

    event PermissionRemoved(
        address indexed _contract,
        address indexed _to,
        string _method
    );

    modifier onlyOwner() {
        require(msg.sender == owner, 'Only owner can manage permissions');
        _;
    }

    constructor() public {
        owner = msg.sender;
    }

    function addPermission(
        address _contract,
        string memory _method,
        address _to
    ) public onlyOwner {
        bytes32 methodHash = keccak256(abi.encodePacked(_method));
        permissions[_contract][methodHash][_to] = true;
        emit PermissionAdded(_contract, _to, _method);
    }

    function removePermission(
        address _contract,
        string memory _method,
        address _to
    ) public onlyOwner {
        bytes32 methodHash = keccak256(abi.encodePacked(_method));
        require(
            permissions[_contract][methodHash][_to] == true,
            'Permision do not exist'
        );
        permissions[_contract][methodHash][_to] = false;
        emit PermissionRemoved(_contract, _to, _method);
    }

    function requestAccess(
        address _contract,
        string memory _method,
        address _to
    ) public view returns (bool) {
        bytes32 methodHash = keccak256(abi.encodePacked(_method));
        return permissions[_contract][methodHash][_to];
    }
}
