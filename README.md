# OmniIDO
Raise Capital From Any Chain, Powered by LayerZero

## Diagram

![image](https://user-images.githubusercontent.com/26431906/230772158-30acafd6-cec4-4bd4-a930-ae1de2d742f4.png)

## Docs

## Destination Functions

### Initialize

    function initialize(
        IERC20 _token,
        IERC20 _offeringToken,
        uint256 _startTime,
        uint256 _endTime,
        uint256 _offeringAmount,
        uint256 _raisingAmount,
        uint256 _minAmount
    ) public onlyOwner

Initializes The IDO Details

#### Parameters

| Name | Type | Description
| ------ | ----------- | ------------ |
| `_token` | IERC20 | Investment Token |
| `_offeringToken` | IERC20 | Token being offered in exchange for `_token` |
| `_startTime` | uint256 | The time IDO will start (Unix Timestamp) |
| `_endTime` | uint256 | The time IDO will end (Unix Timestamp) |
| `_offeringAmount` | uint256 | The amount of `_offeringTokens` being offered |
| `_raisingAmount`  | uint256 | The amount of `_token` being raised |
| `_minAmount` | uint256 | Minimum amount of `_token` one user can invest |

### setMinAmount

    function setMinAmount(
        uint256 _minAmount
     ) public onlyOwner

Sets minimum amount of `_token` one user can invest

#### Parameters

| Name | Type | Description
| ------ | ----------- | ------------ |
| `_minAmount` | uint256 | Minimum amount of `token` one user can invest |


### setOfferingAmount

    function setOfferingAmount(
        uint256 _offerAmount
     ) public onlyOwner

Sets offering amount. This function will fail in case owner changes amount after `startTime`

#### Parameters

| Name | Type | Description
| ------ | ----------- | ------------ |
| `_offerAmount` | uint256 | The amount of `offeringToken`s being offered |

### setRaisingAmount

    function setRaisingAmount(
        uint256 _raisingAmount
    ) public onlyOwner

Sets raising amount. This function will fail in case owner changes amount after `startTime`

#### Parameters

| Name | Type | Description
| ------ | ----------- | ------------ |
| `_raisingAmount` | uint256 | The amount of tokens being raised |

### deposit

    function deposit(uint256 _amount) public

Transfers user's `token` to the contract and registers user's investment. The function will fail in case user:

- IDO hasn't started
- IDO is already over
- `_amount` is 0
- `_amount` is less than `minAmount`

#### Parameters

| Name | Type | Description
| ------ | ----------- | ------------ |
| `_amount` | uint256 | The amount of `token`s user is investing |

### omniDeposit

    function omniDeposit(
        uint256 _amount, 
        address _depositor
     ) internal

Internal function which registers user's investment - only accepts deposits from `stargateRouter`. The function will fail in case user:

- IDO hasn't started
- IDO is already over
- `_amount` is 0
- `_amount` is less than `minAmount`

#### Parameters

| Name | Type | Description
| ------ | ----------- | ------------ |
| `_amount` | uint256 | The amount of `token`s user is investing |
| `_depositor` | address | The user who invested `token` |


### claim

    function claim(
        _user
     ) public

This functions allows users to claim their `offeringToken`s. The function will fail in case user:

- IDO hasn't ended
- `_user` hasn't participated
- `_user` doesn't have anything to claim

#### Parameters

| Name | Type | Description
| ------ | ----------- | ------------ |
| `_user` | address | The user who's `offeringToken`s are being claimed |

### hasClaimed

    function hasClaimed(
        _user
     ) external view returns (bool)

This function returns if the user has claimed his/her `offeringToken`s

#### Parameters

| Name | Type | Description
| ------ | ----------- | ------------ |
| `_user` | address | The user who's `offeringToken`s status you're checking |


### getUserAllocation

    function getUserAllocation(
        _user
     ) external view returns (uint256)

This function returns user's allocation

#### Parameters

| Name | Type | Description
| ------ | ----------- | ------------ |
| `_user` | address | The user who you're checking |

### getOfferingAmount

    function getOfferingAmount(
        _user
     ) external view returns (uint256)

This function returns user's offering amount

#### Parameters

| Name | Type | Description
| ------ | ----------- | ------------ |
| `_user` | address | The user who you're checking |


### getRefundingAmount

    function getRefundingAmount(
        _user
     ) external view returns (uint256)

This function returns user's refunding amount

#### Parameters

| Name | Type | Description
| ------ | ----------- | ------------ |
| `_user` | address | The user who you're checking |

### getAddressListLength

    function getAddressListLength() external view returns (uint256)

This function returns total number of users invested in the IDO


### finalWithdraw

    function finalWithdraw(
        uint256 _lpAmount, 
        uint256 _offerAmount
    ) public onlyOwner

This function helps withdraw `token` and `offeringToken`. This function will fail in case:

- It doesn't hold enough `token`s
- It doesn't hold enough `offeringToken`s
- Transaction is not executed by owner

#### Parameters

| Name | Type | Description
| ------ | ----------- | ------------ |
| `_lpAmount` | uint256 | The amount of `token`s owner wants to withdraw |
| `_offerAmount` | uint256 | The amount of `offeringToken` owner wants to withdraw |

### _nonblockingLzReceive

    function _nonblockingLzReceive(
        uint16 _srcChainId, 
        bytes memory _srcAddress, 
        uint64 _nonce, 
        bytes memory _payload
    ) internal override

Usually meant for the user to remotely claim his assets


### sgReceive

    function sgReceive(
        uint16 _chainId, 
        bytes memory _srcAddress, 
        uint _nonce, 
        address _token, 
        uint amountLD, 
        bytes memory _payload
    ) external

Usually meant for the user to invest remotely
