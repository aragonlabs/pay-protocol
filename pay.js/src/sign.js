const { signTypedData } = require('eth-sig-util')

class PrivateKeySigner {
    constructor(privateKey) {
        this.privateKey = Buffer.from(privateKey.slice(2), 'hex')

        console.log(this.privateKey)
    }

    sign(transfer) {
        return signTypedData(this.privateKey, { data: transfer.typedData()})
    }
}

module.exports = PrivateKeySigner
