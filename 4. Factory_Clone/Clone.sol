// SPDX-License-Identifier: MIT 

pragma solidity ^0.8.26;

library ERC6551BytecodelLib {
    function getCreationCode(address _implementation) internal pure returns(bytes memory) {
        return
        abi.encodePacked(
            hex"3d602d80600a3d3981f3363d3d373d3d3d363d73",
            _implementation,
            hex"5af43d82803e903d91602b57fd5bf3"
        );
    }
}

contract CloneFactory {
    address public lastDeplyedAddr;

    event ProxyCreated(address target);

    function makeClone(address _implementation) external {
        bytes memory code = ERC6551BytecodelLib.getCreationCode(_implementation);

        address target;

        assembly {
            target := create(0, add(code, 0x20), mload(code))
        }

        emit ProxyCreated(target);

        lastDeplyedAddr = target;
    }
}

contract Implementation {
    uint256 public count;

    function set(uint256 _count) external {
        count = _count;
    }

    function inc() external {
        count += 1;
    }

    function dec() external {
        count -= 1;
    }
}