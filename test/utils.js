// source: https://github.com/OpenZeppelin/zeppelin-solidity/blob/master/test/helpers/increaseTime.js
module.exports.increaseTime = function increaseTime(duration) {
  const id = Date.now();

  return new Promise((resolve, reject) => {
    web3.currentProvider.sendAsync(
      {
        jsonrpc: "2.0",
        method: "evm_increaseTime",
        params: [duration],
        id: id
      },
      err1 => {
        if (err1) return reject(err1);

        web3.currentProvider.sendAsync(
          {
            jsonrpc: "2.0",
            method: "evm_mine",
            id: id + 1
          },
          (err2, res) => {
            return err2 ? reject(err2) : resolve(res);
          }
        );
      }
    );
  });
};

module.exports.spy = function spy(waitFor, fn) {
  let called = 0;
  const calls = [];
  const timeout = 2000;
  return new Promise((resolve, reject) => {
    const timeId = setTimeout(() => reject(`Spy timeout (${timeout}ms). Waiting for ${waitFor} calls but called ${calls.length} times.`), timeout);
    const event = fn((error, log) => {
      if (error) reject(error);
      calls.push(log)
      if (++called === waitFor) {
        clearTimeout(timeId);
        event.stopWatching();
        resolve(calls);
      };
    });
  });
}
