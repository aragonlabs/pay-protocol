pragma solidity 0.4.18;

import "./PayConstants.sol";

import "./misc/SignCheck.sol";
import "./misc/BytesHelper.sol";

import "@aragon/core/contracts/apps/App.sol";
import "@aragon/apps-token-manager/contracts/TokenManager.sol";
import "@aragon/core/contracts/zeppelin/token/ERC20.sol";

contract PayProtocol is App, SignCheck, PayConstants {
    using BytesHelper for bytes;

    struct Account {
        mapping (address => uint256) balance; // token -> balance (held in contract)
    }
    // TODO: Solve when contract gets an airdrop with another token addr
    //(How REP token re-deploy situation would have been solved)

    // SYSTEM STATE

    // accts cannot be transferred, but using ints as ids require acct creation
    // and can is vulnerable to chain reorg attacks to take over
    mapping (address => Account) accounts;
    mapping (bytes32 => bool) usedHashes;
    uint256 public tbm; // to be minted

    // GOVERNANCE

    TokenManager manager;
    ERC20 public govToken;

    uint256 public maxMintReward = 10 ** 18; // 1 token

    event LogTransfer(
        address indexed token,
        address indexed from, address indexed to,    // TODO: Decide on style experiment
        uint256 value,
        bool pull, bool push,
        bytes32 hash
    );

    /*
    function PayProtocol(TokenManager _manager) {
        manager = _manager;
        govToken = ERC20(manager.token());
    }
    */

    // Deposit in contract: when from == to, pull = true, push = false, value is deposited
    // Withdraw from contract: when from == to, pull = false, push = true, value is withdrawn
    // TODO: Add chainId to exec
    function exec(ERC20 token, address from, address to, uint256 value, uint64 expires, bool pull, bool push, bytes32[] deps, bytes sig) public {
        bytes32 hash = getHash(token, from, to, value, expires, pull, push, deps);
        require(from == getSigner(hash, sig))
        require(from != address(0));
        require(expires > time());
        require(!usedHashes[hash]);

        // A tx can execute only if a previous transfer occurred
        for (uint i; i < deps.length; i++) {
            require(usedHashes[deps[i]]);
        }

        usedHashes[hash] = true;

        if (to == TO_SENDER) to = msg.sender;

        // added before transfer to avoid code duplication. revoked if reverts
        LogTransfer(token, from, to, value, pull, push, hash);

        if (pull && push) {
            // Transfer occurs directly on token and we finish
            require(token.transferFrom(from, to, value));
            return;
        }

        // Credit either from token or contract balance
        if (pull) {
            require(token.transferFrom(from, this, value));
        } else {
            require(accounts[from].balance[token] >= value);
            accounts[from].balance[token] -= value;
        }

        // Debit either in the token or contract balance
        if (push) {
            require(token.transfer(to, value));
        } else {
            accounts[to].balance[token] += value;
            require(accounts[to].balance[token] >= value); // overflow check
        }
    }

    // TODO: Batch: check gas optimization by having a packed bytes payload
    // TODO: Batch: study gas cost
    // TODO: Make deps and sigs a nested array when solidity supports it (solc new ABI decoder)
    function batch(
        ERC20[] tokens,
        address[] from,
        address[] to,
        uint256[] value,
        uint64[] expires,
        bool[] pull,
        bool[] push,
        uint256[] depsLengths,
        bytes32[] flatDeps,
        uint256[] sigLengths,
        bytes flatSigs
    ) public {
        // TODO: Is checking length integrity needed? Accessing out of bounds reverts?

        // Done outside this function at the expense of having more loops.
        // Workaround 'stack too deep' solc error
        bytes32[][] memory unflattenedDeps = unflattenDeps(flatDeps, depsLengths);
        bytes[] memory unflattedSigs = unflattenSigs(flatSigs, sigLengths);

        for (uint i; i < tokens.length; i++) {
            exec(
                tokens[i],
                from[i],
                to[i],
                value[i],
                expires[i],
                pull[i],
                push[i],
                unflattenedDeps[i],
                unflattedSigs[i]
            );
        }
    }

    function mint(address coinbase) public {
        uint balance = govToken.balanceOf(this);
        // Minting reward is a function of how needed the minting is
        // (measured by how many tokens need to be minted relative to balance)
        uint reward = maxMintReward * tbm / (tbm + balance);
        accounts[coinbase].balance[govToken] += reward;
        require(accounts[coinbase].balance[govToken] >= reward); // overflow check

        uint totalMint = reward + tbm;
        tbm = 0;

        manager.mint(this, totalMint);

        LogTransfer(govToken, address(0), coinbase, reward, false, false, bytes32(0));
    }

    function balance(address token, address holder) public view returns (uint256) {
        return accounts[holder].balance[token];
    }

    function unflattenDeps(bytes32[] flatDeps, uint[] lengths) internal returns (bytes32[][]) {
        // TODO: check array bounds
        bytes32[][] memory unflattened = new bytes32[][](lengths.length);
        uint256 needle;
        for (uint256 i; i < lengths.length; i++) {
            bytes32[] memory deps = new bytes32[](lengths[i]);
            for (uint256 j; j < lengths[i]; j++) {
                deps[j] = flatDeps[needle + j];
            }
            needle += lengths[i];
            unflattened[i] = deps;
        }

        return unflattened;
    }

    function unflattenSigs(bytes flatSigs, uint[] lengths) internal returns (bytes[]) {
        bytes[] memory unflattened = new bytes[](lengths.length);
        uint256 needle;
        for (uint256 i; i < lengths.length; i++) {
            unflattened[i] = flatSigs.slice(needle, lengths[i]);
            needle += lengths[i];
        }

        return unflattened;
    }

    function getHash(address token, address from, address to, uint256 value, uint256 expires, bool pull, bool push, bytes32[] deps) view public returns (bytes32) {
        return keccak256(SCHEMA_HASH, keccak256(this, token, from, to, value, expires, pull, push, keccak256(deps)));
    }

    function time() internal view returns (uint64) { return uint64(now); }
}
