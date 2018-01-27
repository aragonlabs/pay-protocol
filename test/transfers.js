const { assertRevert } = require('./helpers/assertErrors')
const payjs = require('../pay.js')

const PayProtocol = artifacts.require('PayProtocol')

contract('Pay, transfers', accounts => {
    let pay = {}

    before(async () => {
        pay = await PayProtocol.new()
    })

    it('has empty balances', async () => {
        assert.equal(await pay.balance('0x0', '0x0'), 0)
    })

    it('transfer hash matches with pay.js', async () => {
        const token = accounts[2]
        const to = accounts[1]
        const value = 10
        const expires = 10
        const pull = true
        const push = false
        const deps = []

        const from = accounts[0]

        const t = new payjs.Transfer(pay.address, token, to, value, expires, pull, push, deps)

        const hashJS = t.transferHash(from)
        const hashSol = await pay.getHash(token, from, to, value, expires, pull, push, deps)

        assert.equal(hashJS, hashSol, 'js and sol hashes should match')
    })
})
