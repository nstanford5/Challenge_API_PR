/**
 * Bobs Challenge - APIs, parallelReduce
 * 
 * Covers:
 * Simple parallelReduce
 * Intro to creating test API users in the frontend
 * Set insertion
 * basic verification checks
 * .api_ vs .api syntax
 * 
 */
'reach 0.1';

export const main = Reach.App(() => {
  const A = Participant('Alice', {
    cost: UInt,
    ready: Fun([Contract], Null),
    showUser: Fun([Address, UInt], Null),
  });
  const B = API('Bobs', {
    checkin: Fun([], Null),
  });
  init();
  A.only(() => {
    const amount = declassify(interact.cost);
  })
  A.publish(amount);
  A.interact.ready(getContract());

  const pSet = new Set();
  const [count] = parallelReduce([0])
    .invariant(balance() == count * amount)
    .while(count < 4)
    .api_(B.checkin, () => {// API.functionName, takes zero arguments
      // CHECK_EXPR -- assumptions about your function
      check(!pSet.member(this), "already checked in");
      check(this != A, 'you are the host')
      return[amount, (ret) => {// amount = PAY_EXPR; name return function ret
        pSet.insert(this);// add this Address to the set
        A.interact.showUser(this, amount);// log to the front end
        ret(null);// return null to the caller, must match line 40 and function signature
        return[count + 1];// update loop variable
      }];
    })
    // .api(B.checkin,// API.functionName
    //   () => {
    //     // ASSUME_EXPR -- assumptions about your function
    //     check(!pSet.member(this), "already checked in");
    //     check(this != A, "you are the host");
    //   },
    //   () => amount,// PAY_EXPR -- prompt the user to pay amount
    //   (ret) => {// CONSENSUS_EXPR -- function logic here
    //     pSet.insert(this);// add this address to the set
    //     A.interact.showUser(this, amount);// log to front end
    //     ret(null);// return null to the caller. Must match function name on line 53
    //     return[count + 1];// update loop variable
    //   })
  transfer(balance()).to(A);// arbitrary transfer amount
  commit();
  exit();
})
