const { assertRevert } = require('./helpers/assertErrors')
const payjs = require('../pay.js')

const PayProtocol = artifacts.require('PayProtocol')

contract('Pay, transfers', accounts => {
    let pay = {}

    const testAccount = {
        privateKey: '0x79b71a893c193802d16ad407ab4ad8fe2bf84cc7b8a9a0c1bd1c0fff4998ecad',
        address: '0x67e5e9dc12b2b02d1273522ec2c7cec8e447623d',
    }

    before(async () => {
        pay = await PayProtocol.new()
    })

    it('has empty balances', async () => {
        assert.equal(await pay.balance('0x0', '0x0'), 0)
    })

    context('transfer payload manipulation', () => {
        const token = accounts[2]
        const to = accounts[1]
        const value = 10
        const expires = 10
        const pull = true
        const push = false
        const deps = []

        const from = testAccount.address
        const signer = new payjs.Signer(testAccount.privateKey)

        it('transfer hash matches with pay.js', async () => {
            const t = new payjs.Transfer(pay.address, token, to, value, expires, pull, push, deps)

            const hashJS = t.transferHash(from)
            const hashSol = await pay.getHash(token, from, to, value, expires, pull, push, deps)

            assert.equal(hashJS, hashSol, 'js and sol hashes should match')
        })

        it('can sign transfer', async () => {
            const t = new payjs.Transfer(pay.address, token, to, value, expires, pull, push, deps)
            const sig = signer.sign(t)

            console.log(sig)
        })
    })
})
