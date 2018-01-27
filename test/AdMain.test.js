// Activate verbose mode by setting env var `export DEBUG=ck`
// Web3 = require("web3")
// provider = new Web3.providers.HttpProvider("http://166.111.82.253:8545")
// web3 = new Web3(provider)
const debug = require("debug")("ad");
const BigNumber = require("bignumber.js");

const ETH_STRING = web3.toWei(1, "ether");
const FINNEY_STRING = web3.toWei(1, "finney");
const ETH_BN = new BigNumber(ETH_STRING);
const FINNEY_BN = new BigNumber(FINNEY_STRING);
const NULL_ADDRESS = "0x0000000000000000000000000000000000000000";

// add test wrapper to make tests possible
const AdMain = artifacts.require("./AdMain.sol");


contract("AdMain", function(accounts) {
  // This only runs once across all test suites
  before(() => util.measureGas(accounts));
  after(() => util.measureGas(accounts));
  if (util.isNotFocusTest("core")) return;
  const eq = assert.equal.bind(assert);

  const advertiser = accounts[0];
  const user1 = accounts[1];
  const user2 = accounts[2];
  const bad_user = accounts[3];
  const media1 = accounts[4];
  const media2 = accounts[5];
  const gasPrice = 1e11;

  let coreC;

  const logEvents = [];
  const pastEvents = [];
  // timers we get from Kitty contract
  let cooldowns, autoBirthPrice;

  async function deployContract() {
    debug("deploying contract");
    coreC = await AdMain.new();
    // the deployer is the original CEO and can appoint a new one
    await coreC.setUser(user1);
    await coreC.setUser(user2);

    //await coreC.unpause({ from: ceo });

    const eventsWatch = coreC.allEvents();
    eventsWatch.watch((err, res) => {
      if (err) return;
      pastEvents.push(res);
      debug(">>", res.event, res.args);
    });
    logEvents.push(eventsWatch);

  }

  after(function() {
    logEvents.forEach(ev => ev.stopWatching());
  });

  describe("Initial state", function() {
    before(deployContract);

    it("should own contract", async function() {
      const ownerAddr = await coreC.owner();
      eq(ownerAddr, advertiser);

      //const nKitties = await coreC.totalSupply();
      //eq(nKitties.toNumber(), 0);
    });
  });

});
