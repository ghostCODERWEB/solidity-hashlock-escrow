// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {SuiteBase, AssetFlow} from "./SuiteBase.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC4626} from "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {ERC721Holder} from "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/// @title Hashlock token escrow
/// @notice ERC20 hash-locked transfers with SHA-256 preimages, recipient-only redemption and expiry refunds.
/// @dev Reference implementation; independent audit required before production.

contract HashlockEscrow is SuiteBase {
    using SafeERC20 for IERC20;
    IERC20 public immutable token;
    uint256 public liability;
    struct Lock {
        address sender;
        address recipient;
        uint256 amount;
        bytes32 hashlock;
        uint64 expiry;
        bool settled;
    }
    mapping(bytes32 => Lock) public locks;
    event Locked(
        bytes32 indexed id,
        address indexed sender,
        address indexed recipient,
        uint256 amount,
        uint64 expiry
    );
    event Redeemed(bytes32 indexed id, bytes preimage);
    event Refunded(bytes32 indexed id);
    constructor(address asset, address admin) SuiteBase(admin) {
        require(asset.code.length > 0, "asset");
        token = IERC20(asset);
    }
    function lock(
        bytes32 id,
        address recipient,
        uint256 amount,
        bytes32 hashlock,
        uint64 expiry
    ) external nonReentrant whenNotPaused {
        require(
            id != bytes32(0) &&
                locks[id].sender == address(0) &&
                recipient != address(0) &&
                amount > 0 &&
                hashlock != bytes32(0) &&
                expiry > block.timestamp,
            "lock"
        );
        AssetFlow.pullExact(token, msg.sender, amount);
        locks[id] = Lock(
            msg.sender,
            recipient,
            amount,
            hashlock,
            expiry,
            false
        );
        liability += amount;
        emit Locked(id, msg.sender, recipient, amount, expiry);
    }
    function redeem(bytes32 id, bytes calldata preimage) external nonReentrant {
        Lock storage l = locks[id];
        require(
            l.recipient == msg.sender &&
                !l.settled &&
                block.timestamp < l.expiry,
            "redeem"
        );
        require(sha256(preimage) == l.hashlock, "preimage");
        l.settled = true;
        liability -= l.amount;
        token.safeTransfer(msg.sender, l.amount);
        emit Redeemed(id, preimage);
    }
    function refund(bytes32 id) external nonReentrant {
        Lock storage l = locks[id];
        require(
            l.sender == msg.sender && !l.settled && block.timestamp >= l.expiry,
            "refund"
        );
        l.settled = true;
        liability -= l.amount;
        token.safeTransfer(msg.sender, l.amount);
        emit Refunded(id);
    }
}
