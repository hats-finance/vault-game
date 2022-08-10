// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/extensions/ERC4626.sol)

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @dev Modified OpenZeppelin ERC4626 implementation for a 1 to 1 vault for ETH
 */
abstract contract ERC4626ETH is Ownable, ERC20 {
    using Math for uint256;

    event Deposit(address indexed caller, address indexed owner, uint256 assets, uint256 shares);

    event Withdraw(
        address indexed caller,
        address indexed receiver,
        address indexed owner,
        uint256 assets,
        uint256 shares
    );

    /** @dev See {IERC4262-asset}. */
    function asset() public view virtual returns (address) {
        return address(0);
    }

    /** @dev See {IERC4262-totalAssets}. */
    function totalAssets() public view virtual returns (uint256) {
        return address(this).balance;
    }

    /** @dev See {IERC4262-convertToShares}. */
    function convertToShares(uint256 assets) public view virtual returns (uint256 shares) {
        return assets;
    }

    /** @dev See {IERC4262-convertToAssets}. */
    function convertToAssets(uint256 shares) public view virtual returns (uint256 assets) {
        return shares;
    }

    /** @dev See {IERC4262-maxDeposit}. */
    function maxDeposit(address) public view virtual returns (uint256) {
        return type(uint256).max;
    }

    /** @dev See {IERC4262-maxMint}. */
    function maxMint(address) public view virtual returns (uint256) {
        return type(uint256).max;
    }

    /** @dev See {IERC4262-maxWithdraw}. */
    function maxWithdraw(address owner) public view virtual returns (uint256) {
        return balanceOf(owner);
    }

    /** @dev See {IERC4262-maxRedeem}. */
    function maxRedeem(address owner) public view virtual returns (uint256) {
        return balanceOf(owner);
    }

    /** @dev See {IERC4262-previewDeposit}. */
    function previewDeposit(uint256 assets) public view virtual returns (uint256) {
        return assets;
    }

    /** @dev See {IERC4262-previewMint}. */
    function previewMint(uint256 shares) public view virtual returns (uint256) {
        return shares;
    }

    /** @dev See {IERC4262-previewWithdraw}. */
    function previewWithdraw(uint256 assets) public view virtual returns (uint256) {
        return assets;
    }

    /** @dev See {IERC4262-previewRedeem}. */
    function previewRedeem(uint256 shares) public view virtual returns (uint256) {
        return shares;
    }

    /** @dev See {IERC4262-deposit}. */
    function deposit(uint256 assets, address receiver) public virtual payable returns (uint256) {
        require(assets <= maxDeposit(receiver), "ERC4626: deposit more than max");

        _deposit(_msgSender(), receiver, assets);

        return assets;
    }

    /** @dev See {IERC4262-mint}. */
    function mint(uint256 shares, address receiver) public virtual payable returns (uint256) {
        require(shares <= maxMint(receiver), "ERC4626: mint more than max");

        _deposit(_msgSender(), receiver, shares);

        return shares;
    }

    /** @dev See {IERC4262-withdraw}. */
    function withdraw(
        uint256 assets,
        address receiver,
        address owner
    ) public virtual returns (uint256) {
        require(assets <= maxWithdraw(owner), "ERC4626: withdraw more than max");

        _withdraw(_msgSender(), payable(receiver), owner, assets);

        return assets;
    }

    /** @dev See {IERC4262-redeem}. */
    function redeem(
        uint256 shares,
        address receiver,
        address owner
    ) public virtual returns (uint256) {
        require(shares <= maxRedeem(owner), "ERC4626: redeem more than max");

        _withdraw(_msgSender(), payable(receiver), owner, shares);

        return shares;
    }

    /**
     * @dev Deposit/mint common workflow.
     */
    function _deposit(
        address caller,
        address receiver,
        uint256 amount
    ) internal virtual {
        require(amount == msg.value, "Invalid amount sent");
        _mint(receiver, amount);

        emit Deposit(caller, receiver, amount, amount);
    }

    /**
     * @dev Withdraw/redeem common workflow.
     */
    function _withdraw(
        address caller,
        address payable receiver,
        address _owner,
        uint256 amount
    ) internal virtual {
        if (caller != _owner) {
            _spendAllowance(_owner, caller, amount);
        }

        uint256 excessETH = totalAssets() - totalSupply();
        
        _burn(_owner, amount);
        
        Address.sendValue(receiver, amount);
        if (excessETH > 0) {
            Address.sendValue(payable(owner()), excessETH);
        }

        emit Withdraw(caller, receiver, _owner, amount, amount);
    }

    function _isVaultCollateralized() private view returns (bool) {
        return totalAssets() > 0 || totalSupply() == 0;
    }
}
