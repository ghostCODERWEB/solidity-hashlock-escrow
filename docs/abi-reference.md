# ABI reference

Generated from the successfully compiled primary contract. Includes inherited methods. Authorization and economic semantics are documented in the source.

| Signature | Type | Mutability | Returns |
|---|---|---|---|
| `constructor(address asset,address admin)` | constructor | nonpayable |  |
| `EnforcedPause()` | error |  |  |
| `ExpectedPause()` | error |  |  |
| `OwnableInvalidOwner(address owner)` | error |  |  |
| `OwnableUnauthorizedAccount(address account)` | error |  |  |
| `ReentrancyGuardReentrantCall()` | error |  |  |
| `SafeERC20FailedOperation(address token)` | error |  |  |
| `Locked(bytes32 id,address sender,address recipient,uint256 amount,uint64 expiry)` | event |  |  |
| `OwnershipTransferStarted(address previousOwner,address newOwner)` | event |  |  |
| `OwnershipTransferred(address previousOwner,address newOwner)` | event |  |  |
| `Paused(address account)` | event |  |  |
| `Redeemed(bytes32 id,bytes preimage)` | event |  |  |
| `Refunded(bytes32 id)` | event |  |  |
| `Unpaused(address account)` | event |  |  |
| `acceptOwnership()` | function | nonpayable |  |
| `liability()` | function | view | uint256  |
| `lock(bytes32 id,address recipient,uint256 amount,bytes32 hashlock,uint64 expiry)` | function | nonpayable |  |
| `locks(bytes32 )` | function | view | address sender, address recipient, uint256 amount, bytes32 hashlock, uint64 expiry, bool settled |
| `owner()` | function | view | address  |
| `paused()` | function | view | bool  |
| `pendingOwner()` | function | view | address  |
| `redeem(bytes32 id,bytes preimage)` | function | nonpayable |  |
| `refund(bytes32 id)` | function | nonpayable |  |
| `renounceOwnership()` | function | nonpayable |  |
| `setPaused(bool value)` | function | nonpayable |  |
| `token()` | function | view | address  |
| `transferOwnership(address newOwner)` | function | nonpayable |  |
