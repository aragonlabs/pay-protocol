pragma solidity 0.4.18;

import "@aragon/apps-token-manager/contracts/TokenManager.sol";
import "@aragon/core/contracts/zeppelin/token/ERC20.sol";

contract Airdrop {
    MiniMeToken public ANT = MiniMeToken(0x1234); // TODO: Set ANT mainnet addr
    address ETH = address(0);  // intentionally 0, just to keep balances

    // involve more projects? w more tokens?
    // St benefit to only allow ant and eth in terms of our own token utility
    // Mt-lt benefit to make it a community thing 100%

    uint256 constant public ANT_RATE = 100;  // tokens gotten per wei of token
    uint256 constant public ETH_RATE = 5000;
    uint256 constant public DAO_TOKENS = 50; // On mint, DAO ends with x% of supply
    uint256 constant PERCENT = 100;

    uint256 constant public END = 123456; // timestamp for airdrop end

    uint256 tbm; // to be minted
    bool minted;

    address public daoVault;
    uint256 public antSnapshotBlock;

    TokenManager manager;
    ERC20 token;
    // token -> holder -> balance
    mapping (address => mapping (address => uint256)) balances;

    event Drop(address indexed who, uint256 value);

    modifier opened { require(isOpen());  _; }
    modifier closed { require(!isOpen()); _; }

    function Airdrop(TokenManager _manager, address _daoVault, uint256 _antSnapshot) {
        require(address(_daoVault) != 0);

        manager = _manager;
        daoVault = _daoVault;
        antSnapshotBlock = _antSnapshot;
        token = ERC20(manager.token());

        require(token.totalSupply() == 0);
        // require(token != address(0)); // implicit in above check
    }

    function () payable {
        if (isOpen()) {
            if (msg.value == 0) antPing();
            else ethDeposit();
        } else withdraw(msg.sender);
    }

    function ethDeposit() opened payable {
        balances[ETH][msg.sender] += msg.value;
        require(balances[ETH][msg.sender] >= msg.value);

        giveTokens(msg.sender, ETH_RATE * msg.value);
    }

    function antPing() opened {
        // dont allow same block, to avoid token swaps on snapshot block
        require(blockN() > antSnapshotBlock);
        require(balances[ANT][msg.sender] == 0); // hasn't pinged before

        uint256 amount = ANT.balanceOfAt(msg.sender, antSnapshotBlock);
        balances[ANT][msg.sender] = amount;  // mark sender pinged

        giveTokens(msg.sender, ANT_RATE * amount);
    }

    function withdraw(address who) closed {
        if (!minted) mint();

        securityWithdraw(who);

        uint256 tokenBalance = balances[token][who];
        balances[token][who] = 0;

        if (tokenBalance > 0) require(token.transfer(who, tokenBalance));
    }

    // in case mint() fails, make sure 'real' funds dont get locked in the contract
    function securityWithdraw(address who) closed {
        uint256 ethBalance = balances[ETH][who];

        balances[ETH][who] = 0;

        if (ethBalance > 0) who.transfer(ethBalance);
    }

    function giveTokens(address who, uint256 drop) internal {
        balances[token][who] += drop;
        require(balances[token][who] >= drop); // check overflow

        tbm += drop; // add to mint count
        require(tbm >= drop); // check overflow

        Drop(who, drop);
    }

    function mint() internal {
        assert(!minted && !isOpen());
        minted = true;

        // Formula to get how many tokens the DAO has to get, to respect %s
        // AUDIT: this formula is correct
        uint256 daoTokens = tbm / (1e18 - (DAO_TOKENS * 1e18 / PERCENT)) - tbm;

        giveTokens(daoVault, daoTokens);
        manager.mint(this, tbm + daoTokens);
    }

    function isOpen() public view returns (bool) { return time() <= END; }

    function time() internal view returns (uint64) { return uint64(now); }

    function blockN() internal view returns (uint256) { return block.number; }
}
