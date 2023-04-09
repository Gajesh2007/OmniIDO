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

Initializes The IDO

#### Parameters

| Name | Type | Description
| ------ | ----------- | ------------ |
| _token |  |
| engine | engine to be used for processing templates. Handlebars is the default. |
| ext    | extension to be used for dest files. |
