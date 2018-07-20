# Pay protocol
(provisional name)

**Everything in this repo is a research exercise on game theory and governance.**

## Mission statement: fixing the transition to a cashless world

The evolution to a 'cashless society' is the biggest threat to the sovereign
individual in centuries. Cash is clunky, I hate using cash, and in fact I never do,
but I'm scared to death at the possibility of **not being able** to use it when I need to.
Cash is anonymous, hardly traceable and allows free trade between free humans.

The eradication of the physical form of money will convert money in a purely
information network. Information can be censored.

Censoring speech is a horrible thing that shouldn't happen in advanced societies
but unfortunately it happens in every country in the world, every day.

When money is just information, and therefore speech, censoring someone means 
a person could be left in the street to starve.

Card networks and the banking system are really centralized to the point that
a state actor can shut down anyone not playing by their rules or that they might consider
a threat.

Assuming the transition to money as just information is happening it is really important
than the widely used money is money which is hardly censored and completely sovereign.

Incentivizing the transition to getting the mainstream to use p2p money is the only 
purpose of this effort.

## Why aren't we using crypto as money today

- **Network scalability**: Do we pay for coffee on or off-chain? Do hundreds of thousands
of computers world wide need to process every transaction happening in the world economy?
What is the 'correct' tradeoff between security and usability (in terms of fees)

- **Volatility**: High volatily makes crypto a really poor unit of account for day to day use.
A currency that is stable to people's spending basket is needed for crypto to flourish beyond
speculation and long term store of value. 

- **Network effect**: The classic chicken-and-egg problem. No incentive to use it until people you
transact with use it and accept it too. Once a threshold is passed, the network effect will do the
job on its own. But some incentive is needed to get the ball rolling.

- **UX**: Using crypto sucks and it is only used by true freedom fighters or people who are financially
interested in the speculation opportunity. History shows people use whatever is best and that has
nothing to do with values. The only chance is to make using crypto money a better experience than
Apple Pay, the bar is high.

## Solutions

I'm afraid I have nothing to offer on the **scalability** problem. I'm happy people way more intelligent
than myself are working on it and multiple solutions with different tradeoffs will be availble to be used.

The **volatility** problem is being solved by the brilliant [Maker team](https://makerdao.com) who are
building the [Dai](https://vimeo.com/247715549) stablecoin, which is a super collateralized coin that holds
a trustless peg to 1 USD. Significant improvements need to happen for Dai to become the world's currency
but I consider this a solved problem being worked on by a world class team engineers and economisms.

This protocol attempts to solve the last two, introducing a governance token to try to kickstart the **network
effect** (no ICO needed to kickstart the token supply) and save the user acquisition costs by using tokenomics.

Also presents a significant **UX** improvement by allowing Dai (and any ERC20/777 token actually) transfers without
ownining any ether, as well as the cheapest way to transact with tokens in the Ethereum network. The protocol allows
to pay transfer fees in whatever token the user is transacting with. All these while end users being the 
custodial of all their crypto money, which no third party can take away from them.

Token holders will govern a DAO that will own a significant part of the initial token supply. By voting,
DAO token holders should grant tokens to stakeholders that built or will build amazing user experiences for 
using crypto payments everywhere using the protocol. Client implementations of the protocol have the opportunity
to charge transaction fees on transfer settlement for users that don't want to own ether.

## Technical overview

At the technical level there are two main features of the protocol.

- An incentivization layer that mints PAY tokens to reward protocol usage.
- A token transferring and accounting layer that allows for super cheap token transfers.


[ ![Imgur](https://i.imgur.com/sxCYbCn.jpg) ](https://youtu.be/ik1VlTgD53w?t=7m31s)

Technical explanation starts at 7m31s: https://youtu.be/ik1VlTgD53w?t=7m31s

### Token transferring layer

The token transferring layer:

- Allows token owners to pay for transaction fees using any token, by incentivizing other entities to settle token transfers in exchange for a fee. This effectively allows users to own and use their tokens without ever needing any ETH.
- By keeping its own internal accounting of account balances in every token, it allows for really gas optimized token transfers.

## Team

There will be no team. Fortunately no advisors either.

The protocol shouldn't need a team to succeed.

This protocol should be completely governed by a DAO that incentivizes stakeholders to 
make it successful.

No ICO nor any type of crowdfunding should be needed to bootstrap the network.

## Troubleshooting

Until [aragon-core#160](https://github.com/aragon/aragon-core/pull/160) is
properly fixed and merged, to compile manually loose versions of dependency
contracts by finding and replacing `0.4.15` for `^0.4.15` in `node_modules/**/*.sol`

