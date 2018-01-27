const { signTypedData, typedSignatureHash } = require('eth-sig-util')
const { soliditySHA3 } = require('ethereumjs-abi')

class Transfer {
    constructor(protocol, token, to, value, expires, pull, push, deps, from) {
        this.protocol = protocol
        this.token = token
        this.to = to
        this.value = value
        this.expires = expires
        this.pull = pull
        this.push = push
        this.deps = deps
        this.from = from
    }

    transferHash(from = null) {
        if (from != null) {
            this.from = from
        }

        return typedSignatureHash(this.typedData())
    }

    // SCHEMA:
    // 'address protocol', 'address token', 'address from', 'address to', 'uint256 value', 'uint256 expires', 'bool pull', 'bool push', 'bytes32[] deps'

    typedData() {
        console.log('the dep hash', this.depsHash())
        return [
            { type: 'address', name: 'protocol', value: this.protocol },
            { type: 'address', name: 'token', value: this.token },
            { type: 'address', name: 'from', value: this.from },
            { type: 'address', name: 'to', value: this.to },
            { type: 'uint256', name: 'value', value: this.value },
            { type: 'uint256', name: 'expires', value: this.expires },
            { type: 'bool', name: 'pull', value: this.pull },
            { type: 'bool', name: 'push', value: this.push },
            { type: 'bytes32', name: 'depsHash', value: this.depsHash() },
        ]
    }

    depsHash() {
        const types = new Array(this.deps.length).fill('bytes32')
        return '0x'+soliditySHA3(types, this.deps).toString('hex')
    }
}

module.exports = Transfer
