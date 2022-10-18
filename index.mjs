import { loadStdlib } from "@reach-sh/stdlib";
import * as backend from './build/index.main.mjs';
const stdlib = loadStdlib({REACH_NO_WARN: 'Y'});

const startingBalance = stdlib.parseCurrency(100);

const accAlice = await stdlib.newTestAccount(startingBalance);
console.log('Hello Alice');
console.log('Launching...');
const ctcAlice = accAlice.contract(backend);
console.log('Starting backends');

const users = [];
const startBobs = async () => {
  const newBob = async (who) => {
    const acc = await stdlib.newTestAccount(startingBalance);
    users.push(stdlib.formatAddress(acc.getAddress()));
    const ctc = acc.contract(backend, ctcAlice.getInfo());
    await ctc.apis.Bobs.checkin();
  };
  console.log('Creating new Bobs');
  await newBob('Bob1');
  await newBob('Bob2');
  await newBob('Bob3');
  await newBob('Bob4');
  console.log(users);
};

await ctcAlice.p.Alice({
  ready: (c) => {
    console.log(`Alice is ready at contract: ${c}`);
    startBobs();
  },
  showUser: (who, amt) => {
    console.log(`${stdlib.formatAddress(who)} has been counted. They paid ${stdlib.formatCurrency(amt)} ${stdlib.standardUnit}.`)
  },
  cost: stdlib.parseCurrency(10),
});

console.log('Goodbye, Alice and Bobs!');
